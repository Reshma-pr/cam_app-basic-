import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final camera = await availableCameras();
  final firstcamera = camera.first;
  runApp(MaterialApp(
    theme: ThemeData.dark(),
    home: TakePictureCamera(
      cameraDescription: firstcamera,
    ),
  ));
}

class TakePictureCamera extends StatefulWidget {
  TakePictureCamera({Key? key, required this.cameraDescription})
      : super(key: key);
  final CameraDescription cameraDescription;

  @override
  State<TakePictureCamera> createState() => _TakePictureCameraState();
}

class _TakePictureCameraState extends State<TakePictureCamera> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller =
        CameraController(widget.cameraDescription, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CamApp"),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DisplayPicture(imagePath: image.path)));
          } catch (e) {
            print(e);
          }
        },
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}

class DisplayPicture extends StatelessWidget {
  DisplayPicture({Key? key, required this.imagePath}) : super(key: key);
  final String imagePath;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Picture Feed"),
      ),
      body: Image.file(File(imagePath)),
    );
  }
}
