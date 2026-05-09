class ExerciseTemplate {
  final String name;
  final String muscleGroup;
  final String equipment;

  const ExerciseTemplate(this.name, this.muscleGroup, this.equipment);
}

const kExercises = [
  // Peito
  ExerciseTemplate('Supino reto', 'Peito', 'Barra'),
  ExerciseTemplate('Supino inclinado', 'Peito', 'Barra'),
  ExerciseTemplate('Supino declinado', 'Peito', 'Barra'),
  ExerciseTemplate('Supino reto halteres', 'Peito', 'Halteres'),
  ExerciseTemplate('Supino inclinado halteres', 'Peito', 'Halteres'),
  ExerciseTemplate('Crucifixo reto', 'Peito', 'Halteres'),
  ExerciseTemplate('Crucifixo inclinado', 'Peito', 'Halteres'),
  ExerciseTemplate('Peck deck', 'Peito', 'Máquina'),
  ExerciseTemplate('Crossover', 'Peito', 'Cabo'),
  ExerciseTemplate('Flexão de braços', 'Peito', 'Peso corporal'),

  // Costas
  ExerciseTemplate('Remada curvada', 'Costas', 'Barra'),
  ExerciseTemplate('Remada curvada halteres', 'Costas', 'Halteres'),
  ExerciseTemplate('Remada cavalinho', 'Costas', 'Máquina'),
  ExerciseTemplate('Remada serrote', 'Costas', 'Halteres'),
  ExerciseTemplate('Puxada frontal', 'Costas', 'Máquina'),
  ExerciseTemplate('Puxada supinada', 'Costas', 'Máquina'),
  ExerciseTemplate('Puxada aberta', 'Costas', 'Máquina'),
  ExerciseTemplate('Barra fixa', 'Costas', 'Peso corporal'),
  ExerciseTemplate('Levantamento terra', 'Costas', 'Barra'),
  ExerciseTemplate('Remada alta', 'Costas', 'Barra'),

  // Ombros
  ExerciseTemplate('Desenvolvimento barra', 'Ombros', 'Barra'),
  ExerciseTemplate('Desenvolvimento halteres', 'Ombros', 'Halteres'),
  ExerciseTemplate('Desenvolvimento máquina', 'Ombros', 'Máquina'),
  ExerciseTemplate('Elevação lateral', 'Ombros', 'Halteres'),
  ExerciseTemplate('Elevação lateral cabo', 'Ombros', 'Cabo'),
  ExerciseTemplate('Elevação frontal', 'Ombros', 'Halteres'),
  ExerciseTemplate('Encolhimento', 'Ombros', 'Halteres'),
  ExerciseTemplate('Encolhimento barra', 'Ombros', 'Barra'),
  ExerciseTemplate('Face pull', 'Ombros', 'Cabo'),

  // Bíceps
  ExerciseTemplate('Rosca direta barra', 'Bíceps', 'Barra'),
  ExerciseTemplate('Rosca direta halteres', 'Bíceps', 'Halteres'),
  ExerciseTemplate('Rosca martelo', 'Bíceps', 'Halteres'),
  ExerciseTemplate('Rosca concentrada', 'Bíceps', 'Halteres'),
  ExerciseTemplate('Rosca scott', 'Bíceps', 'Barra'),
  ExerciseTemplate('Rosca cabo', 'Bíceps', 'Cabo'),
  ExerciseTemplate('Rosca inversa', 'Bíceps', 'Barra'),

  // Tríceps
  ExerciseTemplate('Tríceps testa', 'Tríceps', 'Barra'),
  ExerciseTemplate('Tríceps pulley', 'Tríceps', 'Cabo'),
  ExerciseTemplate('Tríceps corda', 'Tríceps', 'Cabo'),
  ExerciseTemplate('Tríceps francês', 'Tríceps', 'Halteres'),
  ExerciseTemplate('Mergulho entre bancos', 'Tríceps', 'Peso corporal'),
  ExerciseTemplate('Kickback', 'Tríceps', 'Halteres'),
  ExerciseTemplate('Supino fechado', 'Tríceps', 'Barra'),

  // Pernas
  ExerciseTemplate('Agachamento livre', 'Pernas', 'Barra'),
  ExerciseTemplate('Agachamento hack', 'Pernas', 'Máquina'),
  ExerciseTemplate('Leg press 45°', 'Pernas', 'Máquina'),
  ExerciseTemplate('Leg press horizontal', 'Pernas', 'Máquina'),
  ExerciseTemplate('Cadeira extensora', 'Pernas', 'Máquina'),
  ExerciseTemplate('Cadeira flexora', 'Pernas', 'Máquina'),
  ExerciseTemplate('Mesa flexora', 'Pernas', 'Máquina'),
  ExerciseTemplate('Stiff', 'Pernas', 'Barra'),
  ExerciseTemplate('Avanço', 'Pernas', 'Halteres'),
  ExerciseTemplate('Panturrilha máquina', 'Pernas', 'Máquina'),
  ExerciseTemplate('Panturrilha leg press', 'Pernas', 'Máquina'),
  ExerciseTemplate('Abdutora', 'Pernas', 'Máquina'),
  ExerciseTemplate('Adutora', 'Pernas', 'Máquina'),
  ExerciseTemplate('Glúteo cabo', 'Glúteos', 'Cabo'),
  ExerciseTemplate('Hip thrust', 'Glúteos', 'Barra'),
  ExerciseTemplate('Elevação pélvica', 'Glúteos', 'Peso corporal'),

  // Abdômen
  ExerciseTemplate('Abdominal supra', 'Abdômen', 'Peso corporal'),
  ExerciseTemplate('Abdominal infra', 'Abdômen', 'Peso corporal'),
  ExerciseTemplate('Prancha', 'Abdômen', 'Peso corporal'),
  ExerciseTemplate('Abdominal máquina', 'Abdômen', 'Máquina'),
  ExerciseTemplate('Abdominal cabo', 'Abdômen', 'Cabo'),
  ExerciseTemplate('Oblíquo', 'Abdômen', 'Peso corporal'),
  ExerciseTemplate('Elevação de pernas', 'Abdômen', 'Peso corporal'),

  // Cardio
  ExerciseTemplate('Esteira', 'Cardio', 'Máquina'),
  ExerciseTemplate('Bicicleta ergométrica', 'Cardio', 'Máquina'),
  ExerciseTemplate('Elíptico', 'Cardio', 'Máquina'),
  ExerciseTemplate('Escada', 'Cardio', 'Máquina'),
  ExerciseTemplate('Corda naval', 'Cardio', 'Funcional'),
  ExerciseTemplate('Burpee', 'Cardio', 'Peso corporal'),
  ExerciseTemplate('Jump', 'Cardio', 'Peso corporal'),

  // Pilates
  ExerciseTemplate('Hundred', 'Pilates', 'Solo'),
  ExerciseTemplate('Roll up', 'Pilates', 'Solo'),
  ExerciseTemplate('Leg circle', 'Pilates', 'Solo'),
  ExerciseTemplate('Rolling like a ball', 'Pilates', 'Solo'),
  ExerciseTemplate('Single leg stretch', 'Pilates', 'Solo'),
  ExerciseTemplate('Double leg stretch', 'Pilates', 'Solo'),
  ExerciseTemplate('Spine stretch', 'Pilates', 'Solo'),
  ExerciseTemplate('Swan', 'Pilates', 'Solo'),
  ExerciseTemplate('Teaser', 'Pilates', 'Solo'),
  ExerciseTemplate('Side kick', 'Pilates', 'Solo'),
  ExerciseTemplate('Criss-cross', 'Pilates', 'Solo'),
  ExerciseTemplate('Spine twist', 'Pilates', 'Solo'),
  ExerciseTemplate('Reformer — Footwork', 'Pilates', 'Reformer'),
  ExerciseTemplate('Reformer — Short box', 'Pilates', 'Reformer'),
  ExerciseTemplate('Reformer — Long stretch', 'Pilates', 'Reformer'),
  ExerciseTemplate('Reformer — Elephant', 'Pilates', 'Reformer'),
  ExerciseTemplate('Reformer — Rowing', 'Pilates', 'Reformer'),
  ExerciseTemplate('Cadillac — Leg spring', 'Pilates', 'Cadillac'),
  ExerciseTemplate('Cadillac — Tower', 'Pilates', 'Cadillac'),
  ExerciseTemplate('Barrel — Side stretch', 'Pilates', 'Barrel'),
  ExerciseTemplate('Barrel — Back extension', 'Pilates', 'Barrel'),
  ExerciseTemplate('Chair — Seated pump', 'Pilates', 'Chair'),
];

const kMuscleGroups = ['Todos', 'Peito', 'Costas', 'Ombros', 'Bíceps', 'Tríceps', 'Pernas', 'Glúteos', 'Abdômen', 'Cardio', 'Pilates'];
