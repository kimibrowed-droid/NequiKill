import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class AssetLoader {
  // Clave simple de ofuscación (puedes cambiarla)
  static const String _key = 'NequiKill2024Secret';
  
  // Cargar y desencriptar asset
  static Future<String> loadEncryptedAsset(String path) async {
    try {
      final ByteData data = await rootBundle.load(path);
      final Uint8List bytes = data.buffer.asUint8List();
      return _decrypt(bytes);
    } catch (e) {
      // Si falla, intentar cargar normal (para desarrollo)
      return await rootBundle.loadString(path);
    }
  }
  
  // Desencriptar usando XOR simple
  static String _decrypt(Uint8List encrypted) {
    final keyBytes = utf8.encode(_key);
    final decrypted = Uint8List(encrypted.length);
    
    for (int i = 0; i < encrypted.length; i++) {
      decrypted[i] = encrypted[i] ^ keyBytes[i % keyBytes.length];
    }
    
    return utf8.decode(decrypted);
  }
  
  // Encriptar (para generar los assets encriptados)
  static Uint8List encrypt(String content) {
    final contentBytes = utf8.encode(content);
    final keyBytes = utf8.encode(_key);
    final encrypted = Uint8List(contentBytes.length);
    
    for (int i = 0; i < contentBytes.length; i++) {
      encrypted[i] = contentBytes[i] ^ keyBytes[i % keyBytes.length];
    }
    
    return encrypted;
  }
}
