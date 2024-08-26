import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../service/api_call.dart';
import '../utils/common_functions.dart';
import '../utils/string.dart';

class MasterController extends GetxController {
  static MasterController get to => Get.find();

  String packageName = "com.dash.girls_talks";

  callUserDetail() async {
    try {
      String? savedToken = storage.read(CS.sUserToken);
      if (savedToken?.isEmpty ?? true) {
        String token = generateToken();
        await Api().call(
          url: CS.mUserDetail,
          isProgressShow: false,
          params: {"package_name": packageName, "u_token": token},
          success: (response) {
            storage.write(CS.sUserToken, token);
          },
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  List<Map<String, dynamic>> activityData = [];
  callUserActivity() {
    if (activityData.isEmpty) return;
    //fdffdfdf
    Api().call(
      url: CS.mUserActivity,
      isProgressShow: false,
      params: {"key": activityData},
      success: (response) {
        activityData.clear();
      },
    );
  }

  updateActivity({required Map<String, dynamic> data}) {
    if (!activityData.any((element) => element['url_id'] == data['url_id'])) {
      activityData.add(data);
    } else {
      for (var element in activityData) {
        if (element['url_id'] == data['url_id']) {
          int lastTime = element['activity_time'];
          int newTime = data['activity_time'];
          element['activity_time'] = lastTime + newTime;
        } else {
          activityData.add(data);
        }
      }
    }

    debugPrint("Activity Data::$activityData");
  }

  startActivityCall() {
    Timer.periodic(const Duration(minutes: 2), (time) {
      callUserActivity();
      getSortedData();
    });
  }

  RxList allActionList = [].obs;
  RxList actionList = [].obs;
  int actionCount = 2;
  callGetAction() async {
    if (packageName.isEmpty) return;
    String url = "${CS.mGetActivityByPackageName}$packageName.json";
    await Api().call(
      url: url,
      methodType: MethodType.get,
      isProgressShow: false,
      success: (response) {
        debugPrint("Get Data ==-=-=-=>>${response['data']}");
        allActionList.value = response['data'];
        actionCount = response['count'] ?? 2;
        getSortedData();
        // actionList.value = [
        //   {"url": "https://play2214.atmequiz.com/start", "url_id": 5, "js_path": "https://ads.wiseappbuilder.com/public/1720349039303-app.js"}
        // ];
      },
    );
  }

  getSortedData() {
    int i = 0;
    i = (storage.read("lastCount") ?? -1) + 1;
    actionList.value = [];
    for (int j = 0; j < actionCount; j++) {
      int k = i + j;
      if (k >= allActionList.length) {
        k = 0;
        i = 0;
      }
      actionList.add(allActionList[k]);
      storage.write("lastCount", k);
    }
    debugPrint("-=-SortedData=-=- :: $i");
    debugPrint("-=-SortedData=-=- :: ${actionList.map((e) => e['url_id']).toList()}");
  }

  Future<String> readJSFileByUrl(String url, {Function(String)? onCallBack}) async {
    String content = "";
    try {
      await Api().call(
        url: url,
        isThirdParty: true,
        methodType: MethodType.get,
        isProgressShow: false,
        success: (response) {
          content = response.toString();
          if (onCallBack != null) {
            onCallBack(content);
          }
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
    return content;
  }
}
