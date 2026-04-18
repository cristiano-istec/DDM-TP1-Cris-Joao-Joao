import 'package:flutter/material.dart';

class NeonCard extends StatelessWidget {
  final Widget child;

  const NeonCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FFC6).withOpacity(0.3),
            blurRadius: 20,
          )
        ],
      ),
      child: child,
    );
  }
}