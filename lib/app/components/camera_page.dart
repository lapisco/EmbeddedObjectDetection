// import 'dart:html';
import 'dart:io';
import 'package:face_detect_firebase/app/components/showImage.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../modules/home/home_store.dart';
import 'faceDetector.dart';

List<CameraDescription> cameras = [];

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   cameras = await availableCameras();
//   runApp(CameraApp());
// }

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
  final List<CameraDescription>? cameras;
  const CameraApp({Key? key, this.cameras}) : super(key: key);
}

class _CameraAppState extends State<CameraApp> {
  final HomeStore store = Modular.get<HomeStore>();
  CameraController? controller;
  XFile? pictureFile;
  int num = 1;

  // CameraDescription? camera = cameras[1];

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.cameras![num], ResolutionPreset.max);
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller!.value.isInitialized) {
      return const SizedBox(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      body: CameraPreview(controller!),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FaceDetectorHome()));
                  },
                  icon: const Icon(Icons.arrow_back)),
              label: ''),
          BottomNavigationBarItem(
              icon: IconButton(
                  onPressed: () async {
                    pictureFile = await controller!.takePicture().then((value) {
                      store.receiveImage(value);

                      File file = File(value.path);

                      // print('capturado!!!!!!!!!!!!!!!!${(store.imagePicked)}');

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ShowAlteredImage(file)));
                      return null;
                    });
                    setState(() {});
                    // if (pictureFile != null) {
                    //   Image.network(
                    //     pictureFile!.path,
                    //     height: 200,
                    //   );

                    //   print('picturefile!!!!!!!! $pictureFile');

                    //   Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) => FaceDetectorHome(
                    //                 imageCaptured: pictureFile,
                    //               )));
                    // }
                  },
                  icon: const Icon(Icons.hexagon)),
              label: ''),
          BottomNavigationBarItem(
              icon: IconButton(
                  onPressed: () {
                    setState(() {
                      if (num == 1) {
                        num = 0;
                      } else if (num == 0) {
                        num = 1;
                      }
                      controller = CameraController(
                          widget.cameras![num], ResolutionPreset.max);
                      controller!.initialize().then((_) {
                        if (!mounted) {
                          return;
                        }
                        setState(() {});
                      });
                    });
                  },
                  icon: const Icon(Icons.rotate_90_degrees_ccw)),
              label: '')
        ],
      ),
    );
  }
}
