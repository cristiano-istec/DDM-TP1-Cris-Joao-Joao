import 'package:flutter/material.dart';

class NeonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const NeonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = const Color(0xFF00FFC6),
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.black,
        shadowColor: color,
        elevation: 10,
        padding: const EdgeInsets.all(14),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}