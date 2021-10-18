import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:deteksibendaberbahaya/page/home_scan.dart';

List<CameraDescription> cameras;

Future<Null> main() async {
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }
  runApp(new Main_home_scan());
}

class Main_home_scan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deteksi benda berbahaya',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: HomePageScan(cameras),
    );
  }
}
