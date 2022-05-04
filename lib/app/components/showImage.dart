import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:gallery_saver/gallery_saver.dart';

class ShowAlteredImage extends StatefulWidget {
  File? image;
  ShowAlteredImage(this.image, {Key? key}) : super(key: key);

  @override
  State<ShowAlteredImage> createState() => _ShowAlteredImageState();
}

class _ShowAlteredImageState extends State<ShowAlteredImage> {
  @override
  Widget build(BuildContext context) {
    GallerySaver.saveImage(widget.image!.path, albumName: 'capturedPicture');
    print('entrou aqui!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');

    return Scaffold(
        appBar: AppBar(
          title: const Text("Face Detection"),
        ),
        body: Center(
          child: FittedBox(
            child: SizedBox(
                width: 400, height: 400, child: Image.file(widget.image!)),
          ),
        ));
  }
}
