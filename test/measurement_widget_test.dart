///
/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)
///

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:measurements/measurement/drawing_holder.dart';
import 'package:measurements/measurement/overlay/measure_area.dart';
import 'package:measurements/measurement/repository/measurement_repository.dart';
import 'package:measurements/measurements.dart';
import 'package:measurements/metadata/repository/metadata_repository.dart';
import 'package:photo_view/photo_view.dart';

Type typeOf<T>() => T;

final imageWidth = 800.0;
final imageHeight = 600.0;
final imageWidget = Image.asset(
  "assets/images/example_portrait.png",
  package: "measurements",
  width: imageWidth,
  height: imageHeight,
);

Widget fillTemplate(Widget measurement) {
  return MaterialApp(home: Scaffold(body: measurement,),);
}

void main() {
  group("Measurement Widget Integration Test", () {
    MetadataRepository metadataRepository;
    MeasurementRepository measurementRepository;

    setUp(() {
      metadataRepository = MetadataRepository();
      measurementRepository = MeasurementRepository(metadataRepository);

      GetIt.I.registerSingleton(metadataRepository);
      GetIt.I.registerSingleton(measurementRepository);
    });

    tearDown(() {
      GetIt.I.unregister(instance: metadataRepository);
      GetIt.I.unregister(instance: measurementRepository);
    });

    testWidgets("measurement should show child also when measure is false", (WidgetTester tester) async {
      await tester.pumpWidget(fillTemplate(Measurement(child: imageWidget,)));

      expect(find.byType(typeOf<PhotoView>()), findsOneWidget);
      expect(find.byType(typeOf<Image>()), findsOneWidget);
      expect(find.byType(typeOf<MeasureArea>()), findsOneWidget);
    });

    testWidgets("measurement should show child under measure area when measuring", (WidgetTester tester) async {
      await tester.pumpWidget(fillTemplate(
          Measurement(
            child: imageWidget,
            measure: true,
          )
      ));

      await tester.pump();

      expect(find.byType(typeOf<Image>()), findsOneWidget);
      expect(find.byType(typeOf<MeasureArea>()), findsOneWidget);
    });

    testWidgets("adding single point", (WidgetTester tester) async {
      await tester.pumpWidget(fillTemplate(
          Measurement(
            child: imageWidget,
            measure: true,
          )
      ));

      await tester.pump();

      final gesture = await tester.startGesture(Offset(100, 100));
      await gesture.up();

      await tester.pump();

      measurementRepository.points.listen((actual) => expect(actual, [Offset(100, 100)]));
    });

    testWidgets("adding multiple points and getting distances", (WidgetTester tester) async {
      await tester.pumpWidget(fillTemplate(
          Measurement(
            child: imageWidget,
            measure: true,
            showDistanceOnLine: true,
            measurementInformation: MeasurementInformation(documentWidthInLengthUnits: Millimeter(imageWidth * 2)),
          )
      ));

      await tester.pump();

      final gesture = await tester.startGesture(Offset(100, 100));
      await gesture.up();

      await gesture.down(Offset(100, 300));
      await gesture.up();

      await gesture.down(Offset(300, 300));
      await gesture.up();

      await gesture.down(Offset(300, 100));
      await gesture.up();

      await tester.pump();

      final expectedDrawingHolder = DrawingHolder(
          [Offset(100, 100), Offset(100, 300), Offset(300, 300), Offset(300, 100)],
          [Millimeter(400), Millimeter(400), Millimeter(400)]
      );

      measurementRepository.drawingHolder.listen((actual) => expect(actual, expectedDrawingHolder));
    });

    testWidgets("add points without distances and then turn on distances", (WidgetTester tester) async {
      await tester.pumpWidget(fillTemplate(
          Measurement(
            child: imageWidget,
            measure: true,
            showDistanceOnLine: false,
            measurementInformation: MeasurementInformation(documentWidthInLengthUnits: Millimeter(imageWidth * 2)),
          )
      ));

      await tester.pump();

      final gesture = await tester.startGesture(Offset(100, 100));
      await gesture.up();

      await gesture.down(Offset(100, 300));
      await gesture.up();

      await gesture.down(Offset(300, 300));
      await gesture.up();

      await gesture.down(Offset(300, 100));
      await gesture.up();

      await tester.pump();

      measurementRepository.points.listen((actual) => expectSync(actual, [Offset(100, 100), Offset(100, 300), Offset(300, 300), Offset(300, 100)]));

      await tester.pumpWidget(fillTemplate(
          Measurement(
            child: imageWidget,
            measure: true,
            showDistanceOnLine: false,
            measurementInformation: MeasurementInformation(documentWidthInLengthUnits: Millimeter(imageWidth * 2)),
          )
      ));

      await tester.pump();

      final expectedDrawingHolder = DrawingHolder(
          [Offset(100, 100), Offset(100, 300), Offset(300, 300), Offset(300, 100)],
          [Millimeter(400), Millimeter(400), Millimeter(400)]
      );

      measurementRepository.drawingHolder.listen((actual) => expect(actual, expectedDrawingHolder));
    });

    testWidgets("adding multiple points and getting distances with set scale", (WidgetTester tester) async {
      await tester.pumpWidget(fillTemplate(
          Measurement(
            child: imageWidget,
            measure: true,
            showDistanceOnLine: true,
            measurementInformation: MeasurementInformation(documentWidthInLengthUnits: Millimeter(imageWidth), scale: 2.0),
          )
      ));

      await tester.pump();

      final gesture = await tester.startGesture(Offset(100, 100));
      await gesture.up();

      await gesture.down(Offset(100, 300));
      await gesture.up();

      await gesture.down(Offset(300, 300));
      await gesture.up();

      await gesture.down(Offset(300, 100));
      await gesture.up();

      await tester.pump();

      final expectedDrawingHolder = DrawingHolder(
        [Offset(100, 100), Offset(100, 300), Offset(300, 300), Offset(300, 100)],
        [Millimeter(100), Millimeter(100), Millimeter(100)],
      );

      measurementRepository.drawingHolder.listen((actual) => expect(actual, expectedDrawingHolder));
    });
  });
}