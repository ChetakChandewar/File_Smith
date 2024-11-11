import 'package:flutter/material.dart';

class DrawerStateProvider with ChangeNotifier {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
    notifyListeners();
  }
}
