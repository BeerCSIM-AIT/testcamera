import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:testcamera/AppUtil.dart';
import 'package:testcamera/Screens/DisplayPictureScreen.dart';
import 'package:testcamera/Screens/GalleryScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MaterialApp(
    theme: ThemeData.dark(),
    home: TakePictureScreen(
      camera: firstCamera,
    ),
  ));
}

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  const TakePictureScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  // Next, initialize the controller. This returns a Future.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    print(size.height);
    return Scaffold(
      appBar: AppBar(
        title: Text('Take a photo'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GalleryScreen(),
                ),
              );
            },
            icon: Icon(Icons.photo_album),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 6,
            child: Container(
              child: FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(_controller);
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _photoModeButton("unripe", "อ่อน"),
                  _photoModeButton("ripe", "แก่"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoModeButton(String strMode, String strCaption) {
    return Expanded(
      flex: 1,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: ElevatedButton(
          onPressed: () async {
            await handlePhotoTaking(context, strMode);
          },
          child: Text(strCaption),
        ),
      ),
    );
  }

  Future<void> handlePhotoTaking(BuildContext context, String mode) async {
    try {
      await _initializeControllerFuture;
      String storedFolder = await AppUtil.createFolderInAppDocDir(mode);
      String imgFileName =
          mode + "_" + DateTime.now().millisecondsSinceEpoch.toString();
      String imgPath = "$storedFolder$imgFileName.jpg";
      final image = await _controller.takePicture();
      print("======== Image Path ========");
      print(image.path);
      print(imgPath);
      image.saveTo(imgPath);

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(imagePath: imgPath),
        ),
      );
    } catch (e) {
      print(e);
    }
  }
}
