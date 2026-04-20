import 'dart:convert';
import 'dart:math';

class ConversionRecord {
  final String id;
  final String inputText;
  final String outputText;
  final bool isLatinToCyrillic;
  final DateTime createdAt;
  final bool isFavorite;

  ConversionRecord({
    required this.id,
    required this.inputText,
    required this.outputText,
    required this.isLatinToCyrillic,
    required this.createdAt,
    this.isFavorite = false,
  });

  factory ConversionRecord.create({
    required String inputText,
    required String outputText,
    required bool isLatinToCyrillic,
  }) {
    return ConversionRecord(
      id: '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9000) + 1000}',
      inputText: inputText,
      outputText: outputText,
      isLatinToCyrillic: isLatinToCyrillic,
      createdAt: DateTime.now(),
    );
  }

  ConversionRecord copyWith({
    String? id,
    String? inputText,
    String? outputText,
    bool? isLatinToCyrillic,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return ConversionRecord(
      id: id ?? this.id,
      inputText: inputText ?? this.inputText,
      outputText: outputText ?? this.outputText,
      isLatinToCyrillic: isLatinToCyrillic ?? this.isLatinToCyrillic,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversionRecord &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inputText': inputText,
      'outputText': outputText,
      'isLatinToCyrillic': isLatinToCyrillic,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  factory ConversionRecord.fromJson(Map<String, dynamic> json) {
    return ConversionRecord(
      id: json['id'] as String,
      inputText: json['inputText'] as String,
      outputText: json['outputText'] as String,
      isLatinToCyrillic: json['isLatinToCyrillic'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory ConversionRecord.fromJsonString(String jsonString) {
    return ConversionRecord.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }
}
