import 'package:flutter/material.dart';

class MagnitudeBadge extends StatelessWidget {
  final double magnitude;

  const MagnitudeBadge({
    super.key,
    required this.magnitude,
  });

  Color _getBadgeColor() {
    if (magnitude < 4.0) {
      return Colors.green.shade600;
    } else if (magnitude < 6.0) {
      return Colors.orange.shade600;
    } else {
      return Colors.red.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getBadgeColor(),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        magnitude.toStringAsFixed(1),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }
}
