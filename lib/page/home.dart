import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flat_icons_flutter/flat_icons_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:tflite/tflite.dart';
import 'package:mysql1/mysql1.dart';
import 'package:intl/intl.dart';
import 'package:deteksibendaberbahaya/page/main_home_scan.dart';
import 'package:deteksibendaberbahaya/page/main_home_scan2.dart';

class HomePageDetects extends StatefulWidget {
  @override
  HomePages createState() => HomePages();
}

class HomePages extends State<HomePageDetects> {
  List _results;
  var hasilsql;
  Future ConnectDB() async {
    final connectdb = await MySqlConnection.connect(ConnectionSettings(host: 'localhost', port: 3306, user: 'root', db: 'db_deteksibendaberhaya', password: ''));
    hasilsql = await connectdb.query('INSERT INTO tb_benda(No_benda,Input_benda,gambar,Tgl_input) VALUES(?,?,?)', [
      inputbenda,
      Filegambar,
      hasiltgl
    ]);
    print('Inserted row id=${hasilsql.insertId}');
  }

  static final DateTime now = DateTime.now();
  static final DateFormat formatdate = DateFormat('yyy-MM-dd');
  final String hasiltgl = formatdate.format(now);
  var inputbenda;
  File Filegambar;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Deteksi benda berbahaya',
        ),
      ),
      body: Column(
        children: [
          if (Filegambar != null)
            Container(margin: EdgeInsets.all(10), child: Image.file(Filegambar))
          else
            Container(
              margin: EdgeInsets.all(40),
              child: Opacity(
                opacity: 0.6,
                child: Center(
                  child: Text('Gambar tidak terdeteksi'),
                ),
              ),
            ),
          SingleChildScrollView(
            child: Column(
              children: _results != null
                  ? _results.map((result) {
                      return Card(
                        child: Container(
                          margin: EdgeInsets.all(10),
                          child: Text(
                            "${result["label"]} -  ${result["confidence"].toStringAsFixed(2)}",
                            style: TextStyle(color: Colors.red, fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }).toList()
                  : [],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          new IconButton(
            icon: Image.asset('asset/gambar/captureimg.png'),
            /* Font Awesome Script icon: FaIcon(FontAwesomeIcons.scanner),*/
            iconSize: 25,
            onPressed: () async {
              await showAlertDialogDatabase(context);
              setState(() {});
            },
          ),
          SizedBox(height: 16),
          new IconButton(
            icon: Image.asset('asset/gambar/scanimg.png'),
            /* Font Awesome Script icon: FaIcon(FontAwesomeIcons.scanner),*/
            iconSize: 25,
            onPressed: () {
              showAlertDialogScanGambar(context);
            },
          ),
          new IconButton(
            icon: new Icon(FlatIcons.picture),

            /* Font Awesome Script icon: FaIcon(FontAwesomeIcons.scanner),*/
            iconSize: 25,
            onPressed: () {
              showAlertDialogGalery(context);
            },
          ),
        ],
      ),
    );
  }

  showAlertDialogDataBerhasilDisimpan(BuildContext context) {
    Widget Yesbutton = FlatButton(
      child: Text("Oke"),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePageDetects()));

        setState(() {
          ConnectDB();
        });
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Data berhasil disimpan ^-^"),
      actions: [
        Yesbutton,
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  showAlertDialogHomePageScanDL(BuildContext context) {
    Widget Halbutton1 = FlatButton(
        child: Text("Halaman scan 1"),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => Main_home_scan()));
        });
    Widget Halbutton2 = FlatButton(
        child: Text("Halaman scan 2"),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => MainHomeScanDua()));
        });
    AlertDialog alert = AlertDialog(
      title: Text("Halaman Scan Benda"),
      content: Text("Anda yakin ingin pindah halaman scan?"),
      actions: [
        Halbutton1,
        Halbutton2,
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  showAlertDialogDatabase(BuildContext context) {
    Widget Yesbutton = FlatButton(
        child: Text("Belum"),
        onPressed: () async {
          await pickImage(ImageSource.camera);

          setState(() {
            showAlertDialogDataBerhasilDisimpan(context);
          });
        });
    AlertDialog alert = AlertDialog(
      title: Text("Simpan photo ke Database"),
      content: Text("Anda sudah ambil photo?"),
      actions: [
        Yesbutton,
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  showAlertDialogScanGambar(BuildContext context) {
    Widget Yesbutton = FlatButton(
        child: Text("Ya"),
        onPressed: () {
          showAlertDialogHomePageScanDL(context);
        });
    Widget Nobutton = FlatButton(
      child: Text("Tidak"),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePageDetects()));
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Scanning benda"),
      content: Text("Anda ingin scan benda?"),
      actions: [
        Nobutton,
        Yesbutton,
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  showAlertDialogGalery(BuildContext context) {
    Widget Yesbutton = FlatButton(
      child: Text("Ya"),
      onPressed: () async {
        await pickImage(ImageSource.gallery);

        setState(() {
          showAlertDialogDataBerhasilDisimpan(context);
        });
      },
    );
    Widget Nobutton = FlatButton(
      child: Text("Tidak"),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePageDetects()));
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Gallery Photo"),
      content: Text("Anda ingin pergi ke galeri photo?"),
      actions: [
        Nobutton,
        Yesbutton,
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  Future loadModel() async {
    await Tflite.loadModel(model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
    await Tflite.loadModel(model: 'assets/assets/mobilenet_v2_1.0_224.tflite', labels: 'assets/labels2.txt');
    await Tflite.loadModel(model: 'assets/assets/detect.tflite', labels: 'assets/labelmap.txt');
  }

  void pickImage(ImageSource imageSource) async {
    var image = await ImagePicker().pickImage(source: imageSource);
    if (image == null) {
      return null;
    }
    setState(() {
      Filegambar = File(image.path);
    });
    processImage(Filegambar);
  }

  Future processImage(File image) async {
    // Run tensorflowlite image classification model on the image
    final List results = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _results = results;
      Filegambar = image;
    });
  }
}
