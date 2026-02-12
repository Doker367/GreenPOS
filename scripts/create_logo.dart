import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  // Crear imagen de 1024x1024 con fondo oscuro
  final image = img.Image(width: 1024, height: 1024);
  
  // Fondo oscuro (#1A1F2E)
  img.fill(image, color: img.ColorRgb8(26, 31, 46));
  
  // Color verde del gradiente (#00C853 y #6AFF7B mezclados)
  final green1 = img.ColorRgb8(0, 200, 83);
  final green2 = img.ColorRgb8(106, 255, 123);
  
  // Crear forma "G" grande (outer RRect)
  for (var y = 50; y < 800; y++) {
    for (var x = 0; x < 1024; x++) {
      // Forma aproximada de letra G con ticket
      if (_inGShape(x, y, 1024)) {
        // Gradiente simple
        final t = y / 800.0;
        final r = (green1.r * (1 - t) + green2.r * t).round();
        final g = (green1.g * (1 - t) + green2.g * t).round();
        final b = (green1.b * (1 - t) + green2.b * t).round();
        image.setPixel(x, y, img.ColorRgb8(r, g, b));
      }
    }
  }
  
  // Ticket oscuro (parte inferior)
  for (var y = 600; y < 920; y++) {
    for (var x = 460; x < 788; x++) {
      if (_inTicketShape(x, y)) {
        image.setPixel(x, y, img.ColorRgb8(0, 52, 31)); // Verde oscuro
      }
    }
  }
  
  // Líneas verdes brillantes en el ticket
  for (var x = 480; x < 750; x++) {
    image.setPixel(x, 680, img.ColorRgb8(0, 234, 114));
    image.setPixel(x, 681, img.ColorRgb8(0, 234, 114));
    image.setPixel(x, 682, img.ColorRgb8(0, 234, 114));
    
    if (x < 600) {
      image.setPixel(x, 760, img.ColorRgb8(0, 234, 114));
      image.setPixel(x, 761, img.ColorRgb8(0, 234, 114));
      image.setPixel(x, 762, img.ColorRgb8(0, 234, 114));
    }
  }
  
  // Guardar
  final png = img.encodePng(image);
  await File('assets/icons/logo.png').writeAsBytes(png);
  print('✓ Logo generado: assets/icons/logo.png');
}

bool _inGShape(int x, int y, int size) {
  // Rectángulo redondeado grande (outer)
  if (x < 0 || x > size || y < 50 || y > 800) return false;
  
  // Corte interno (inner cut) - aproximado
  if (x > 340 && x < 820 && y > 270 && y < 630) {
    return false;
  }
  
  // Notch horizontal
  if (x > 420 && x < 800 && y > 430 && y < 590) {
    return true;
  }
  
  return x < 1024 && y > 50 && y < 800;
}

bool _inTicketShape(int x, int y) {
  return x > 460 && x < 788 && y > 600 && y < 880;
}
