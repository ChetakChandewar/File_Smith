import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  int _currentIndex = 0;
  int _selectedFeature = 0;

  int get currentIndex => _currentIndex;
  int get selectedFeature => _selectedFeature;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setFeature(int featureIndex) {
    _selectedFeature = featureIndex;
    notifyListeners();
  }
}
