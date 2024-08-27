import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DashStack {
  static DashStack? _instance;
  static DashStack get instance => _instance ??= DashStack._();

  DashStack._();

  String packageName = "com.dash.girls_talks";
  bool isInitialize = false;

  Future<void> initialize() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      // PackageInfo packageInfo = await PackageInfo.fromPlatform();
      // packageName = packageInfo.packageName;
      await GetStorage.init("dash_stack");
      isInitialize = true;
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
