import 'package:flutter/material.dart';

class PasswordBoxes extends StatelessWidget {
  final String pin;

  const PasswordBoxes({super.key, required this.pin});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isFilled = index < pin.length;
        return Container(
          width: 48,
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: isFilled ? const Color(0xFFFF00FF) : Colors.white,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
            color: Colors.transparent,
          ),
          child: Center(
            child: Text(
              isFilled ? '*' : '',
              style: TextStyle(
                color: isFilled ? const Color(0xFFFF00FF) : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }
}

