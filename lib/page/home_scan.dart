import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import 'package:deteksibendaberbahaya/page/camera.dart';
import 'package:deteksibendaberbahaya/page/render.dart';

const String ssd = "Start Classification";

class HomePageScan extends StatefulWidget {
  final List<CameraDescription> cameras;

  HomePageScan(this.cameras);

  @override
  _HomePageScanState createState() => new _HomePageScanState();
}

class _HomePageScanState extends State<HomePageScan> {
  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "";

  @override
  void initState() {
    super.initState();
  }

  loadModel() async {
    String res;
    String res2;
    switch (_model) {
      default:
        res = await Tflite.loadModel(model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
        res2 = await Tflite.loadModel(model: 'assets/mobilenet_v2_1.0_224.tflite', labels: 'assets/labels2');
        break;
    }
    print(res);
    print(res2);
  }

  onSelect(model) {
    setState(() {
      _model = model;
    });
    loadModel();
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;

    return RotatedBox(
        quarterTurns: 1,
        child: Scaffold(
          appBar: PreferredSize(preferredSize: Size.fromHeight(20.0), child: AppBar(centerTitle: true, title: const Text('TFlite Real Time Classification'))),
          body: _model == ""
              ? Center(
                  child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/bg3.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ButtonTheme(
                        child: RaisedButton(
                          child: Text(ssd, style: TextStyle(fontSize: 25.0)),
                          onPressed: () => onSelect(ssd),
                        ),
                      )
                    ],
                  ),
                ))
              : Stack(
                  children: [
                    RotatedBox(
                        quarterTurns: -1,
                        child: Camera(
                          widget.cameras,
                          _model,
                          setRecognitions,
                        )),
                    Render(
                      _recognitions == null ? [] : _recognitions,
                      math.max(_imageHeight, _imageWidth),
                      math.min(_imageHeight, _imageWidth),
                      screen.height,
                      screen.width,
                    ),
                  ],
                ),
        ));
  }
}
