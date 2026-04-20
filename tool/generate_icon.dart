// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

void main() {
  const size = 1024;
  final image = img.Image(width: size, height: size);

  // Ko'k fon (#0068B7)
  img.fill(image, color: img.ColorRgb8(0, 104, 183));

  // Oddiy "Uz" yozuvini oq rangda markazga joylash
  // image paketi bilan matn yozish
  img.drawString(
    image,
    'Uz',
    font: img.arial48,
    x: size ~/ 2 - 48,
    y: size ~/ 2 - 24,
    color: img.ColorRgb8(255, 255, 255),
  );

  // Faylga saqlash
  final pngBytes = img.encodePng(image);
  File('assets/icon/app_icon.png').writeAsBytesSync(pngBytes);
  print('App icon yaratildi: assets/icon/app_icon.png');
}
