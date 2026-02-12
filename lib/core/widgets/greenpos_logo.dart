import 'package:flutter/material.dart';

/// Logo recreado de GreenPOS usando dibujo vectorial en lienzo.
class GreenPosLogo extends StatelessWidget {
  final double size;

  const GreenPosLogo({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _GreenPosLogoPainter(),
    );
  }
}

class _GreenPosLogoPainter extends CustomPainter {
  const _GreenPosLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF6AFF7B), Color(0xFF00C853)],
    ).createShader(rect);

    final logoPaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;

    canvas.saveLayer(rect, Paint());

    final outer = RRect.fromRectXY(
      Rect.fromLTWH(0, size.height * 0.05, size.width, size.height * 0.75),
      size.width * 0.32,
      size.width * 0.32,
    );
    canvas.drawRRect(outer, logoPaint);

    final innerCut = RRect.fromRectXY(
      Rect.fromLTWH(
        size.width * 0.34,
        size.height * 0.27,
        size.width * 0.48,
        size.height * 0.36,
      ),
      size.width * 0.2,
      size.width * 0.2,
    );
    canvas.drawRRect(innerCut, Paint()..blendMode = BlendMode.clear);

    final notchPaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectXY(
        Rect.fromLTWH(
          size.width * 0.42,
          size.height * 0.43,
          size.width * 0.38,
          size.height * 0.16,
        ),
        size.width * 0.08,
        size.width * 0.08,
      ),
      notchPaint,
    );

    canvas.restore();

    final ticketPaint = Paint()
      ..color = const Color(0xFF00341F)
      ..style = PaintingStyle.fill;

    final ticketWidth = size.width * 0.32;
    final ticketHeight = size.height * 0.32;
    final ticketLeft = size.width * 0.45;
    final ticketTop = size.height * 0.58;

    final ticketPath = Path()
      ..addRRect(
        RRect.fromRectXY(
          Rect.fromLTWH(ticketLeft, ticketTop, ticketWidth, ticketHeight * 0.82),
          size.width * 0.06,
          size.width * 0.06,
        ),
      )
      ..moveTo(ticketLeft, ticketTop + ticketHeight * 0.82)
      ..lineTo(ticketLeft + ticketWidth * 0.25, ticketTop + ticketHeight)
      ..lineTo(ticketLeft + ticketWidth * 0.5, ticketTop + ticketHeight * 0.86)
      ..lineTo(ticketLeft + ticketWidth * 0.75, ticketTop + ticketHeight)
      ..lineTo(ticketLeft + ticketWidth, ticketTop + ticketHeight * 0.82)
      ..close();

    canvas.drawPath(ticketPath, ticketPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF00EA72)
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round;

    final lineStartY = ticketTop + ticketHeight * 0.25;
    final lineGap = size.width * 0.12;

    canvas.drawLine(
      Offset(ticketLeft + size.width * 0.05, lineStartY),
      Offset(ticketLeft + ticketWidth - size.width * 0.05, lineStartY),
      linePaint,
    );

    canvas.drawLine(
      Offset(ticketLeft + size.width * 0.05, lineStartY + lineGap),
      Offset(ticketLeft + ticketWidth * 0.7, lineStartY + lineGap),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
