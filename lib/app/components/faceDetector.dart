import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:face_detect_firebase/app/components/camera_page.dart';
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
    // print('imagem tirada!!!!!!!!!!!!!!!!!${widget.imageCaptured!}');
    // print('path imagem capturada!!!!!: ${widget.imageCaptured!.path}');

    File img = File(widget.imageCaptured!.path);

    //--------------------------------------------------------------------------------

    // var src = picker.ImageSource.camera;

    // File img = File((await picker.ImagePicker().pickImage(source: src))!.path);

    // print('img!!!!!!!!!!!!!!!:: $img');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FaceDetection(img)),
    );
  }
}

class FaceDetection extends StatefulWidget {
  File file;
  FaceDetection(this.file, {Key? key}) : super(key: key);

  @override
  _FaceDetectionState createState() => _FaceDetectionState();
}

class _FaceDetectionState extends State<FaceDetection> {
  late ui.Image image;
  late List<Face> faces;
  late String _path;
  bool _busy = false;
  var im;

  late tfl.Interpreter interpreter;

  @override
  initState() {
    super.initState();
    setState(() {
      _busy = true;
    });
    faceCompare();
  }

  Future faceCompare() async {
    // print('file!!!!!!!!!!!!!!!!!: ${widget.file}');
    GallerySaver.saveImage(widget.file.path, albumName: 'faceRecognition');
    await loadModel();
    await detectFaces(widget.file);

    im = await loadImage(File(_path));

    File imageFace = File(_path);
    var embeddingFaceImage = await get_embedding_Image(imageFace);

    _write((embeddingFaceImage).toString());

    // Parte comentada

    // print("EMBEDDINGS CAMERA");

    // print(embeddingFaceImage);
    // File imageLeticia = await getImageFileFromAssets("Leticia.png");
    // await detectFaces(imageLeticia);
    // im = await loadImage(File(_path));
    // File imageFace2 = File(_path);
    // var embLeticia = await get_embedding_Image(imageFace2);
    // print("EMBEDDINGS");
    // print(embLeticia);
    // var similarityFace = similarity(embLeticia, embeddingFaceImage);
    // print(similarityFace);
    // if (similarityFace <= 9.9) {
    //   print("FACES IGUAIS");
    // }
  }

  Future loadModel() async {
    try {
      interpreter = await tfl.Interpreter.fromAsset('facenet.tflite');
      print("Interpreter loaded successfully");
    } on PlatformException {
      print('Failed to load model.');
    }
  }

  double similarity(Float32List embedding1, Float32List embedding2) {
    double simi = 0;
    for (int i = 0; i < 128; i++) {
      simi += pow((embedding1[i] - embedding2[i]), 2);
    }
    simi = sqrt(simi);
    return simi;
  }

  Future<Float32List> get_embedding_Image(File image) async {
    img.Image imageInput = img.decodeImage(image.readAsBytesSync())!;

    TensorImage tensorImage = TensorImage(tfl.TfLiteType.float32);
    tensorImage.loadImage(imageInput);

    ImageProcessor imageProcessor = ImageProcessorBuilder()
        .add(ResizeOp(160, 160, ResizeMethod.NEAREST_NEIGHBOUR))
        .build();

    tensorImage = imageProcessor.process(tensorImage);
    double mean_ = mean(tensorImage);
    double std_ = std(tensorImage, mean_);

    ImageProcessor imageProcessorNorm =
        ImageProcessorBuilder().add(NormalizeOp(mean_, std_)).build();
    tensorImage = imageProcessorNorm.process(tensorImage);

    TensorBuffer probabilityBuffer =
        TensorBuffer.createFixedSize(<int>[1, 128], tfl.TfLiteType.float32);

    interpreter.run(tensorImage.buffer, probabilityBuffer.buffer);

    return probabilityBuffer.buffer.asFloat32List();
  }

  double mean(TensorImage tensorImage) {
    var tensorBuffer = tensorImage.getBuffer().asUint8List();
    double mean_ = 0;
    double total = tensorBuffer.shape[0].toDouble();
    for (var pos in tensorBuffer) {
      mean_ += pos / total;
    }
    return mean_;
  }

  double std(TensorImage tensorImage, double mean_) {
    var tensorBuffer = tensorImage.getBuffer().asUint8List();
    double total = tensorBuffer.shape[0].toDouble();
    double std_ = 0;
    for (var pos in tensorBuffer) {
      std_ += pow((pos - mean_), 2) / total;
    }
    std_ = sqrt(std_);

    return std_;
  }

  Future<ui.Image> loadImage(File file) async {
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then(
      (value) => setState(() {
        image = value;
        _busy = false;
      }),
    );
    return image;
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  Future detectFaces(File file) async {
    print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Fase 1');
    img.Image? imgFig = img.decodeImage(file.readAsBytesSync());

    print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Fase 2');
    final GoogleVisionImage visionImage = GoogleVisionImage.fromFile(file);

    print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Fase 3');
    final FaceDetector faceDetector = GoogleVision.instance.faceDetector(
        const FaceDetectorOptions(
            mode: FaceDetectorMode.fast, enableLandmarks: false));

    print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Fase 4');
    List<Face> detectedFaces = await faceDetector.processImage(visionImage);

    print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Fase 5');
    faces = detectedFaces;

    print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Fase 6');

    print('!!!!!!!!!!! detected faces: $detectedFaces');

    if (faces.isEmpty) {
      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! nenhuma face detectada');

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FaceDetectorHome()),
      );
    } else {
      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Fase 7');
      var face = faces.last;
      int left = ((face.boundingBox.left)).round();
      int top = ((face.boundingBox.top)).round();
      int right = ((face.boundingBox.right)).round() - left;
      int bottom = ((face.boundingBox.bottom)).round() - top;

      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Fase 8');
      img.Image imOut = img.copyCrop(imgFig!, left, top, right, bottom);

      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Fase 9');
      _path = join(
        // Store the picture in the temp directory.
        // Find the temp directory using the `path_provider` plugin.
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png',
      );

      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Fase 10');
      File(_path).writeAsBytesSync(img.encodePng(
          imOut)); // está fazendo processo de modificação sincrono, provávelmente, ver se dá pra colocar assincrono.

      // print('imOut!!!!!!!!!!: $imOut');

      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Fase 11');
      GallerySaver.saveImage(_path, albumName: 'teste');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Face Detection"),
      ),
      body: (_busy)
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: FittedBox(
                child: SizedBox(
                    width: image.width.toDouble(),
                    height: image.width.toDouble(),
                    child: CustomPaint(painter: FacePainter(image))),
              ),
            ),
    );
  }
}

class FacePainter extends CustomPainter {
  ui.Image image;
  FacePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(0.8);
    canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return image != oldDelegate.image;
  }
}

_write(String text) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final File file = File('${directory.path}/my_file.txt');

  // print('embeddings saveds!!!!!!!!!!!!!111 ${directory.path}');
  await file.writeAsString(text);
}
