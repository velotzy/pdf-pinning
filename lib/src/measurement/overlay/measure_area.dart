/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
import 'dart:ui' as ui;
import 'package:document_measure/document_measure.dart';
import 'package:document_measure/src/measurement/bloc/magnification_bloc/magnification_bloc.dart';
import 'package:document_measure/src/measurement/bloc/magnification_bloc/magnification_state.dart';
import 'package:document_measure/src/measurement/bloc/points_bloc/points_bloc.dart';
import 'package:document_measure/src/measurement/bloc/points_bloc/points_state.dart';
import 'package:document_measure/src/measurement/overlay/painters/polygon_painter.dart';
import 'package:document_measure/src/measurement/overlay/painters/size_painter.dart';
import 'package:document_measure/src/measurement/repository/measurement_repository.dart';
import 'package:document_measure/src/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'painters/distance_painter.dart';
import 'painters/magnifying_painter.dart';
import 'painters/measure_painter.dart';

class MeasureArea extends StatelessWidget {
  final PointStyle pointStyle;
  final MagnificationStyle magnificationStyle;
  final DistanceStyle distanceStyle;
  final Paint dotPaint = Paint(), pathPaint = Paint();
  final measurementRepository = GetIt.I<MeasurementRepository>();

  MeasureArea(
      {required this.pointStyle,
      required this.magnificationStyle,
      required this.distanceStyle,
      }) {
    var lineType = pointStyle.lineType;
    double strokeWidth;
    if (lineType is SolidLine) {
      strokeWidth = lineType.lineWidth;
    } else if (lineType is DashedLine) {
      strokeWidth = lineType.dashWidth;
    } else {
      throw UnimplementedError(
          'This line type is not supported! Type was: $lineType');
    }

    dotPaint.color = pointStyle.dotColor;

    pathPaint
      ..style = PaintingStyle.stroke
      ..color = pointStyle.lineType.lineColor
      ..strokeWidth = strokeWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        BlocBuilder<PointsBloc, PointsState>(
          builder: (context, state) => _pointsOverlay(state),
        ),
        // BlocBuilder<MagnificationBloc, MagnificationState>(
        //   builder: (context, state) => _magnificationOverlay(state),
        // ),
      ],
    );
  }

  Stack _pointsOverlay(PointsState state) {
    
    var widgets = <Widget>[];

    if (state is PointsSingleState) {
      widgets.add(_pointPainter(state.point, state.point, false));
    } else if (state is PointsOnlyState) {
      widgets.addAll(_onlyPoints(state));
    // } else if (state is PointsAndDistanceActiveState ) {
    //   widgets.addAll(_pointsAndPolygonWithSpace(state));
    // } else if (state is PointsAndDistanceState) {
    //   widgets.addAll(_pointsAndPolygon(state));
    }

    return Stack(
      children: widgets.asMap().entries.map((entry) {
        
        // if (entry.key % 2 == 0) {
        //   return entry.value;
        // } else {
        //   return Container();
        // }
return entry.value;
        
      }).toList(),
    );
  }

  List<Widget> _onlyPoints(PointsOnlyState state) {
    var widgets = <Widget>[];

    state.points
        .doInBetween((start, end) => widgets.add(_pointPainter(start, end, false)));

    return widgets;
  }

  CustomPaint _pointPainter(dynamic first, dynamic last, bool isDrawPath ) {
    return CustomPaint(
      foregroundPainter: MeasurePainter(
        start: first,
        end: last,
        style: pointStyle,
        dotPaint: dotPaint,
        pathPaint: pathPaint,
        isDrawPath: isDrawPath
      ),
    );
  }

  Widget _magnificationOverlay(MagnificationState state) {
    if (state is MagnificationActiveState) {
      return CustomPaint(
        foregroundPainter: MagnifyingPainter(
          fingerPosition: state.position,
          absolutePosition: state.absolutePosition,
          image: state.backgroundImage,
          imageScaleFactor: state.imageScaleFactor,
          style: magnificationStyle,
          magnificationOffset: state.magnificationOffset,
        ),
      );
    }

    return Opacity(
      opacity: 0.0,
    );
  }
}
