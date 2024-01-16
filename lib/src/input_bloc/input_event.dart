/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'dart:ui';

import 'package:equatable/equatable.dart';

abstract class InputEvent extends Equatable {
  final Offset position;
  final bool isPerimeter;

  InputEvent(this.position, this.isPerimeter);

  @override
  List<Object> get props => [position];

  @override
  String toString() {
    return super.toString() + ' position: $position';
  }
}

class InputDownEvent extends InputEvent {
  InputDownEvent(Offset position, bool isPerimeter) : super(position, isPerimeter);
}

class InputMoveEvent extends InputEvent {
  InputMoveEvent(Offset position, bool isPerimeter) : super(position, isPerimeter);
}

class InputUpEvent extends InputEvent {
  InputUpEvent(Offset position, bool isPerimeter) : super(position, isPerimeter);
}
