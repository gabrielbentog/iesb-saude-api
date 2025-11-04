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

# Criar estagiários - 3 para cada especialidade
interns = [
  # Nutrição
  { name: 'Ana Estagiária', email: 'ana.intern@test.com', cpf: '18660795067', specialty: specialties.first },
  { name: 'Carlos Estagiário', email: 'carlos.intern@test.com', cpf: '11122233344', specialty: specialties.first },
  { name: 'Fernanda Estagiária', email: 'fernanda.intern@test.com', cpf: '55566677788', specialty: specialties.first },
  
  # Odontologia
  { name: 'Pedro Estagiário', email: 'pedro.intern@test.com', cpf: '09348680005', specialty: specialties.second },
  { name: 'Mariana Estagiária', email: 'mariana.intern@test.com', cpf: '99988877766', specialty: specialties.second },
  { name: 'Rafael Estagiário', email: 'rafael.intern@test.com', cpf: '33344455566', specialty: specialties.second },
  
  # Psicologia
  { name: 'Julia Estagiária', email: 'julia.intern@test.com', cpf: '42155270070', specialty: specialties.last },
  { name: 'Lucas Estagiário', email: 'lucas.intern@test.com', cpf: '77788899900', specialty: specialties.last },
  { name: 'Beatriz Estagiária', email: 'beatriz.intern@test.com', cpf: '12321456789', specialty: specialties.last }
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
end.compact

# Criar alguns pacientes com CPFs e telefones
patients = [
  { name: 'Maria Silva', email: 'maria@test.com', cpf: '12345678903', phone: '(61) 99999-1111' },
  { name: 'João Santos', email: 'joao@test.com', cpf: '12345678904', phone: '(61) 99999-2222' },
  { name: 'Ana Costa', email: 'ana@test.com', cpf: '12345678905', phone: '(61) 99999-3333' },
  { name: 'Pedro Oliveira', email: 'pedro@test.com', cpf: '12345678906', phone: '(61) 99999-4444' },
  { name: 'Julia Lima', email: 'julia@test.com', cpf: '12345678907', phone: '(61) 99999-5555' },
  { name: 'Carlos Souza', email: 'carlos@test.com', cpf: '12345678908', phone: '(61) 99999-6666' }
].map do |attrs|
  User.create!(
    name: attrs[:name],
    email: attrs[:email],
    password: '12345678',
    password_confirmation: '12345678',
    profile: Profile.find_by(name: 'Paciente'),
    cpf: attrs[:cpf],
    phone: attrs[:phone]
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

    # Criar salas de consulta para cada especialidade (reduzido para teste)
    room_count = case spec_name
                 when 'Nutrição' then 2      # Era 8, agora 2
                 else 1                      # Era 4, agora 1
                 end
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

# Horários de funcionamento: apenas alguns horários por dia (ambiente de teste)
horarios = ['08:00', '10:00', '14:00', '16:00']  # Apenas 4 horários por dia

# Criar horários apenas para algumas semanas (não o ano todo)
start_date = Date.current
end_date = Date.current + 2.months  # Apenas 2 meses para teste

(start_date..end_date).each do |date|
  # Pular finais de semana
  next if date.saturday? || date.sunday?
  
  # Criar mais horários para nutrição
  if [1, 2, 3, 4, 5].include?(date.wday) # Segunda a sexta
    
    # Nutrição - criar TODOS os horários primeiro
    nutricao_rooms = ConsultationRoom.where(specialty: nutricao)
    nutricao_time_slots = []
    
    nutricao_rooms.each do |room|
      horarios.each do |horario|
        time_slot = TimeSlot.create!(
          start_time: DateTime.parse("#{date} #{horario}"),
          end_time: DateTime.parse("#{date} #{horario}") + 1.hour,
          date: date,
          college_location: room.college_location,
          specialty: nutricao
        )
        nutricao_time_slots << { time_slot: time_slot, room: room, horario: horario }
      end
    end
    
    # Agora criar alguns agendamentos (20% dos horários criados - mais visível)
    appointments_to_create = [(nutricao_time_slots.size * 0.2).to_i, 1].max  # Pelo menos 1
    nutricao_time_slots.shuffle.first(appointments_to_create).each do |slot_data|
      patient = patients.sample
      status = ['pending', 'admin_confirmed', 'completed', 'cancelled_by_admin'].sample
      start_time = DateTime.parse("#{date} #{slot_data[:horario]}")
      end_time = start_time + 1.hour
      
      appointment = Appointment.create!(
        user: patient,
        time_slot: slot_data[:time_slot],
        consultation_room: slot_data[:room],
        status: status,
        date: date,
        start_time: start_time,
        end_time: end_time,
        notes: status == 'completed' ? "Consulta realizada com sucesso" : nil
      )
      
      # Adicionar estagiários (90% dos agendamentos têm de 1 a 3 estagiários)
      if rand < 0.9
        selected_interns = interns.select { |intern| intern.specialty == nutricao }.sample(rand(1..3))
        appointment.interns = selected_interns if selected_interns.any?
      end
    end
    
    # Psicologia - criar horários primeiro (reduzido)
    psicologia_rooms = ConsultationRoom.where(specialty: psicologia)
    psicologia_time_slots = []
    
    psicologia_rooms.each do |room|
      horarios.sample(2).each do |horario| # Apenas 2 horários por dia (era 4)
        time_slot = TimeSlot.create!(
          start_time: DateTime.parse("#{date} #{horario}"),
          end_time: DateTime.parse("#{date} #{horario}") + 1.hour,
          date: date,
          college_location: room.college_location,
          specialty: psicologia
        )
        psicologia_time_slots << { time_slot: time_slot, room: room, horario: horario }
      end
    end
    
    # Criar alguns agendamentos (15% dos horários criados - mais visível)
    appointments_to_create = [(psicologia_time_slots.size * 0.15).to_i, 1].max  # Pelo menos 1
    psicologia_time_slots.shuffle.first(appointments_to_create).each do |slot_data|
      patient = patients.sample
      status = ['pending', 'completed'].sample
      start_time = DateTime.parse("#{date} #{slot_data[:horario]}")
      end_time = start_time + 1.hour
      
      appointment = Appointment.create!(
        user: patient,
        time_slot: slot_data[:time_slot],
        consultation_room: slot_data[:room],
        status: status,
        date: date,
        start_time: start_time,
        end_time: end_time,
        notes: status == 'completed' ? "Sessão de terapia realizada" : nil
      )
      
      # Adicionar estagiários (90% dos agendamentos têm de 1 a 3 estagiários)
      if rand < 0.9
        selected_interns = interns.select { |intern| intern.specialty == psicologia }.sample(rand(1..3))
        appointment.interns = selected_interns if selected_interns.any?
      end
    end
    
    # Odontologia - apenas no Campus Asa Sul
    if CollegeLocation.find_by(name: 'Campus Asa Sul')
      odonto_rooms = ConsultationRoom.where(
        specialty: odontologia,
        college_location: CollegeLocation.find_by(name: 'Campus Asa Sul')
      )
      odonto_time_slots = []
      
      odonto_rooms.each do |room|
        horarios.sample(2).each do |horario| # Apenas 2 horários por dia (era 3)
          time_slot = TimeSlot.create!(
            start_time: DateTime.parse("#{date} #{horario}"),
            end_time: DateTime.parse("#{date} #{horario}") + 1.hour,
            date: date,
            college_location: room.college_location,
            specialty: odontologia
          )
          odonto_time_slots << { time_slot: time_slot, room: room, horario: horario }
        end
      end
      
      # Criar alguns agendamentos (18% dos horários criados - mais visível)
      appointments_to_create = [(odonto_time_slots.size * 0.18).to_i, 1].max  # Pelo menos 1
      odonto_time_slots.shuffle.first(appointments_to_create).each do |slot_data|
        patient = patients.sample
        status = ['pending', 'completed'].sample
        start_time = DateTime.parse("#{date} #{slot_data[:horario]}")
        end_time = start_time + 1.hour
        
        appointment = Appointment.create!(
          user: patient,
          time_slot: slot_data[:time_slot],
          consultation_room: slot_data[:room],
          status: status,
          date: date,
          start_time: start_time,
          end_time: end_time,
          notes: status == 'completed' ? "Procedimento odontológico realizado" : nil
        )
        
        # Adicionar estagiários (90% dos agendamentos têm de 1 a 3 estagiários)
        if rand < 0.9
          selected_interns = interns.select { |intern| intern.specialty == odontologia }.sample(rand(1..3))
          appointment.interns = selected_interns if selected_interns.any?
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