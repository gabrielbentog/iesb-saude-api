Profile.find_or_create_by(name: 'Paciente')
Profile.find_or_create_by(name: 'Gestor')
Profile.find_or_create_by(name: 'Estagiário')

Appointment.destroy_all
TimeSlot.destroy_all
ConsultationRoom.destroy_all
LocationSpecialty.destroy_all
CollegeLocation.destroy_all
Specialty.destroy_all

puts "🎓 Criando especialidades..."
specialties = [
  { name: 'Nutrição',            description: 'Curso de Nutrição na IESB',       active: true },
  { name: 'Odontologia',    description: 'Curso de Odontologia na IESB', active: true },
  { name: 'Psicologia',                  description: 'Curso de Psicologia na IESB',               active: true },
].map { |attrs| Specialty.create!(attrs) }

User.create(name: 'Gestor', email: 'gestor@test.com', password: '12345678', password_confirmation: '12345678', profile: Profile.find_by(name: 'Gestor'), specialty: specialties.first)
User.create(name: 'Estagiário', email: 'intern@test.com', password: '12345678', password_confirmation: '12345678', profile: Profile.find_by(name: 'Estagiário'), specialty: specialties.first)
User.create(name: 'Paciente', email: 'patient@test.com', password: '12345678', password_confirmation: '12345678', profile: Profile.find_by(name: 'Paciente'))

puts "🏫 Criando polos (college_locations)..."
campuses = [
  { name: 'Campus Asa Sul',   location: 'Setor Comercial Sul, Brasília - DF' },
  # { name: 'Campus Taguatinga',     location: 'QNM 26 Conjunto G, Taguatinga - DF' },
  { name: 'Campus Ceilândia',      location: 'QS 317, Ceilândia - Brasília - DF' },
  # { name: 'Campus Gama',           location: 'SGAN Quadra 613, Gama - Brasília - DF' },
  # { name: 'Campus Águas Claras',   location: 'QNO 18, Águas Claras - Brasília - DF' }
].map { |attrs| CollegeLocation.create!(attrs) }

puts "🔗 Associando especialidades a cada campus e criando salas de consulta..."
campus_specialties_map = {
  'Campus Asa Sul'  => ['Nutrição'], # , 'Odontologia', 'Psicologia'],
  # 'Campus Taguatinga'    => ['Psicologia', 'Odontologia'],
  'Campus Ceilândia'     => ['Nutrição'], #, 'Odontologia', 'Psicologia'],
  # 'Campus Gama'          => ['Odontologia'],
  # 'Campus Águas Claras'  => ['Nutrição']
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

    # Criar oito salas de consulta para cada especialidade
    8.times.each do |room_label|
      ConsultationRoom.create!(
        college_location: campus,
        specialty:        spec,
        name:             "#{spec.name} – #{room_label + 1}",
        active:           true
      )
    end
  end
end

puts "✅ Seed finalizado!"