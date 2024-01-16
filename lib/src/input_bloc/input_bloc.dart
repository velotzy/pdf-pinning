/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'dart:async';

import 'package:document_measure/src/measurement/repository/measurement_repository.dart';
import 'package:document_measure/src/metadata/repository/metadata_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'input_event.dart';
import 'input_state.dart';

class InputBloc extends Bloc<InputEvent, InputState> {
  final List<StreamSubscription> _streamSubscription = [];

  late MeasurementRepository _measurementRepository;
  late MetadataRepository _metadataRepository;
  
  bool _measure = false;
  bool _delete = false;

  InputBloc() : super(InputEmptyState()) {
    _metadataRepository = GetIt.I<MetadataRepository>();
    _measurementRepository = GetIt.I<MeasurementRepository>();

    on<InputEvent>(mapEventToState);

    _streamSubscription.add(_metadataRepository.measurement
        .listen((measure) => _measure = measure));

        
  }

  @override
  void onEvent(InputEvent event) {
    if (_measure) {
      switch (event.runtimeType) {
        case InputDownEvent:
          if (_metadataRepository.isInDeleteRegion(event.position)) {
            _delete = false;
          } else {
            _delete = true;
          }

          _measurementRepository.registerDownEvent(event.position, event. isPerimeter);
          break;
        case InputMoveEvent:
          _measurementRepository.registerMoveEvent(event.position, event.isPerimeter);
          break;
        case InputUpEvent:
          if (_delete && _metadataRepository.isInDeleteRegion(event.position)) {
            _measurementRepository.removeCurrentPoint();
          } else {
            _measurementRepository.registerUpEvent(event.position, event.isPerimeter);
          }
          break;
        default:
      }
    }

    super.onEvent(event);
  }

  @override
  Future<void> close() {
    _streamSubscription.forEach((subscription) => subscription.cancel());
    return super.close();
  }

  Future<void> mapEventToState(
      InputEvent event,
      Emitter<InputState> emit,
  ) async {
    if (_measure) {
      if (_delete && _metadataRepository.isInDeleteRegion(event.position)) {
        if (event is InputMoveEvent || event is InputDownEvent) {
          emit( InputDeleteRegionState(event.position));
        } else if (event is InputUpEvent) {
          emit(InputDeleteState());
        }
      } else {
        if (event is InputMoveEvent || event is InputDownEvent) {
          emit(InputStandardState(event.position));
        } else if (event is InputUpEvent) {
          emit( InputEndedState(event.position));
        }
      }
    } else {
      emit( InputEmptyState());
    }
  }
}
