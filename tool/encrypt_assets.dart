import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

const String key = 'NequiKill2024Secret';

Uint8List encrypt(String content) {
  final contentBytes = utf8.encode(content);
  final keyBytes = utf8.encode(key);
  final encrypted = Uint8List(contentBytes.length);
  
  for (int i = 0; i < contentBytes.length; i++) {
    encrypted[i] = contentBytes[i] ^ keyBytes[i % keyBytes.length];
  }
  
  return encrypted;
}

void main() async {
  print('🔒 Encriptando assets...');
  
  // Encriptar splash_animation.json
  final splashFile = File('assets/splash_animation.json');
  if (await splashFile.exists()) {
    final content = await splashFile.readAsString();
    final encrypted = encrypt(content);
    await File('assets/splash_animation.enc').writeAsBytes(encrypted);
    print('✅ splash_animation.json encriptado');
  }
  
  // Encriptar SVGs
  final svgFiles = [
    'assets/images/nequi_logo.xml',
    'assets/images/by_bancolombia.xml',
    'assets/images/transfiya.xml',
  ];
  
  for (final path in svgFiles) {
    final file = File(path);
    if (await file.exists()) {
      final content = await file.readAsString();
      final encrypted = encrypt(content);
      final newPath = path.replaceAll('.xml', '.enc');
      await File(newPath).writeAsBytes(encrypted);
      print('✅ ${path.split('/').last} encriptado');
    }
  }
  
  print('🎉 Todos los assets encriptados!');
  print('⚠️  Ahora puedes eliminar los archivos originales (.json y .xml)');
}
