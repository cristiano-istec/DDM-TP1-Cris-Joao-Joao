import 'package:flutter/material.dart';

class NeonCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const NeonCircleButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: color,
        shape: const CircleBorder(),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
          )
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black),
        onPressed: onPressed,
      ),
    );
  }
}