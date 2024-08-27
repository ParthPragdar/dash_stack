import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as get_x;
import 'package:get_storage/get_storage.dart';

import '../utils/string.dart';

bool isLiveApi = true;

enum ServerType { dev, live }

///Live
String baseUri = "https://ads.wiseappbuilder.com/";

String somethingWrong = MCS.somethingWentWrong.tr;
String responseMessage = MCS.noResponseDataFound.tr;
String interNetMessage = MCS.pleaseCheckYourInternetConnectionAndTryAgainLatter.tr;
String connectionTimeOutMessage = MCS.opsServerNotWorkingOrMightBeInMaintenancePleaseTryAgainLater.tr;
String authenticationMessage = MCS.theSessionHasBeenExpiredPleaseLogInAgain.tr;
String tryAgain = CS.tryAgain.tr;

int serviceCallCount = 0;
GetStorage storage = GetStorage("dash_stack");

class Api {
  get_x.RxBool isLoading = false.obs;
  call({
    required String url,
    Map<String, dynamic>? params,
    Map<String, dynamic>? header,
    required Function success,
    Function(Map<String, dynamic>)? error,
    Function? authentication,
    ErrorMessageType errorMessageType = ErrorMessageType.snackBarOnlyError,
    MethodType methodType = MethodType.post,
    bool? isHideLoader = true,
    bool isProgressShow = true,
    bool isGoBack = true,
    bool isThirdParty = false,
    bool isShowErrorToast = true,
    FormData? formValues,
  }) async {
    if (await checkInternet()) {
      if (isProgressShow) {
        showProgressDialog(isLoading: isProgressShow);
      }
      if (formValues != null) {
        Map<String, dynamic> tempMap = <String, dynamic>{};
        for (var element in formValues.fields) {
          tempMap[element.key] = element.value;
        }
        FormData reGenerateFormData = FormData.fromMap(tempMap);
        for (var element in formValues.files) {
          reGenerateFormData.files.add(MapEntry(element.key, element.value));
        }
        formValues = reGenerateFormData;
      }
      isLoading.value = true;
      Map<String, dynamic> headerParameters = {};
      if (!isThirdParty) {
        if ((storage.read("loginToken") ?? "").toString().isNotEmpty) {
          headerParameters.addAll({"authorization": "Bearer ${storage.read("loginToken") ?? ""}"});
          if (kDebugMode) {
            print("token $headerParameters");
          }
        }
      }
      // else {
      //   headerParameters.addAll({"authorization": "Bearer ${storage.read("loginToken") ?? ""}"});
      // }
      if (header?.isNotEmpty ?? false) {
        headerParameters.addAll(header!);
      }
      String mainUrl = isThirdParty ? url : (baseUri + url);
      if (kDebugMode) {
        print('authorization: ${headerParameters["authorization"] ?? ""}');
        print(mainUrl);
        print(params);
      }

      try {
        Response response;

        if (methodType == MethodType.get) {
          response = await Dio().get(mainUrl,
              queryParameters: params,
              options: Options(
                headers: headerParameters,
                validateStatus: (status) {
                  return (status! < 500);
                },
                responseType: ResponseType.plain,
              ));
        } else if (methodType == MethodType.put) {
          response = await Dio().put(mainUrl,
              data: params,
              options: Options(
                headers: headerParameters,
                validateStatus: (status) {
                  return (status! < 500);
                },
                responseType: ResponseType.plain,
              ));
        } else {
          response = await Dio().post(mainUrl,
              data: formValues ?? params,
              options: Options(
                headers: headerParameters,
                validateStatus: (status) {
                  return (status! < 500);
                },
                responseType: ResponseType.plain,
              ));
        }

        if (handleResponse(response)) {
          if (kDebugMode) {
            print("error code => ${response.statusCode}");
            print(response);
          }

          ///postman response Code guj
          Map<String, dynamic>? responseData;
          if (!isThirdParty) responseData = jsonDecode(response.data);

          if (isHideLoader!) {
            hideProgressDialog();
          }

          if (isThirdParty) {
            if ((response.statusCode == 401 || response.statusCode == 403)) {
              if (authentication != null) {
                authentication();
              }
            } else {
              success(response.data);
            }
          } else if (response.statusCode == 200) {
            //#region alert
            if (errorMessageType == ErrorMessageType.snackBarOnlySuccess || errorMessageType == ErrorMessageType.snackBarOnResponse) {
              debugPrint(responseData?["message"] ?? "");
            } else if (errorMessageType == ErrorMessageType.dialogOnlySuccess || errorMessageType == ErrorMessageType.dialogOnResponse) {
              await apiAlertDialog(message: responseData?["message"], buttonTitle: CS.okay.tr, isShowGoBack: isGoBack);
            }
            //#endregion alert
            if ((responseData?.containsKey("data") ?? false) &&
                (responseData is Map) &&
                (responseData?.containsKey("token") ?? false) &&
                (responseData?["token"].toString().isNotEmpty ?? false)) {
              storage.write(CS.rLoginToken, responseData?["token"]);
            }
            success(responseData!);
          } else {
            //region 401 = Session Expired Manage Authentication/Session Expire
            if (response.statusCode == 401 || response.statusCode == 403) {
              unauthorizedDialog(responseData?["message"]);
            } else {
              if (kDebugMode) {
                print("else ===>");
              }

              if (isShowErrorToast) {
                //#region alert
                if (errorMessageType == ErrorMessageType.snackBarOnlyError || errorMessageType == ErrorMessageType.snackBarOnResponse) {
                  debugPrint(responseData?["message"] ?? "");
                } else if (errorMessageType == ErrorMessageType.dialogOnlyError || errorMessageType == ErrorMessageType.dialogOnResponse) {
                  await apiAlertDialog(message: responseData?["message"], buttonTitle: CS.okay.tr, isShowGoBack: isGoBack);
                }
              }

              //#endregion alert
              if (error != null) {
                error(responseData!);
              }
            }
            //endregion
          }
          isLoading.value = false;
        } else {
          if (isHideLoader!) {
            hideProgressDialog();
          }
          if (kDebugMode) {
            print('else_======>');
          }
          showErrorMessage(
              message: responseMessage,
              isRecall: true,
              isGoBack: isGoBack,
              callBack: () {
                goBack();
                call(
                  params: params,
                  url: url,
                  success: success,
                  error: error,
                  isProgressShow: isProgressShow,
                  methodType: methodType,
                  formValues: formValues,
                  isHideLoader: isHideLoader,
                  errorMessageType: errorMessageType,
                  isGoBack: isGoBack,
                  isThirdParty: isThirdParty,
                );
              });
          isLoading.value = false;
        }
        isLoading.value = false;
      } on DioException catch (dioError) {
        //#region dioError
        if (kDebugMode) {
          print('DioError======> ${dioError.message}');
          print('DioError======> ${dioError.stackTrace}');
        }
        dioErrorCall(
            dioError: dioError,
            onCallBack: (String message, bool isRecallError) {
              showErrorMessage(
                  message: message,
                  isGoBack: isGoBack,
                  isRecall: isRecallError,
                  callBack: () {
                    if (serviceCallCount < 3) {
                      serviceCallCount++;

                      if (isRecallError) {
                        goBack();
                        call(
                          params: params,
                          url: url,
                          success: success,
                          error: error,
                          isProgressShow: isProgressShow,
                          methodType: methodType,
                          formValues: formValues,
                          isHideLoader: isHideLoader,
                          errorMessageType: errorMessageType,
                          isGoBack: isGoBack,
                          isThirdParty: isThirdParty,
                        );
                      } else {
                        goBack(); // For redirecting to back screen
                      }
                    } else {
                      goBack(); // For redirecting to back screen
                      // GeneralController.to.selectedTab.value = 0;
                      // get_x.Get.offAll(() => DashboardTab());
                    }
                  });
            });
        isLoading.value = false;
        //#endregion dioError
      } catch (e) {
        //#region catch
        if (kDebugMode) {
          print(e);
        }
        if (kDebugMode) {
          print('catch======>');
        }
        hideProgressDialog();
        showErrorMessage(
            message: e.toString(),
            isGoBack: isGoBack,
            isRecall: true,
            callBack: () {
              goBack();
              call(
                params: params,
                url: url,
                success: success,
                error: error,
                isProgressShow: isProgressShow,
                methodType: methodType,
                formValues: formValues,
                isHideLoader: isHideLoader,
                errorMessageType: errorMessageType,
                isGoBack: isGoBack,
                isThirdParty: isThirdParty,
              );
            });
        isLoading.value = false;

        //#endregion catch
      }
    } else {
      //#region No Internet
      showErrorMessage(
          message: interNetMessage,
          isRecall: true,
          isGoBack: isGoBack,
          callBack: () {
            goBack();
            call(
              params: params,
              url: url,
              success: success,
              error: error,
              isProgressShow: isProgressShow,
              methodType: methodType,
              formValues: formValues,
              isHideLoader: isHideLoader,
              errorMessageType: errorMessageType,
              isGoBack: isGoBack,
              isThirdParty: isThirdParty,
            );
          });
      //#endregion No Internet
    }
  }
}

showErrorMessage({required String message, required bool isRecall, required Function callBack, bool isGoBack = true}) {
  serviceCallCount = 0;
  // serviceCallCount++;
  hideProgressDialog();
  apiAlertDialog(
      buttonTitle: serviceCallCount < 3 ? tryAgain : CS.restartApp.tr,
      message: message,
      buttonCallBack: () {
        callBack();
      },
      isShowGoBack: isGoBack);
}

showProgressDialog({bool isLoading = true}) {
  isLoading = true;
  get_x.Get.dialog(
      PopScope(
        canPop: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // CircularProgressIndicator()
            gifLoader(),
          ],
        ),
      ),
      barrierColor: Colors.black12,
      barrierDismissible: false);
}

gifLoader() {
  return const CircularProgressIndicator();
}

void hideProgressDialog({bool isLoading = true, bool isProgressShow = true, bool isHideLoader = true}) {
  isLoading = false;
  if ((isProgressShow || isHideLoader) && (get_x.Get.isDialogOpen ?? false)) {
    goBack();
  }
}

dioErrorCall({required DioException dioError, required Function onCallBack}) {
  switch (dioError.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.cancel:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
    default:
      onCallBack(dioError.message, true);
      break;
  }
}

Future<bool> checkInternet() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  return !(connectivityResult.first == ConnectivityResult.none);
}

unauthorizedDialog(message) async {
  debugPrint(message ?? "");
}

bool handleResponse(Response response) {
  try {
    if (response.toString().isNotEmpty) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}

goBack() {
  get_x.Get.back(closeOverlays: get_x.Get.isSnackbarOpen);
}

apiAlertDialog({required String message, String? buttonTitle, Function? buttonCallBack, bool isShowGoBack = true}) async {
  if (!get_x.Get.isDialogOpen!) {
    debugPrint(message);

    // return commonToast(msg: message);

    /*await get_x.Get.dialog(
      WillPopScope(
        onWillPop: () {
          return isShowGoBack ? Future.value(true) : Future.value(false);
        },
        child: CupertinoAlertDialog(
          title: Text(CS.swipeCart),
          content: Text(message),
          actions: isShowGoBack
              ? [
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text(isNotEmptyString(buttonTitle) ? buttonTitle! : CS.tryAgain.tr),
                    onPressed: () {
                      if (buttonCallBack != null) {
                        buttonCallBack();
                      } else {
                        goBack();
                      }
                    },
                  ),
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text(CS.goBack.tr),
                    onPressed: () {
                      goBack();
                      goBack();
                    },
                  )
                ]
              : [
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text(isNotEmptyString(buttonTitle) ? buttonTitle! : CS.tryAgain.tr),
                    onPressed: () {
                      if (buttonCallBack != null) {
                        buttonCallBack();
                      } else {
                        goBack();
                      }
                    },
                  ),
                ],
        ),
      ),
      barrierDismissible: false,
      transitionCurve: Curves.easeInCubic,
      transitionDuration: const Duration(milliseconds: 400),
    );*/
  }
}

enum MethodType { get, post, put }

enum MessageType { success, error, warning }

enum ErrorMessageType { snackBarOnlyError, snackBarOnlySuccess, snackBarOnResponse, dialogOnlyError, dialogOnlySuccess, dialogOnResponse, none }
