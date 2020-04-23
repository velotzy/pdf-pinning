import 'dart:async';
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/measurement/bloc/points_bloc/points_event.dart';
import 'package:measurements/measurement/bloc/points_bloc/points_state.dart';
import 'package:measurements/measurement/repository/measurement_repository.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';
import 'package:measurements/util/logger.dart';

class PointsBloc extends Bloc<PointsEvent, PointsState> {
  final _logger = Logger(LogDistricts.POINTS_BLOC);

  MeasurementRepository _measureRepository;
  MetadataRepository _metadataRepository;

  StreamSubscription _onlyPointsSubscription;
  StreamSubscription _pointsAndDistancesSubscription;

  Offset _viewCenter;

  PointsBloc() {
    _measureRepository = GetIt.I<MeasurementRepository>();

    _onlyPointsSubscription = _measureRepository.points.listen((points) {
      _logger.log("adding points only event");
      add(PointsOnlyEvent(points));
    });

    _pointsAndDistancesSubscription = _measureRepository.drawingHolder.listen((holder) {
      _logger.log("adding points and distances event");
      add(PointsAndDistancesEvent(holder.points, holder.distances));
    });

    _metadataRepository = GetIt.I<MetadataRepository>();

    _metadataRepository.showDistances.listen((showDistances) {
      if (showDistances) {
        _pointsAndDistancesSubscription?.resume();
        _onlyPointsSubscription?.pause();
        _logger.log("now showing with distance");
      } else {
        _onlyPointsSubscription?.resume();
        _pointsAndDistancesSubscription?.pause();
        _logger.log("now showing without distance");
      }
    });

    _metadataRepository.viewCenter.listen((center) {
      _logger.log("updated viewCenter");
      _viewCenter = center;
    });

    _logger.log("Created Bloc");
  }

  @override
  PointsState get initialState => PointsEmptyState();

  @override
  void onEvent(PointsEvent event) {
    _logger.log("received event: $event");
    super.onEvent(event);
  }

  @override
  Stream<PointsState> mapEventToState(PointsEvent event) async* {
    if (event.points.length == 0) {
      yield PointsEmptyState();
    } else if (event.points.length == 1) {
      yield PointsSingleState(event.points[0]);
    } else {
      if (event is PointsOnlyEvent) {
        yield PointsOnlyState(event.points);
      } else if (event is PointsAndDistancesEvent) {
        yield PointsAndDistanceState(event.points, event.distances, _viewCenter);
      }
    }
  }
}
