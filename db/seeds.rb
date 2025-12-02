# seeds.rb

# --- Helpers ---
def generate_cpf
  digits = 9.times.map { rand(0..9) }
  v1 = digits.each_with_index.map { |d, i| d * (10 - i) }.sum % 11
  digits << (v1 < 2 ? 0 : 11 - v1)
  v2 = digits.each_with_index.map { |d, i| d * (11 - i) }.sum % 11
  digits << (v2 < 2 ? 0 : 11 - v2)
  digits.join
end

# --- Limpeza ---
puts "🗑️  Limpando banco de dados..."
# Usando really_destroy! se tiver paranoia, senao destroy_all
Appointment.respond_to?(:really_destroy!) ? Appointment.with_deleted.each(&:really_destroy!) : Appointment.destroy_all
TimeSlot.respond_to?(:really_destroy!) ? TimeSlot.with_deleted.each(&:really_destroy!) : TimeSlot.destroy_all
ConsultationRoom.destroy_all
LocationSpecialty.destroy_all
User.with_deleted.each(&:really_destroy!) if User.respond_to?(:really_destroy!)
User.destroy_all unless User.count == 0
CollegeLocation.destroy_all
Specialty.destroy_all
Profile.destroy_all

puts "🛠️  Criando Perfis..."
p_paciente   = Profile.find_or_create_by!(name: 'Paciente')
p_gestor     = Profile.find_or_create_by!(name: 'Gestor')
p_estagiario = Profile.find_or_create_by!(name: 'Estagiário')

puts "🎓 Criando Especialidades..."
specialties = [
  { name: 'Nutrição',    description: 'Atendimento nutricional', active: true },
  { name: 'Odontologia', description: 'Tratamentos dentários',   active: true },
  { name: 'Psicologia',  description: 'Acompanhamento psicológico', active: true }
].map { |attrs| Specialty.create!(attrs) }

spec_nutri = specialties.find { |s| s.name == 'Nutrição' }
spec_odon  = specialties.find { |s| s.name == 'Odontologia' }
spec_psi   = specialties.find { |s| s.name == 'Psicologia' }

puts "🏫 Criando Polos..."
campus_asa_sul = CollegeLocation.create!(name: 'Campus Asa Sul', location: 'L2 Sul')
campus_ceilandia = CollegeLocation.create!(name: 'Campus Ceilândia', location: 'Ceilândia')

puts "🔗 Configurando Salas..."
config_salas = [
  [ campus_asa_sul, spec_nutri, 3 ],
  [ campus_asa_sul, spec_odon,  4 ],
  [ campus_asa_sul, spec_psi,   3 ],
  [ campus_ceilandia, spec_nutri, 2 ],
  [ campus_ceilandia, spec_psi,   2 ]
]

config_salas.each do |campus, specialty, qtd|
  LocationSpecialty.find_or_create_by!(college_location: campus, specialty: specialty)
  qtd.times do |i|
    ConsultationRoom.create!(
      college_location: campus,
      specialty: specialty,
      name: "#{specialty.name} - Sala #{i + 1} (#{campus.name.split.last})",
      active: true
    )
  end
end

puts "👥 Criando USUÁRIOS PRINCIPAIS..."

# Gestor Principal (Necessário para o Current.user)
gestor_demo = User.create!(
  name: 'Gestor Demo', email: 'gestor@tcc.com',
  password: '12345678', password_confirmation: '12345678',
  profile: p_gestor, specialty: spec_nutri, cpf: generate_cpf
)

# Estagiário Demo
User.create!(
  name: 'Estagiário Demo', email: 'estagiario@tcc.com',
  password: '12345678', password_confirmation: '12345678',
  profile: p_estagiario, specialty: spec_nutri, cpf: generate_cpf
)

# Paciente Demo
User.create!(
  name: 'Paciente Demo', email: 'paciente@tcc.com',
  password: '12345678', password_confirmation: '12345678',
  profile: p_paciente, cpf: generate_cpf, phone: '(61) 99999-9999'
)

# Simulando usuário logado para os callbacks do modelo funcionarem
# Se sua app usa Current.user, isso evita erro de nil
if defined?(Current)
  Current.user = gestor_demo
end

puts "👥 Criando usuários extras..."
# Estagiários
interns = []
15.times do
  interns << User.create!(
    name: "Estagiário #{Faker::Name.first_name rescue 'Extra'}",
    email: "estagiario_#{SecureRandom.hex(4)}@test.com",
    password: '12345678', password_confirmation: '12345678',
    profile: p_estagiario,
    specialty: specialties.sample,
    cpf: generate_cpf
  )
end

# Pacientes
patients = []
20.times do |i|
  patients << User.create!(
    name: "Paciente #{i+1}",
    email: "paciente_#{i+1}@test.com",
    password: '12345678', password_confirmation: '12345678',
    profile: p_paciente,
    cpf: generate_cpf,
    phone: "(61) 98888-#{1000 + i}"
  )
end

puts "⏰ Gerando AGENDA E CONSULTAS..."

all_rooms = ConsultationRoom.all
start_date = 14.days.ago.to_date
end_date   = 30.days.from_now.to_date
horarios_base = [ '08:00', '09:00', '10:00', '14:00', '15:00', '16:00' ]

(start_date..end_date).each do |date|
  next if date.saturday? || date.sunday?

  is_past   = date < Date.current
  is_today  = date == Date.current
  is_future = date > Date.current

  all_rooms.each do |room|
    # Menos horários no futuro distante
    next if is_future && date > 5.days.from_now && rand > 0.4

    horarios_do_dia = horarios_base.dup
    # Se for hoje, simula que alguns já passaram
    horarios_do_dia = horarios_base.last(3) if is_today && Time.now.hour > 13

    horarios_do_dia.each do |horario|
      start_time = DateTime.parse("#{date} #{horario}")

      # Cria o TimeSlot (disponibilidade)
      ts = TimeSlot.create!(
        start_time: start_time,
        end_time: start_time + 1.hour,
        date: date,
        college_location: room.college_location,
        specialty: room.specialty
      )

      # LÓGICA DE STATUS REALISTA
      should_book = false
      status_to_assign = nil

      if is_past
        should_book = rand > 0.3 # 70% de ocupação no passado
        # No passado, a maioria foi concluída, mas houve cancelamentos
        status_to_assign = [ :completed, :completed, :completed, :patient_cancelled, :cancelled_by_admin, :rejected ].sample

      elsif is_today
        should_book = rand > 0.4
        if start_time < Time.now
          status_to_assign = :completed # Já aconteceu hoje
        else
          # Próximas horas: Tudo pronto (confirmado) ou pendente de última hora
          status_to_assign = [ :patient_confirmed, :patient_confirmed, :admin_confirmed ].sample
        end

      elsif is_future
        # No futuro, deixamos MAIS LIVRE para você agendar na demo
        should_book = rand > 0.75 # Apenas 25% ocupado
        # Futuro: Pendente, Confirmado pelo Admin (esperando paciente) ou Confirmado Final
        status_to_assign = [ :pending, :admin_confirmed, :patient_confirmed ].sample
      end

      if should_book
        patient = patients.sample

        app = Appointment.new(
          user: patient,
          time_slot: ts,
          consultation_room: room,
          date: date,
          start_time: start_time,
          end_time: start_time + 1.hour,
          status: status_to_assign,
          notes: status_to_assign == :completed ? "Atendimento realizado conforme protocolo." : nil
        )

        # Salva o agendamento (Callbacks de notificação rodarão aqui)
        # O log_status_change usará o Current.user definido acima
        if app.save
          # Associa estagiários da especialidade correta
          if [ :patient_confirmed, :completed ].include?(status_to_assign)
            room_interns = interns.select { |u| u.specialty_id == room.specialty_id }
            app.interns << room_interns.sample(rand(1..2)) if room_interns.any?
          end
        else
          puts "⚠️ Erro ao criar consulta: #{app.errors.full_messages}"
        end
      end
    end
  end
end

puts "✅ SEED FINALIZADO!"
puts "Estatísticas:"
puts "Pendentes: #{Appointment.where(status: :pending).count}"
puts "Aguardando Paciente (Admin Confirmed): #{Appointment.where(status: :admin_confirmed).count}"
puts "Confirmadas (Patient Confirmed): #{Appointment.where(status: :patient_confirmed).count}"
puts "Concluídas: #{Appointment.where(status: :completed).count}"
