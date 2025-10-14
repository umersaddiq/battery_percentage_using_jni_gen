import 'dart:developer';

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
  late final batteryUtils = BatteryUtils(
    JObject.fromReference(Jni.getCachedApplicationContext()),
  );

  late final int percentage = batteryUtils.getBatteryPercentage();
  late final int percentageLegacy = batteryUtils.getBatteryPercentageLegacy();

  var _percentage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      batteryUtils.startBatteryPercentageStream(
        BatteryCallback.implement(
          $BatteryCallback(
            onBatteryPercentageChanged: (percentage) {
              log('Current Percentage from Stream : $percentage%');
              _percentage = percentage;
              setState(() {});
            },
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    batteryUtils.stopBatteryPercentageStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Native Packages')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Battery Percentage : $percentage'),
              Text('Current Battery Legacy Percentage : $percentageLegacy'),
              Text('Percentage from Stream : $_percentage%'),
            ],
          ),
        ),
      ),
    );
  }
}
