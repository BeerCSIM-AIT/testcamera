import 'dart:io';

import 'package:path_provider/path_provider.dart';

final String imageDirName = "images";

class AppUtil {
  static Future<String> createFolderInAppDocDir(String folderName) async {
    //Get this App Document Directory
    final Directory? _appDocDir = await getExternalStorageDirectory();
    //App Document Directory + folder name
    final Directory _appDocDirFolder =
        Directory('${_appDocDir!.path}/$imageDirName/$folderName/');

    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
      return _appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
      return _appDocDirNewFolder.path;
    }
  }
}
