import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:testcamera/Screens/LoadGalleryFragment.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen>
    with SingleTickerProviderStateMixin {
  TabController? controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gallery"),
        bottom: TabBar(
          tabs: [
            Tab(text: "อ่อน"),
            Tab(text: "แก่"),
          ],
          controller: controller,
        ),
      ),
      body: TabBarView(
        children: [
          LoadGalleryFragment(mode: "unripe"),
          LoadGalleryFragment(mode: "ripe"),
        ],
        controller: controller,
      ),
    );
  }
}
