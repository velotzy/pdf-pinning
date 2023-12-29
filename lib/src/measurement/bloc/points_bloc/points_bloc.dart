/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'dart:async';
import 'dart:ui';

import 'package:document_measure/src/measurement/bloc/points_bloc/points_event.dart';
import 'package:document_measure/src/measurement/bloc/points_bloc/points_state.dart';
import 'package:document_measure/src/measurement/overlay/holder.dart';
import 'package:document_measure/src/measurement/repository/measurement_repository.dart';
import 'package:document_measure/src/metadata/repository/metadata_repository.dart';
import 'package:document_measure/src/util/logger.dart';
import 'package:document_measure/src/util/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../drawing_holder.dart';

class PointsBloc extends Bloc<PointsEvent, PointsState> {
  final _logger = Logger(LogDistricts.POINTS_BLOC);
  final List<StreamSubscription> _streamSubscriptions = [];

  late MeasurementRepository _measureRepository;
  late MetadataRepository _metadataRepository;

  StreamSubscription? _onlyPointsSubscription;
  StreamSubscription? _pointsAndDistancesSubscription;

  late Function(List<Offset>) _pointsListener;
  late Function(DrawingHolder) _pointsAndDistanceListener;

  late Offset _viewCenter;
  late double _tolerance;

  PointsBloc() : super(PointsEmptyState()) {

    on<PointsEvent>(mapEventToState);
    _pointsListener = (points) => add(PointsOnlyEvent(points));
    _pointsAndDistanceListener = (holder) =>
        add(PointsAndDistancesEvent(holder.points, holder.distances));

    _measureRepository = GetIt.I<MeasurementRepository>();
    _metadataRepository = GetIt.I<MetadataRepository>();

    _streamSubscriptions
        .add(_metadataRepository.showDistances.listen((showDistances) {
      if (showDistances) {
        if (_pointsAndDistancesSubscription == null) {
          _onlyPointsSubscription?.cancel().then((value) {
            _onlyPointsSubscription = null;
          });

          _pointsAndDistancesSubscription = _measureRepository.drawingHolder
              .listen(_pointsAndDistanceListener);
        }
      } else {
        if (_onlyPointsSubscription == null) {
          _pointsAndDistancesSubscription?.cancel().then((value) {
            _pointsAndDistancesSubscription = null;
          });

          _onlyPointsSubscription =
              _measureRepository.points.listen(_pointsListener);
        }
      }
    }));

    _streamSubscriptions.add(_metadataRepository.viewCenter
        .listen((center) => _viewCenter = center));
    _streamSubscriptions.add(_metadataRepository.tolerance
        .listen((tolerance) => _tolerance = tolerance));
  }

  @override
  void onEvent(PointsEvent event) {
    _logger.log('received event: $event');
    super.onEvent(event);
  }

  @override
  Future<void> close() {
    _streamSubscriptions.forEach((subscription) => subscription.cancel());
    _onlyPointsSubscription?.cancel();
    _pointsAndDistancesSubscription?.cancel();
    return super.close();
  }

  
  Future<void> mapEventToState(
      PointsEvent event,
      Emitter<PointsState> emit,
  ) async {
    if (event.points.isEmpty) {
      emit( PointsEmptyState());
    } else if (event.points.length == 1) {
      emit( PointsSingleState(event.points[0]));
    } else {
      if (event is PointsOnlyEvent) {
        emit( PointsOnlyState(event.points));
      } else if (event is PointsAndDistancesEvent) {
        emit( _mapMultiplePointsWithDistancesToState(event));
      }
    }
  }

  PointsState _mapMultiplePointsWithDistancesToState(
      PointsAndDistancesEvent event) {
    var holders = <Holder>[];
    event.points.doInBetween((start, end) => holders.add(Holder(start, end)));
    event.distances.asMap().forEach((index, distance) =>
        holders[index] = Holder.extend(holders[index], distance));

    if (event.distances.contains(null)) {
      var nullIndices = <int>[];
      nullIndices.add(event.distances.indexOf(null));
      nullIndices.add(event.distances.lastIndexOf(null));

      return PointsAndDistanceActiveState(
          holders, _viewCenter, _tolerance, nullIndices);
    } else if (event.points.length - 1 > event.distances.length) {
      return PointsAndDistanceActiveState(
          holders, _viewCenter, _tolerance, [event.distances.length]);
    } else {
      return PointsAndDistanceState(holders, _viewCenter, _tolerance);
    }
  }
}
