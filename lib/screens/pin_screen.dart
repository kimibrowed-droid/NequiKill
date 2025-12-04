import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../widgets/loading_overlay.dart';
import '../widgets/password_boxes.dart';
import '../utils/nequi_alert.dart';
import 'home_screen.dart';

class PinScreen extends StatefulWidget {
  final String userPhone;
  
  const PinScreen({super.key, required this.userPhone});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> with TickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();
  // final FirebaseFirestore _db = FirebaseFirestore.instance; // Comentado temporalmente
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  bool _isVerifying = false;
  bool _isNavigating = false;
  String _enteredPin = '';
  late AnimationController _loadingController;
  bool _showLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    // Verificar huella automáticamente si está disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFingerprint();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  Future<void> _checkFingerprint() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPhone = prefs.getString('biometric_phone');
      final isFingerprintEnabled = prefs.getBool('fingerprint_enabled') ?? false;
      
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      if (savedPhone == widget.userPhone && 
          isFingerprintEnabled && 
          isAvailable && 
          isDeviceSupported) {
        await Future.delayed(const Duration(milliseconds: 500));
        _showFingerprintAuthDialog();
      }
    } catch (e) {
      // Silently fail if biometrics not available
    }
  }

  void _addDigit(String digit) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += digit;
        _pinController.text = _enteredPin;
      });
      
      if (_enteredPin.length == 4) {
        _verifyPin(_enteredPin);
      }
    }
  }

  void _removeDigit() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _pinController.text = _enteredPin;
      });
    }
  }

  Future<bool> _isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.wifi ||
           connectivityResult == ConnectivityResult.mobile ||
           connectivityResult == ConnectivityResult.ethernet;
  }

  Future<void> _verifyPin(String pin) async {
    if (_isVerifying || _isNavigating) return;
    
    setState(() {
      _isVerifying = true;
      _showLoading = true;
    });
    
    _loadingController.repeat();
    
    try {
      // Verificar conectividad
      if (!await _isOnline()) {
        setState(() {
          _isVerifying = false;
          _showLoading = false;
        });
        _loadingController.stop();
        NequiAlert.showError(context, 'Sin conexión a Wi‑Fi');
        _clearPin();
        return;
      }
      
      // Buscar usuario por teléfono
      // final phoneDigits = widget.userPhone.replaceAll(RegExp(r'[^\d]'), '');
      
      // Modo demo - acepta cualquier PIN de 4 dígitos
      if (pin.length != 4) {
        setState(() {
          _isVerifying = false;
          _showLoading = false;
        });
        _loadingController.stop();
        NequiAlert.showError(context, 'PIN debe tener 4 dígitos');
        _clearPin();
        return;
      }
      
      // Firebase comentado temporalmente
      // final query = await _db.collection('users')
      //     .where('telefono', isEqualTo: phoneDigits)
      //     .limit(1)
      //     .get();
      // 
      // if (query.docs.isEmpty) {
      //   setState(() {
      //     _isVerifying = false;
      //     _showLoading = false;
      //   });
      //   _loadingController.stop();
      //   NequiAlert.showError(context, 'Usuario no encontrado');
      //   _clearPin();
      //   return;
      // }
      // 
      // final doc = query.docs.first;
      // final storedPin = doc.data()['pin'] as String? ?? '';
      // 
      // if (storedPin != pin) {
      //   setState(() {
      //     _isVerifying = false;
      //     _showLoading = false;
      //   });
      //   _loadingController.stop();
      //   NequiAlert.showError(context, 'Clave incorrecta Contactame @Sangre_binerojs');
      //   _clearPin();
      //   return;
      // }
      
      // PIN correcto - navegar a Home
      setState(() {
        _isVerifying = false;
        _isNavigating = true;
      });
      
      await Future.delayed(const Duration(seconds: 3));
      
      if (mounted) {
        _loadingController.stop();
        Navigator.of(context).pushReplacementNamed(
          '/home',
          arguments: {'userPhone': widget.userPhone},
        );
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _showLoading = false;
      });
      _loadingController.stop();
      NequiAlert.showError(context, 'Ocurrió un error. Intenta de nuevo');
      _clearPin();
    }
  }

  void _clearPin() {
    setState(() {
      _enteredPin = '';
      _pinController.clear();
    });
  }

  void _showFingerprintAuthDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _FingerprintAuthDialog(
        userPhone: widget.userPhone,
        onSuccess: () {
          Navigator.of(context).pop();
          setState(() {
            _showLoading = true;
          });
          _loadingController.repeat();
          Future.delayed(const Duration(seconds: 3)).then((_) {
            if (mounted) {
              _loadingController.stop();
              Navigator.of(context).pushReplacementNamed(
                '/home',
                arguments: {'userPhone': widget.userPhone},
              );
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF200020),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Back arrow and title
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Ingrese su PIN de seguridad',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Password boxes
                PasswordBoxes(pin: _enteredPin),
                
                const SizedBox(height: 60),
                
                // Keypad
                Expanded(
                  child: _buildKeypad(),
                ),
                
                // Forgot password
                TextButton(
                  onPressed: _showForgotPinSheet,
                  child: const Text(
                    'Olvidé mi clave',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
            
            // Loading overlay
            if (_showLoading)
              LoadingOverlay(controller: _loadingController),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Row 1-3
          for (int row = 0; row < 3; row++)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int col = 1; col <= 3; col++)
                  _buildKeypadButton('${row * 3 + col}'),
              ],
            ),
          
          const SizedBox(height: 20),
          
          // Row 4: Delete, 0, Fingerprint
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeypadButton('', icon: Icons.fingerprint, onTap: _showFingerprintAuthDialog),
              _buildKeypadButton('0'),
              _buildKeypadButton('', icon: Icons.backspace, onTap: _removeDigit),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(String digit, {IconData? icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: () {
        if (icon != null && onTap != null) {
          onTap();
        } else {
          _addDigit(digit);
        }
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: Colors.white, size: 28)
              : Text(
                  digit,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  void _showForgotPinSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¿Olvidaste tu PIN?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Contacta con soporte a través de Telegram',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Abrir Telegram
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0088CC),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Abrir Telegram'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FingerprintAuthDialog extends StatefulWidget {
  final String userPhone;
  final VoidCallback onSuccess;

  const _FingerprintAuthDialog({
    required this.userPhone,
    required this.onSuccess,
  });

  @override
  State<_FingerprintAuthDialog> createState() => _FingerprintAuthDialogState();
}

class _FingerprintAuthDialogState extends State<_FingerprintAuthDialog> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    setState(() => _isAuthenticating = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPhone = prefs.getString('biometric_phone');
      
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Autentícate con tu huella',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      
      if (didAuthenticate && savedPhone == widget.userPhone) {
        if (mounted) {
          setState(() => _isAuthenticating = false);
          widget.onSuccess();
        }
      } else {
        if (mounted) {
          setState(() => _isAuthenticating = false);
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAuthenticating = false);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _isAuthenticating 
                    ? const Color(0xFF26A69A) 
                    : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isAuthenticating ? Icons.check : Icons.fingerprint,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isAuthenticating 
                  ? 'Reconocido de huella dactilar'
                  : 'Coloca tu huella',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}

