import 'package:battery_percentage/battery_utils.dart';
import 'package:flutter/material.dart';

import 'package:jni/jni.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final batteryUtils = BatteryUtils(
    JObject.fromReference(Jni.getCachedApplicationContext()),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Native Packages')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Battery Percentage : ${batteryUtils.getBatteryPercentage()}',
            ),
            Text(
              'Current Battery Legacy Percentage : ${batteryUtils.getBatteryPercentageLegacy()}',
            ),
          ],
        ),
      ),
    );
  }
}
