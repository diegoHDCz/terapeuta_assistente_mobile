import 'package:flutter/material.dart';

/// Simple stand-in for the official multicolor Google "G" asset.
/// Swap for the branded SVG/PNG asset if strict brand guidelines are required.
class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: size * 0.85,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4285F4),
            height: 1,
          ),
        ),
      ),
    );
  }
}
