/// Foydalanuvchi custom dictionary yozuvi.
///
/// Latin yozuv va uning Kirill ekvivalenti. Barcha matnlar
/// aniq mos kelganda oddiy algoritmdan oldin almashtirish uchun ishlatiladi.
class DictionaryEntry {
  const DictionaryEntry({
    this.id,
    required this.latin,
    required this.cyrillic,
    required this.createdAt,
  });

  final int? id;
  final String latin;
  final String cyrillic;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'latin': latin,
        'cyrillic': cyrillic,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory DictionaryEntry.fromMap(Map<String, dynamic> map) {
    return DictionaryEntry(
      id: map['id'] as int?,
      latin: map['latin'] as String,
      cyrillic: map['cyrillic'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          map['created_at'] as int? ?? 0),
    );
  }

  DictionaryEntry copyWith({
    int? id,
    String? latin,
    String? cyrillic,
    DateTime? createdAt,
  }) {
    return DictionaryEntry(
      id: id ?? this.id,
      latin: latin ?? this.latin,
      cyrillic: cyrillic ?? this.cyrillic,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
