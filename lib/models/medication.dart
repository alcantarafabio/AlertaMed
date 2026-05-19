class Medication {
  final int? id;
  final String name;
  final String dosage;
  final String schedule;
  final String notes;

  const Medication({
    this.id,
    required this.name,
    required this.dosage,
    required this.schedule,
    this.notes = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'schedule': schedule,
        'notes': notes,
      };

  factory Medication.fromMap(Map<String, dynamic> map) => Medication(
        id: map['id'] as int?,
        name: map['name'] as String,
        dosage: map['dosage'] as String,
        schedule: map['schedule'] as String,
        notes: (map['notes'] as String?) ?? '',
      );
}
