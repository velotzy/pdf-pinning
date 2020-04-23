import 'dart:ui' as ui;

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

abstract class MetadataEvent extends Equatable {
}

class MetadataOrientationEvent extends MetadataEvent {
  final Orientation orientation;

  MetadataOrientationEvent(this.orientation);

  @override
  List<Object> get props => [orientation];

  @override
  String toString() {
    return super.toString() + " orientation: $orientation";
  }
}

class MetadataBackgroundEvent extends MetadataEvent {
  final ui.Image backgroundImage;
  final Size size;

  MetadataBackgroundEvent(this.backgroundImage, this.size);

  @override
  List<Object> get props => [backgroundImage, size];


  @override
  String toString() {
    return super.toString() + " size: $size -- backgroundImage: $backgroundImage";
  }
}

class MetadataStartedEvent extends MetadataEvent {
  final Size documentSize;
  final Function(List<double>) callback;
  final double scale;
  final double zoom;
  final bool measure;
  final bool showDistances;
  final Color lineColor;

  MetadataStartedEvent(this.documentSize, this.callback, this.scale, this.zoom, this.measure, this.showDistances, this.lineColor);

  @override
  List<Object> get props => [documentSize, callback, scale, zoom, measure, showDistances, lineColor];

  @override
  String toString() {
    return super.toString() + " documentSize: $documentSize -- scale: $scale -- zoom: $zoom -- measure: $measure -- showDistances: $showDistances";
  }
}

class MetadataUpdatedEvent extends MetadataEvent {
  final bool measure;

  MetadataUpdatedEvent(this.measure);

  @override
  List<Object> get props => [measure];

  @override
  String toString() {
    return super.toString() + " measure: $measure";
  }
}