import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:face_detect_firebase/app/components/camera_page.dart';
import 'package:face_detect_firebase/app/components/showImage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_ml_vision/google_ml_vision.dart';
// import 'package:image_picker/image_picker.dart' as picker;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:gallery_saver/gallery_saver.dart';

import '../modules/home/home_store.dart';

final HomeStore store = Modular.get<HomeStore>();

class FaceDetectorHome extends StatefulWidget {
  // const FaceDetectorHome();
  final XFile? imageCaptured;
  const FaceDetectorHome({Key? key, this.imageCaptured}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FaceDetectorHomeState();
}

class _FaceDetectorHomeState extends State<FaceDetectorHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Face Detection'),
        ),
        body: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            buildRowTitle(context, 'Pick Image'),
            buildSelectImageRowWidget(context)
          ],
        )));
  }

  Widget buildRowTitle(BuildContext context, String title) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: Text(
        title,
      ),
    ));
  }

  Widget buildSelectImageRowWidget(BuildContext context) {
    return Row(
      children: <Widget>[createButton('Camera')],
    );
  }

  Widget createButton(String imgSource) {
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: RaisedButton(
          color: Colors.blue,
          textColor: Colors.white,
          splashColor: Colors.blueGrey,
          onPressed: () {
            onPickImageSelected(imgSource);
          },
          child: Text(imgSource)),
    ));
  }

  onPickImageSelected(String imgSource) async {
    //------------------------------------------------------------------------------

    await availableCameras().then((value) => Navigator.push(context,
        MaterialPageRoute(builder: (context) => CameraApp(cameras: value))));

    File img = File(widget.imageCaptured!.path);
  }
}
