/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'dart:math';
import 'dart:ui';

import 'package:document_measure/document_measure.dart';
import 'package:flutter/material.dart' as material;

class SizePainter extends material.CustomPainter {
  static final double _log10 = log(10);
  static final double _offsetPerDigit = 4.57;

  final LengthUnit distance;
  final Offset viewCenter;

  late Offset _zeroPoint;
  final Offset _zeroPointWithoutTolerance = Offset(-29, 0);
  final Offset _zeroPointWithTolerance = Offset(-47, 0);

  late Paragraph _paragraph;

  late Offset _position;

  ParagraphBuilder paragraphBuilder = ParagraphBuilder(
    ParagraphStyle(
      textAlign: TextAlign.center,
      // textDirection: TextDirection.ltr,
      maxLines: 1,
      height: 0.5,
      fontSize: 10,
      fontStyle: FontStyle.normal,
    ),
  );

  SizePainter(
      {required Offset start,
      required Offset end,
      required this.distance,
      required this.viewCenter,
      required double tolerance,
      required DistanceStyle style}) {
    if (style.showTolerance) {
      _zeroPoint = _zeroPointWithTolerance;
    } else {
      _zeroPoint = _zeroPointWithoutTolerance;
    }

    var areaValue = distance.value;
    areaValue = ((start.dx - end.dx).abs() * (start.dy - end.dy).abs() ) * 0.2857142857;

    paragraphBuilder.pushStyle(TextStyle(color: style.textColor));

    paragraphBuilder.addText(
        '${areaValue.toStringAsFixed(style.numDecimalPlaces)}${distance.getAbbreviation()}');

    _paragraph = paragraphBuilder.build();
    _paragraph.layout(ParagraphConstraints(width: (start.dx - end.dx).abs()));
    _position = Offset(
        ((start.dx - end.dx).abs() / 2) + start.dx > end.dx ? end.dx : start.dx,
        start.dy > end.dy
            ? end.dy + ((start.dy - end.dy).abs() / 2)
            : start.dy + ((start.dy - end.dy).abs() / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    // canvas.translate(_position.dx, _position.dy);
    // canvas.rotate(_radians);

    canvas.drawParagraph(_paragraph, _position);
  }

  @override
  bool shouldRepaint(material.CustomPainter oldDelegate) {
    var old = oldDelegate as SizePainter;

    return distance != old.distance || _position != old._position;
  }
}

extension OffsetExtension on Offset {
  Offset normal() {
    var normalized = normalize();
    return Offset(-normalized.dy, normalized.dx);
  }

  Offset normalize() {
    return this / distance;
  }

  double cosAlpha(Offset other) {
    var thisNormalized = normalize();
    var otherNormalized = other.normalize();

    return thisNormalized.dx * otherNormalized.dx +
        thisNormalized.dy * otherNormalized.dy;
  }
}
