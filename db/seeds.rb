Profile.find_or_create_by(name: 'Paciente')
Profile.find_or_create_by(name: 'Gestor')
Profile.find_or_create_by(name: 'Estagiário')

Appointment.destroy_all
TimeSlot.destroy_all
ConsultationRoom.destroy_all
LocationSpecialty.destroy_all
CollegeLocation.destroy_all
Specialty.destroy_all
User.destroy_all

puts "🎓 Criando especialidades..."
specialties = [
  { name: 'Nutrição',            description: 'Curso de Nutrição na IESB',       active: true },
  { name: 'Odontologia',    description: 'Curso de Odontologia na IESB', active: true },
  { name: 'Psicologia',                  description: 'Curso de Psicologia na IESB',               active: true },
].map { |attrs| Specialty.create!(attrs) }

puts "👤 Criando usuários..."
User.create!(name: 'Gestor', email: 'gestor@test.com', password: '12345678', password_confirmation: '12345678', profile: Profile.find_by(name: 'Gestor'), specialty: specialties.first, cpf: '12345678901')

# Criar estagiários
interns = [
  { name: 'Ana Estagiária', email: 'ana.intern@test.com', cpf: '18660795067', specialty: specialties.first },
  { name: 'Pedro Estagiário', email: 'pedro.intern@test.com', cpf: '09348680005', specialty: specialties.second },
  { name: 'Julia Estagiária', email: 'julia.intern@test.com', cpf: '42155270070', specialty: specialties.last }
].map do |attrs|
  user = User.find_by(email: attrs[:email])
  next if user.present?
  User.create!(
    name: attrs[:name],
    email: attrs[:email],
    password: '12345678',
    password_confirmation: '12345678',
    profile: Profile.find_by(name: 'Estagiário'),
    specialty: attrs[:specialty],
    cpf: attrs[:cpf]
  )
end

# Criar alguns pacientes com CPFs
patients = [
  { name: 'Maria Silva', email: 'maria@test.com', cpf: '12345678903' },
  { name: 'João Santos', email: 'joao@test.com', cpf: '12345678904' },
  { name: 'Ana Costa', email: 'ana@test.com', cpf: '12345678905' },
  { name: 'Pedro Oliveira', email: 'pedro@test.com', cpf: '12345678906' },
  { name: 'Julia Lima', email: 'julia@test.com', cpf: '12345678907' },
  { name: 'Carlos Souza', email: 'carlos@test.com', cpf: '12345678908' }
].map do |attrs|
  User.create!(
    name: attrs[:name],
    email: attrs[:email],
    password: '12345678',
    password_confirmation: '12345678',
    profile: Profile.find_by(name: 'Paciente'),
    cpf: attrs[:cpf]
  )
end

puts "🏫 Criando polos (college_locations)..."
campuses = [
  { name: 'Campus Asa Sul',   location: 'L2 Sul, Brasília - DF' },
  { name: 'Campus Ceilândia',      location: 'QS 317, Ceilândia - Brasília - DF' },
].map { |attrs| CollegeLocation.create!(attrs) }

puts "🔗 Associando especialidades a cada campus e criando salas de consulta..."
campus_specialties_map = {
  'Campus Asa Sul'  => ['Nutrição', 'Odontologia', 'Psicologia'],
  'Campus Ceilândia'     => ['Nutrição', 'Psicologia'],
}

campus_specialties_map.each do |campus_name, spec_names|
  campus = CollegeLocation.find_by!(name: campus_name)
  spec_names.each do |spec_name|
    spec = Specialty.find_by!(name: spec_name)

    # Join table
    LocationSpecialty.create!(
      college_location: campus,
      specialty:        spec
    )

    # Criar salas de consulta para cada especialidade
    room_count = spec_name == 'Nutrição' ? 8 : 4
    room_count.times.each do |room_label|
      ConsultationRoom.create!(
        college_location: campus,
        specialty:        spec,
        name:             "#{spec.name} – #{room_label + 1}",
        active:           true
      )
    end
  end
end

puts "⏰ Criando horários até janeiro de 2026..."

# Encontrar especialidades e salas
nutricao = Specialty.find_by!(name: 'Nutrição')
psicologia = Specialty.find_by!(name: 'Psicologia')
odontologia = Specialty.find_by!(name: 'Odontologia')

# Horários de funcionamento: 8h às 17h
horarios = ['08:00', '09:00', '10:00', '11:00', '14:00', '15:00', '16:00', '17:00']

# Criar horários de novembro de 2024 até janeiro de 2026
start_date = Date.current.beginning_of_month
end_date = Date.new(2026, 1, 31)

(start_date..end_date).each do |date|
  # Pular finais de semana
  next if date.saturday? || date.sunday?
  
  # Criar mais horários para nutrição
  if [1, 2, 3, 4, 5].include?(date.wday) # Segunda a sexta
    
    # Nutrição - mais horários
    nutricao_rooms = ConsultationRoom.where(specialty: nutricao)
    nutricao_rooms.each do |room|
      horarios.each do |horario|
        time_slot = TimeSlot.create!(
          start_time: DateTime.parse("#{date} #{horario}"),
          end_time: DateTime.parse("#{date} #{horario}") + 1.hour,
          college_location: room.college_location,
          specialty: nutricao
        )
        
        # Criar alguns agendamentos (5% dos horários - mais realista)
        if rand < 0.05
          patient = patients.sample
          status = ['pending', 'admin_confirmed', 'completed', 'cancelled_by_admin'].sample
          start_time = DateTime.parse("#{date} #{horario}")
          end_time = start_time + 1.hour
          
          appointment = Appointment.create!(
            user: patient,
            time_slot: time_slot,
            consultation_room: room,
            status: status,
            date: date,
            start_time: start_time,
            end_time: end_time,
            notes: status == 'completed' ? "Consulta realizada com sucesso" : nil
          )
          
          # Adicionar estagiários aleatoriamente (30% dos agendamentos)
          if rand < 0.3
            selected_interns = interns.select { |intern| intern.specialty == nutricao }.sample(rand(1..3))
            appointment.interns = selected_interns
          end
        end
      end
    end
    
    # Psicologia - horários reduzidos
    psicologia_rooms = ConsultationRoom.where(specialty: psicologia)
    psicologia_rooms.each do |room|
      horarios.sample(4).each do |horario| # Apenas 4 horários por dia
        time_slot = TimeSlot.create!(
          start_time: DateTime.parse("#{date} #{horario}"),
          end_time: DateTime.parse("#{date} #{horario}") + 1.hour,
          college_location: room.college_location,
          specialty: psicologia
        )
        
        # Menos agendamentos para psicologia (3% - ainda mais raro)
        if rand < 0.03
          patient = patients.sample
          status = ['pending', 'completed'].sample
          start_time = DateTime.parse("#{date} #{horario}")
          end_time = start_time + 1.hour
          
          appointment = Appointment.create!(
            user: patient,
            time_slot: time_slot,
            consultation_room: room,
            status: status,
            date: date,
            start_time: start_time,
            end_time: end_time,
            notes: status == 'completed' ? "Sessão de terapia realizada" : nil
          )
          
          # Adicionar estagiários de psicologia
          if rand < 0.2
            selected_interns = interns.select { |intern| intern.specialty == psicologia }.sample(1)
            appointment.interns = selected_interns
          end
        end
      end
    end
    
    # Odontologia - apenas no Campus Asa Sul
    if CollegeLocation.find_by(name: 'Campus Asa Sul')
      odonto_rooms = ConsultationRoom.where(
        specialty: odontologia,
        college_location: CollegeLocation.find_by(name: 'Campus Asa Sul')
      ).limit(2)
      
      odonto_rooms.each do |room|
        horarios.sample(3).each do |horario| # Apenas 3 horários por dia
          time_slot = TimeSlot.create!(
            start_time: DateTime.parse("#{date} #{horario}"),
            end_time: DateTime.parse("#{date} #{horario}") + 1.hour,
            college_location: room.college_location,
            specialty: odontologia
          )
          
          # Agendamentos para odontologia (4% - realista)
          if rand < 0.04
            patient = patients.sample
            status = ['pending', 'completed'].sample
            start_time = DateTime.parse("#{date} #{horario}")
            end_time = start_time + 1.hour
            
            appointment = Appointment.create!(
              user: patient,
              time_slot: time_slot,
              consultation_room: room,
              status: status,
              date: date,
              start_time: start_time,
              end_time: end_time,
              notes: status == 'completed' ? "Procedimento odontológico realizado" : nil
            )
            
            # Adicionar estagiários de odontologia
            if rand < 0.25
              selected_interns = interns.select { |intern| intern.specialty == odontologia }.sample(1)
              appointment.interns = selected_interns
            end
          end
        end
      end
    end
  end
end

puts "📊 Estatísticas criadas:"
puts "- Usuários: #{User.count}"
puts "- Especialidades: #{Specialty.count}"
puts "- Campi: #{CollegeLocation.count}"
puts "- Salas de consulta: #{ConsultationRoom.count}"
puts "- Horários criados: #{TimeSlot.count}"
puts "- Agendamentos: #{Appointment.count}"
puts "- Agendamentos concluídos: #{Appointment.where(status: 'completed').count}"
puts "- Horários livres: #{TimeSlot.left_joins(:appointments).where(appointments: { id: nil }).count}"

puts "✅ Seed finalizado!"