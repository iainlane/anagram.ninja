import 'dart:math' show asin, min, pi;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class CircleTextPainter extends CustomPainter {
  final String text;
  final TextStyle _textStyle;
  final TextPainter _textPainter;
  num _textPainterHeight;
  num _stretchAngle;

  CircleTextPainter({
    this.text,
    @required textStyle,
    @required double stretchAngle,
  })  : assert(textStyle != null, 'textStyle can' 't be null'),
        assert(stretchAngle != null, 'stretchAngle can' 't be null'),
        this._stretchAngle = stretchAngle,
        this._textStyle = textStyle,
        this._textPainter = TextPainter(textDirection: TextDirection.ltr) {
    _textPainter.text = TextSpan(text: text, style: textStyle);
    _textPainter.layout(minWidth: 0, maxWidth: double.maxFinite);

    _textPainterHeight = _textPainter.height;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final radius =
        (min(size.width, size.height) / 2);
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    _drawText(canvas, radius - _textPainterHeight, radius);
    canvas.restore();
  }

  double getFinalAngle(double radius) {
    double finalRotation = 0;
    text.runes.forEach((charCode) {
      _textPainter.text =
          TextSpan(text: String.fromCharCode(charCode), style: _textStyle);
      _textPainter.layout(minWidth: 0, maxWidth: double.maxFinite);
      finalRotation += _textPainter.alpha(radius);
    });
    return finalRotation;
  }

  void _drawText(Canvas canvas, double heightOffset, double radius) {
    // Each iteration we need to return to upright, so keep track of how far
    // we've rotated so far.
    if (text == null)
      return;

    final _interLetterAngle = text.runes.length > 1
        ? (_stretchAngle - getFinalAngle(radius)) / text.runes.length
        : 0;

    double rot = 0;
    text.runes.forEach((charCode) {
      // Set the TextPainter up to paint the current character
      _textPainter.text =
          TextSpan(text: String.fromCharCode(charCode), style: _textStyle);
      _textPainter.layout(minWidth: 0, maxWidth: double.maxFinite);

      final angle = _textPainter.alpha(radius);

      // Move to the edge
      canvas.save();
      canvas.translate(0, heightOffset);

      // Draw the text upright
      canvas.rotate(rot);

      // Move so that the centre of the letter is on our circumference
      canvas.translate(-_textPainter.width / 2, -_textPainter.height / 2);
      _textPainter.paint(canvas, Offset(0, 0));
      canvas.restore();

      // Get in place for the next letter
      canvas.rotate(angle + _interLetterAngle);
      rot -= angle + _interLetterAngle;
    });
  }

  @override
  bool shouldRepaint(CircleTextPainter oldDelegate) {
    return this.text != oldDelegate.text;
  }
}

extension Alpha on TextPainter {
  double alpha(double radius) {
    return 2 * asin(this.width / (2 * radius));
  }
}

class CircleText extends StatelessWidget {
  const CircleText({
    Key key,
    @required this.text,
    @required this.textStyle,
  })  : _fillAngle = 360 * pi / 180,
        super(key: key);

  /// Text to draw.
  final String text;

  /// TextStyle that will be applied to the text.
  final TextStyle textStyle;

  // Customisability: if we want to make it possible to fill in less than the
  // whole circle, expose fillAngle as a property
  final double _fillAngle;

  @override
  Widget build(BuildContext context) =>
      Flex(direction: Axis.vertical, children: [
        Expanded(
            child: CustomPaint(
          size: Size.infinite,
          painter: CircleTextPainter(
            text: text,
            textStyle: textStyle,
            stretchAngle: _fillAngle,
          ),
        ))
      ]);
}
