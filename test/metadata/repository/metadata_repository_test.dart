///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:measurements/measurements.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';
import 'package:measurements/style/magnification_style.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/test_mocks.dart';


void main() {
  group("Metadata Repository Unit Test", () {
    final expectedMeasurement = true;
    final expectedShowDistance = true;
    final Function(List<double>) expectedCallback = null;
    final Function(double) expectedToleranceCallback = null;
    final expectedMeasurementInformation = MeasurementInformation(documentWidthInLengthUnits: Millimeter(200), scale: 4.0);
    final expectedViewCenter = Offset(100, 150);
    final Image expectedImage = MockedImage.mock;
    final expectedMagnificationStyle = MagnificationStyle();

    final expectedViewScaleFactor = 1.0;
    final expectedImageScaleFactor = 3.0;
    final expectedTransformationFactor = Millimeter(1 / 4);

    final viewSize = Size(200, 300);

    MetadataRepository metadataRepository;

    setUp(() {
      metadataRepository = MetadataRepository();
    });

    tearDown(() {
      metadataRepository.dispose();
    });

    test("started", () {
      when((expectedImage as MockedImage).width).thenReturn(600);

      metadataRepository.registerStartupValuesChange(
          measurementInformation: expectedMeasurementInformation,
          measure: expectedMeasurement,
          showDistance: expectedShowDistance,
          magnificationStyle: expectedMagnificationStyle,
          callback: expectedCallback,
          toleranceCallback: expectedToleranceCallback
      );

      metadataRepository.registerBackgroundChange(expectedImage, viewSize);

      metadataRepository.measurement.listen((actual) => expect(actual, expectedMeasurement));
      metadataRepository.showDistances.listen((actual) => expect(actual, expectedShowDistance));
      metadataRepository.callback.listen((actual) => expect(actual, expectedCallback));
      metadataRepository.viewCenter.listen((actual) => expect(actual, expectedViewCenter));
      metadataRepository.backgroundImage.listen((actual) => expect(actual, expectedImage));

      metadataRepository.viewScaleFactor.listen((actual) => expect(actual, expectedViewScaleFactor));
      metadataRepository.imageScaleFactor.listen((actual) => expect(actual, expectedImageScaleFactor));
      metadataRepository.transformationFactor.listen((actual) => expect(actual, expectedTransformationFactor));
    });

    test("started and updated view size", () {
      final updatedViewSize = Size(400, 150);
      final expectedUpdatedViewScaleFactor = 2.0;

      when((expectedImage as MockedImage).width).thenReturn(600);

      metadataRepository.registerStartupValuesChange(
          measurementInformation: expectedMeasurementInformation,
          measure: expectedMeasurement,
          showDistance: expectedShowDistance,
          magnificationStyle: expectedMagnificationStyle,
          callback: expectedCallback,
          toleranceCallback: expectedToleranceCallback
      );

      metadataRepository.registerBackgroundChange(expectedImage, viewSize);
      metadataRepository.registerBackgroundChange(expectedImage, updatedViewSize);

      metadataRepository.viewScaleFactor.listen((actual) => expect(actual, expectedUpdatedViewScaleFactor));
    });
  });
}