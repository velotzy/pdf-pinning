/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'dart:math';
import 'dart:ui';

import 'package:document_measure/document_measure.dart';
import 'package:flutter/material.dart' as material;

class SizePainter extends material.CustomPainter {
  static final double _log10 = log(10);
  static final double _offsetPerDigit = 4.57;

  // final LengthUnit distance;
  final Offset viewCenter;

  late Offset _zeroPoint;
  final Offset _zeroPointWithoutTolerance = Offset(-29, 0);
  final Offset _zeroPointWithTolerance = Offset(-47, 0);

  late Paragraph _paragraph;
  late double _radians;
  late Offset _position;

  ParagraphBuilder paragraphBuilder = ParagraphBuilder(
    ParagraphStyle(
      textAlign: TextAlign.center,
      maxLines: 1,
      height: 0.5,
      fontStyle: FontStyle.normal,
    ),
  );

  SizePainter(
      {required Offset start,
      required Offset end,
      // required this.distance,
      required this.viewCenter,
      required double tolerance,
      required DistanceStyle style}) {
    if (style.showTolerance) {
      _zeroPoint = _zeroPointWithTolerance;
    } else {
      _zeroPoint = _zeroPointWithoutTolerance;
    }

    // var distanceValue = distance.value;

    // if (distanceValue > 0) {
    //   _zeroPoint -= Offset(
    //       ((log(distanceValue) / _log10).floor() - 1) * _offsetPerDigit, 0);
    // }

    double width = (end.dx - start.dx).abs();
    double height = (end.dy - start.dy).abs();

    

    var sizeValue = width * height;

    var difference = end - start;
    _position = start + difference / 2.0;
    // _radians = difference.direction;

    // if (_radians.abs() >= pi / 2.0) {
    //   _radians += pi;
    // }

    var positionToCenter = viewCenter - _position;

    var offset = difference.normal();
    offset *= offset.cosAlpha(positionToCenter).sign;

    paragraphBuilder.pushStyle(TextStyle(color: style.textColor));
    // if (style.showTolerance) {
    //   paragraphBuilder.addText(
    //       '${distanceValue?.toStringAsFixed(style.numDecimalPlaces)}±${tolerance.toStringAsFixed(style.numDecimalPlaces)}${distance.getAbbreviation()}');
    // } else {
    //   paragraphBuilder.addText(
    //       '${distanceValue?.toStringAsFixed(style.numDecimalPlaces)}${distance.getAbbreviation()}');
    // }



    paragraphBuilder.addText('${sizeValue.toStringAsFixed(style.numDecimalPlaces)}');

    _paragraph = paragraphBuilder.build();
    _paragraph.layout(ParagraphConstraints(width: width));

    _position += offset * 12;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(_position.dx, _position.dy);
    // canvas.rotate(_radians);

    canvas.drawParagraph(_paragraph, _zeroPoint);
  }

  @override
  bool shouldRepaint(material.CustomPainter oldDelegate) {
    var old = oldDelegate as SizePainter;

    return _position != old._position;
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
