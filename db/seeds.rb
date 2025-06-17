Profile.find_or_create_by(name: 'Paciente')
Profile.find_or_create_by(name: 'Gestor')
Profile.find_or_create_by(name: 'Estagiário')

ConsultationRoom.delete_all
LocationSpecialty.delete_all
CollegeLocation.delete_all
Specialty.delete_all

puts "🎓 Criando especialidades..."
specialties = [
  { name: 'Nutrição',            description: 'Curso de Administração na IESB',       active: true },
  { name: 'Odontologia',    description: 'Curso de Ciência da Computação na IESB', active: true },
  { name: 'Psicologia',                  description: 'Curso de Direito na IESB',               active: true },
].map { |attrs| Specialty.create!(attrs) }

User.create(name: 'Gestor', email: 'gestor@test.com', password: '12345678', password_confirmation: '12345678', profile: Profile.find_by(name: 'Gestor'), specialty: specialties.first)
User.create(name: 'Estagiário', email: 'intern@test.com', password: '12345678', password_confirmation: '12345678', profile: Profile.find_by(name: 'Estagiário'), specialty: specialties.first)
User.create(name: 'Paciente', email: 'patient@test.com', password: '12345678', password_confirmation: '12345678', profile: Profile.find_by(name: 'Paciente'))

puts "🏫 Criando polos (college_locations)..."
campuses = [
  { name: 'Campus Brasília Sul',   location: 'Setor Comercial Sul, Brasília - DF' },
  { name: 'Campus Taguatinga',     location: 'QNM 26 Conjunto G, Taguatinga - DF' },
  { name: 'Campus Ceilândia',      location: 'QS 317, Ceilândia - Brasília - DF' },
  { name: 'Campus Gama',           location: 'SGAN Quadra 613, Gama - Brasília - DF' },
  { name: 'Campus Águas Claras',   location: 'QNO 18, Águas Claras - Brasília - DF' }
].map { |attrs| CollegeLocation.create!(attrs) }

puts "🔗 Associando especialidades a cada campus e criando salas de consulta..."
campus_specialties_map = {
  'Campus Brasília Sul'  => ['Psicologia'],
  'Campus Taguatinga'    => ['Psicologia', 'Odontologia'],
  'Campus Ceilândia'     => ['Nutrição', 'Odontologia', 'Psicologia'],
  'Campus Gama'          => ['Odontologia'],
  'Campus Águas Claras'  => ['Nutrição']
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

    # Criar duas salas de consulta para cada especialidade
    ['Sala 1', 'Sala 2'].each do |room_label|
      ConsultationRoom.create!(
        college_location: campus,
        specialty:        spec,
        name:             "#{spec.name} – #{room_label}",
        active:           true
      )
    end
  end
end

puts "✅ Seed finalizado!"