import 'package:flutter/material.dart';

class KwanCard extends StatelessWidget {
  final Widget child;

  const KwanCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        boxShadow: [

          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),

        ],
      ),

      child: child,
    );
  }
}