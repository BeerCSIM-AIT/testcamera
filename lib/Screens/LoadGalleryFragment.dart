import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:testcamera/Screens/DisplayPictureScreen.dart';

class LoadGalleryFragment extends StatefulWidget {
  final String mode;
  const LoadGalleryFragment({Key? key, required this.mode}) : super(key: key);

  @override
  _LoadGalleryFragmentState createState() => _LoadGalleryFragmentState();
}

class _LoadGalleryFragmentState extends State<LoadGalleryFragment>
    with SingleTickerProviderStateMixin {
  TabController? controller;
  Future? _futureGetPath;
  List<dynamic> listImagePath = List.empty(growable: true);
  String maturityMode = "unripe";
  var _permissionStatus;

  @override
  void initState() {
    super.initState();
    _listenForPermissionStatus();
    // Declaring Future object inside initState() method
    // prevents multiple calls inside stateful widget
    _futureGetPath = _getPath();
    controller = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: FutureBuilder(
            future: _futureGetPath,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                var dir = Directory(snapshot.data);
                print('permission status: $_permissionStatus');
                if (_permissionStatus) _fetchFiles(dir);
                return Text(snapshot.data);
              } else {
                return Text("Loading");
              }
            },
          ),
        ),
        Expanded(
          flex: 19,
          child: GridView.count(
            primary: false,
            padding: const EdgeInsets.all(10),
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            crossAxisCount: 2,
            children: _getListImg(listImagePath),
          ),
        )
      ],
    );
  }

  // Check for storage permission
  void _listenForPermissionStatus() async {
    final status = await Permission.storage.request().isGranted;
    // setState() triggers build again
    setState(() => _permissionStatus = status);
  }

  Future<String> _getPath() async {
    final String imageDirName = "images";
    final String folderName = widget.mode;
    final Directory? _appDocDir = await getExternalStorageDirectory();
    final Directory _appDocDirFolder =
        Directory('${_appDocDir!.path}/$imageDirName/$folderName/');
    return _appDocDirFolder.path;
  }

  _fetchFiles(Directory dir) {
    List<dynamic> listImage = List.empty(growable: true);
    dir.list().forEach((element) {
      RegExp regExp =
          new RegExp("\.(gif|jpe?g|tiff?|png|webp|bmp)", caseSensitive: false);
      // Only add in List if path is an image
      if (regExp.hasMatch('$element')) listImage.add(element);
      setState(() {
        listImagePath = listImage;
      });
    });
  }

  List<Widget> _getListImg(List<dynamic> listImagePath) {
    List<Widget> listImages = List.empty(growable: true);
    for (var imagePath in listImagePath) {
      listImages.add(
        GestureDetector(
          child: Container(
            padding: const EdgeInsets.all(4),
            child: Image.file(imagePath, fit: BoxFit.cover),
          ),
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    DisplayPictureScreen2(imagePath: imagePath),
              ),
            );
          },
        ),
      );
    }
    return listImages;
  }
}

class DisplayPictureScreen2 extends StatelessWidget {
  final dynamic imagePath;
  const DisplayPictureScreen2({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview'),
      ),
      body: Image.file(imagePath),
    );
  }
}
