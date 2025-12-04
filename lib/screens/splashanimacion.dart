import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'dart:typed_data';

class SplashAnimacion extends StatefulWidget {
  final VoidCallback? onAnimationComplete;

  const SplashAnimacion({
    Key? key,
    this.onAnimationComplete,
  }) : super(key: key);

  @override
  State<SplashAnimacion> createState() => _SplashAnimacionState();
}

class _SplashAnimacionState extends State<SplashAnimacion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isAnimationStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation(Duration duration) {
    if (!_isAnimationStarted) {
      _isAnimationStarted = true;
      // Reiniciar el controlador desde 0 para asegurar que la animación comience desde el inicio
      _controller.reset();
      _controller.duration = duration;
      _controller.forward().whenComplete(() {
        if (widget.onAnimationComplete != null) {
          widget.onAnimationComplete!();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 1.2,
          height: MediaQuery.of(context).size.height * 1.2,
          child: FutureBuilder<String>(
            future: rootBundle.loadString('assets/splash_animation.json'),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              return Lottie.memory(
                Uint8List.fromList(snapshot.data!.codeUnits),
                controller: _controller,
                onLoaded: (composition) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _startAnimation(composition.duration);
                  });
                },
                fit: BoxFit.contain,
                repeat: false,
              );
            },
          ),
        ),
      ),
    );
  }
}
