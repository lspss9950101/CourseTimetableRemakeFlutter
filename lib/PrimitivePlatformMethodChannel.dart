import 'package:flutter/services.dart';

import 'Course.dart';

class PrimitivePlatformMethodChannel {
  static const WidgetChannel = const MethodChannel('widget');
  static const UtilChannel = const MethodChannel('util');
  static Future<int> updateWidget(List<Course> courses) async {
    int result;
    try {
      result = await WidgetChannel.invokeMethod('updateWidget');
    } on PlatformException catch (e) {
      result = 0;
      print(e);
    }
    return result;
  }
  static Future<int> displayImage(String path) async {
    int result;
    try {
      result = await WidgetChannel.invokeMethod('displayImage', path);
    } on PlatformException catch (e) {
      result = 0;
      print(e);
    }
    return result;
  }
}