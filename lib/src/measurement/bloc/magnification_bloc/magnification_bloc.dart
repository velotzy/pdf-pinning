/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:document_measure/src/input_bloc/input_bloc.dart';
import 'package:document_measure/src/input_bloc/input_state.dart';
import 'package:document_measure/src/measurement/repository/measurement_repository.dart';
import 'package:document_measure/src/metadata/repository/metadata_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'magnification_event.dart';
import 'magnification_state.dart';

class MagnificationBloc extends Bloc<MagnificationEvent, MagnificationState> {
  final _defaultMagnificationOffset = Offset(0, 40);
  final InputBloc inputBloc;
  final List<StreamSubscription> _streamSubscriptions = [];

  late MeasurementRepository _measureRepository;
  late MetadataRepository _metadataRepository;

  ui.Image? _backgroundImage ;
  late double _imageScaleFactor;
  Size _viewSize = Size.zero;
  late double _magnificationRadius;
  late Offset _magnificationOffset;

  MagnificationBloc(this.inputBloc) : super(MagnificationInactiveState()) {
    _measureRepository = GetIt.I<MeasurementRepository>();
    _metadataRepository = GetIt.I<MetadataRepository>();

    on<MagnificationEvent>(mapEventToState);

    _streamSubscriptions.add(_metadataRepository.backgroundImage
        .listen((image) => _backgroundImage = image));
    _streamSubscriptions.add(_metadataRepository.imageScaleFactor
        .listen((factor) => _imageScaleFactor = factor));
    _streamSubscriptions
        .add(_metadataRepository.viewSize.listen((size) => _viewSize = size));
    _streamSubscriptions
        .add(_metadataRepository.magnificationCircleRadius.listen((radius) {
      _magnificationRadius = radius;
      _magnificationOffset = Offset(_defaultMagnificationOffset.dx,
          _defaultMagnificationOffset.dy + radius);
    }));

    
    _streamSubscriptions.add(inputBloc.stream.listen((state) {
      if (state is InputStandardState) {
        add(MagnificationShowEvent(state.position));
      } else if (state is InputEmptyState) {
        add(MagnificationHideEvent());
      } else if (state is InputDeleteRegionState) {
        add(MagnificationHideEvent());
      } else if (state is InputEndedState) {
        add(MagnificationHideEvent());
      } else if (state is InputDeleteState) {
        add(MagnificationHideEvent());
      }
    }));
  }

  
  Stream<Transition<MagnificationEvent, MagnificationState>>
      transformTransitions(
          Stream<Transition<MagnificationEvent, MagnificationState>>
              transitions) {
    return transitions
        .map((Transition<MagnificationEvent, MagnificationState> transition) {
      final state = transition.nextState;
      if (state is MagnificationActiveState) {
        return Transition(
            currentState: transition.currentState,
            event: transition.event,
            nextState: MagnificationActiveState(
              state.position,
              state.magnificationOffset,
              absolutePosition: _measureRepository
                  .convertIntoDocumentLocalTopLeftPosition(state.position),
              backgroundImage: _backgroundImage!,
              imageScaleFactor: _imageScaleFactor,
            ));
      } else {
        return transition;
      }
    });
  }

  
  Future<void> mapEventToState(
      MagnificationEvent event,
      Emitter<MagnificationState> emit,
  ) async {
    if (event is MagnificationShowEvent) {
      emit( _mapMagnificationShowToState(event));
    } else if (event is MagnificationHideEvent) {
      emit( MagnificationInactiveState());
    }
  }

  @override
  Future<void> close() {
    _streamSubscriptions.forEach((subscription) => subscription.cancel());
    return super.close();
  }

  MagnificationState _mapMagnificationShowToState(
      MagnificationShowEvent event) {
    var magnificationPosition = event.position - _magnificationOffset;

    if (_magnificationGlassFitsWithoutModification(magnificationPosition)) {
      return MagnificationActiveState(event.position, _magnificationOffset, backgroundImage: _backgroundImage!);
    } else {
      var modifiedOffset = _magnificationOffset;

      if (event.position.dy < _magnificationOffset.dy + _magnificationRadius) {
        modifiedOffset = Offset(modifiedOffset.dx, -modifiedOffset.dy);
      }

      if (event.position.dx < _magnificationRadius) {
        modifiedOffset =
            Offset(event.position.dx - _magnificationRadius, modifiedOffset.dy);
      } else if (event.position.dx > _viewSize.width - _magnificationRadius) {
        modifiedOffset = Offset(
            _magnificationRadius - (_viewSize.width - event.position.dx),
            modifiedOffset.dy);
      }

      return MagnificationActiveState(event.position, modifiedOffset, backgroundImage: _backgroundImage!);
    }
  }

  bool _magnificationGlassFitsWithoutModification(
          Offset magnificationPosition) =>
      magnificationPosition >
          Offset(_magnificationRadius, _magnificationRadius) &&
      magnificationPosition <
          Offset(_viewSize.width - _magnificationRadius,
              _viewSize.height - _magnificationRadius);
}
