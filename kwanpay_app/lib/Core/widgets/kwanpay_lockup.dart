import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_copy.dart';

class KwanPayMark extends StatelessWidget {
  final double size;

  const KwanPayMark({
    super.key,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.markTile,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: CustomPaint(
        painter: _KwanPayMarkPainter(),
      ),
    );
  }
}

class _KwanPayMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.085
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.24, size.height * 0.78)
      ..cubicTo(
        size.width * 0.30,
        size.height * 0.50,
        size.width * 0.46,
        size.height * 0.58,
        size.width * 0.52,
        size.height * 0.40,
      )
      ..cubicTo(
        size.width * 0.58,
        size.height * 0.24,
        size.width * 0.68,
        size.height * 0.24,
        size.width * 0.74,
        size.height * 0.24,
      );

    canvas.drawPath(path, stroke);

    final startDot = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.24, size.height * 0.78),
      size.width * 0.07,
      startDot,
    );

    final ring = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.055;
    canvas.drawCircle(
      Offset(size.width * 0.74, size.height * 0.24),
      size.width * 0.09,
      ring,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class KwanPayWordmark extends StatelessWidget {
  final double fontSize;
  final bool onDark;

  const KwanPayWordmark({
    super.key,
    this.fontSize = 36,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final kwanColor = onDark ? Colors.white : AppColors.primary;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Kwan',
            style: TextStyle(color: kwanColor),
          ),
          const TextSpan(
            text: 'Pay',
            style: TextStyle(color: AppColors.accent),
          ),
        ],
      ),
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -0.4,
      ),
    );
  }
}

class KwanPayLockup extends StatelessWidget {
  final bool onDark;
  final bool showTagline;
  final double markSize;
  final double wordmarkSize;
  final Axis axis;

  const KwanPayLockup({
    super.key,
    this.onDark = false,
    this.showTagline = true,
    this.markSize = 72,
    this.wordmarkSize = 36,
    this.axis = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    final wordmarkAndTagline = Column(
      crossAxisAlignment: axis == Axis.vertical
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        KwanPayWordmark(
          fontSize: wordmarkSize,
          onDark: onDark,
        ),
        if (showTagline) ...[
          const SizedBox(height: 8),
          Text(
            AppCopy.tagline,
            textAlign: axis == Axis.vertical
                ? TextAlign.center
                : TextAlign.start,
            style: TextStyle(
              fontSize: wordmarkSize * 0.38,
              fontWeight: FontWeight.w500,
              color: AppColors.accent,
              height: 1.3,
            ),
          ),
        ],
      ],
    );

    if (axis == Axis.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          KwanPayMark(size: markSize),
          const SizedBox(width: 16),
          wordmarkAndTagline,
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        KwanPayMark(size: markSize),
        const SizedBox(height: 20),
        wordmarkAndTagline,
      ],
    );
  }
}
