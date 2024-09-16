/// Copyright (c) 2020 arconsis IT-Solutions GmbH
/// Licensed under MIT (https://github.com/arconsis/measurements/blob/master/LICENSE)

import 'package:document_measure/document_measure.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'colors.dart';

class MetadataRepository {}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static String originalTitle = 'Measurement app';
  String title = originalTitle;
  bool measure = true;
  bool showDistanceOnLine = true;
  bool showTolerance = false;
  bool zoomed = false;

  List<LengthUnit> unitsOfMeasurement = [
    Meter.asUnit(),
    Millimeter.asUnit(),
    Inch.asUnit(),
    Foot.asUnit()
  ];
  int unitIndex = 0;

  MeasurementController controller = MeasurementController();

  @override
  void initState() {
    super.initState();

  }

  Color getButtonColor(bool selected) {
    if (selected) {
      return selectedColor;
    } else {
      return unselectedColor;
    }
  }

  int _selectedIndex = 0;
  final listController = [
    MeasurementController(),
    MeasurementController(),
    MeasurementController()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Row(
            children: <Widget>[
              IconButton(
                onPressed: () => setState(() {
                  measure = !measure;
                  title = originalTitle;
                }),
                icon: Icon(
                  Icons.pinch,
                  color: getButtonColor(
                    measure,
                  ),
                ),
              ),
              
                      IconButton(
                onPressed: () {
                  controller.clear();
                  setState(() {
                    
                  });
                }
                    ,
                icon: Icon(
                  Icons.delete,
                  color: getButtonColor(showDistanceOnLine),
                ),
              ),
            ],
          ),
        ),
        body: Measurements(
            child: Center(child: Image.asset('assets/images/tech_draw.png'),),
            deleteChild: Container(
            // child: Icon(
            //   Icons.delete,
            //   color: Colors.red,
            // ),
            margin: EdgeInsets.only(bottom: 40),
          ),
            measurementInformation: MeasurementInformation(
              scale: 1 / 1.0,
              documentWidthInLengthUnits: Millimeter(210),
              documentHeightInLengthUnits: Millimeter(297),
              targetLengthUnit: unitsOfMeasurement[unitIndex],
            ),
            
            controller: listController[_selectedIndex],
            showDistanceOnLine: true,
          ),
        
      ),
    );
  }
}
