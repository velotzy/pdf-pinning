/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'dart:ui';
import 'dart:async';
import 'dart:ui' as UI;

import 'package:flutter/services.dart';

import 'package:document_measure/src/style/point_style.dart';
import 'package:flutter/material.dart' as material;

class MeasurePainter extends material.CustomPainter {
  final Offset start, end;
  final PointStyle style;
  final Paint dotPaint, pathPaint;

  final bool isDrawPath;

  final Path _drawPath = Path();
  late double _dotRadius;

  UI.Image? markerImage;

  MeasurePainter(
      {required this.start,
      required this.end,
      required this.style,
      required this.dotPaint,
      required this.pathPaint,
      required this.isDrawPath}) {
    _dotRadius = style.dotRadius;

    var lineType = style.lineType;
    _drawPath.reset();
    _drawPath.moveTo(start.dx, start.dy);

    if (lineType is SolidLine) {
      _drawPath.lineTo(end.dx, end.dy);
    } else if (lineType is DashedLine) {
      var distance = (end - start).distance;

      var solidOffset = (end - start) * lineType.dashLength / distance;
      var emptyOffset = (end - start) * lineType.dashDistance / distance;
      var currentPosition = start;

      var numLines =
          (distance / (lineType.dashLength + lineType.dashDistance)).floor();

      for (var i = 0; i < numLines; i++) {
        currentPosition += solidOffset;
        _drawPath.lineTo(currentPosition.dx, currentPosition.dy);
        currentPosition += emptyOffset;
        _drawPath.moveTo(currentPosition.dx, currentPosition.dy);
      }

      currentPosition += solidOffset;

      if ((currentPosition - start).distance > distance) {
        _drawPath.lineTo(end.dx, end.dy);
      } else {
        _drawPath.lineTo(currentPosition.dx, currentPosition.dy);
      }
    } else {
      throw UnimplementedError(
          'This line type is not supported! Type was: $style');
    }
  }

  loadUiImage(String imageAssetPath) {
    // final Completer<UI.Image> completer = Completer();
    rootBundle.load(imageAssetPath).then((data) =>
        UI.decodeImageFromList(Uint8List.view(data.buffer), (UI.Image img) {
          markerImage = img;
        }));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (markerImage == null) {
      loadUiImage('assets/images/pin_point.png');
    }

    if (markerImage != null) {
      canvas.drawImage(
          markerImage!, Offset(end.dx - 10, end.dy - 27), dotPaint);
      canvas.drawImage(
          markerImage!, Offset(start.dx - 10, start.dy - 27), dotPaint);
    } else {
      canvas.drawCircle(start, _dotRadius, dotPaint);
      canvas.drawCircle(end, _dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(material.CustomPainter oldDelegate) {
    var old = oldDelegate as MeasurePainter;

    return old.start != start || old.end != end || old.style != style;
  }
}
