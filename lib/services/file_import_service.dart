import 'dart:io';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';

/// Tashqi fayldan matn import qilish servisi: `.txt` va `.docx`.
class FileImportService {
  FileImportService._();

  static const int maxBytes = 5 * 1024 * 1024; // 5 MB
  static const int maxChars = 100000;

  /// Foydalanuvchidan fayl tanlab, matnni qaytaradi.
  ///
  /// Natija turi:
  /// - `FileImportResult(text: ...)` — muvaffaqiyat.
  /// - `FileImportResult(error: ...)` — xato (juda katta, qo'llab-quvvatlanmaydigan format, yoki parse xatosi).
  /// - `FileImportResult.cancelled()` — foydalanuvchi bekor qildi.
  static Future<FileImportResult> pickAndReadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'docx'],
        withData: false,
      );
      if (result == null || result.files.isEmpty) {
        return FileImportResult.cancelled();
      }

      final platformFile = result.files.first;
      final path = platformFile.path;
      if (path == null) {
        return FileImportResult.error(
            'Fayl yo\'lini olib bo\'lmadi');
      }

      final file = File(path);
      final size = await file.length();
      if (size > maxBytes) {
        return FileImportResult.error(
            'Fayl juda katta (max 5 MB)');
      }

      final ext = platformFile.extension?.toLowerCase();
      String text;
      if (ext == 'txt') {
        text = await file.readAsString();
      } else if (ext == 'docx') {
        text = await _extractDocxText(file);
      } else {
        return FileImportResult.error(
            'Faqat .txt va .docx qo\'llab-quvvatlanadi');
      }

      if (text.length > maxChars) {
        text = text.substring(0, maxChars);
      }

      return FileImportResult(text: text);
    } catch (e) {
      debugPrint('FileImportService: $e');
      return FileImportResult.error('Fayl o\'qishda xatolik');
    }
  }

  /// `.docx` fayli = ZIP + `word/document.xml`. `<w:t>` elementlardan matnni chiqarib olamiz.
  static Future<String> _extractDocxText(File file) async {
    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final doc = archive.findFile('word/document.xml');
    if (doc == null) {
      throw const FormatException('Noto\'g\'ri .docx fayl: document.xml yo\'q');
    }
    final xml = XmlDocument.parse(String.fromCharCodes(doc.content as List<int>));
    final buffer = StringBuffer();
    for (final paragraph in xml.findAllElements('w:p')) {
      final texts = paragraph.findAllElements('w:t');
      for (final t in texts) {
        buffer.write(t.innerText);
      }
      buffer.writeln();
    }
    return buffer.toString().trim();
  }
}

class FileImportResult {
  const FileImportResult._({this.text, this.errorMessage});

  factory FileImportResult({required String text}) =>
      FileImportResult._(text: text);

  factory FileImportResult.error(String message) =>
      FileImportResult._(errorMessage: message);

  factory FileImportResult.cancelled() => const FileImportResult._();

  final String? text;
  final String? errorMessage;

  bool get isSuccess => text != null;
  bool get isError => errorMessage != null;
  bool get isCancelled => text == null && errorMessage == null;
}
