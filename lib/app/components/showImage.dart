import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui' as ui;

class ShowAlteredImage extends StatefulWidget {
  File? image;
  ShowAlteredImage(this.image, {Key? key}) : super(key: key);

  @override
  State<ShowAlteredImage> createState() => _ShowAlteredImageState();
}

class _ShowAlteredImageState extends State<ShowAlteredImage> {
  @override
  Widget build(BuildContext context) {
    print('entrou aqui!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    // final img = decodeImage(File('test.webp').readAsBytesSync())!;
    // ui.Image imag = loadImage(widget.image) as ui.Image;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Face Detection"),
        ),
        body: Center(
          child: FittedBox(
            child: SizedBox(
                // width: Image.network(widget.image!.path).width!.toDouble(),
                // height: Image.network(widget.image!.path).height!.toDouble(),
                width: 400,
                height: 400,
                child: Image.file(widget.image!)
                // child: CustomPaint(painter: FacePainter(image))),
                ),
          ),
        ));
  }
}
