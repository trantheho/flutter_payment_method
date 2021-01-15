import 'dart:convert';
import 'dart:io';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_payment_method/main_bloc.dart';
import 'package:flutter_payment_method/widgets/dialog.dart';
import 'package:toast/toast.dart';

class AppHelper{


  static SystemUiOverlayStyle statusBarOverlayUI(Brightness androidBrightness){
    SystemUiOverlayStyle statusBarStyle;
    if(Platform.isIOS)
      statusBarStyle = (androidBrightness == Brightness.light) ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
    if(Platform.isAndroid){
      statusBarStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: androidBrightness ?? Brightness.light);
    }
    return statusBarStyle;
  }

  static showToaster(String text, [BuildContext context]) {
    if (text.isEmpty) return;
    Toast.show(text, context == null ? MainBloc.instance.getOverLayContext() : context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
        backgroundRadius: 10,
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.8),
        textColor: Colors.white);
  }


  /// network dialog
  static void showNetworkDialog(String title, String message) {
    if (MainBloc.instance.getOverLayContext() == null) return;
    showDialog(
      context: MainBloc.instance.getOverLayContext(),
      barrierDismissible: false,
      builder: (context) => AppAlertDialog(title: title,message: message),
    );
  }

  static void navigatePush(context, String screenName, Widget screen, [Function(Object) callback]) {
    if (context == null) return null;
    Navigator.push(context,
        CupertinoPageRoute(builder: (context) =>
        screen,
          settings: RouteSettings(name: screenName),
        )
    ).then((data) {
      if (data != null && callback != null) {
        callback(data);
      }
    });
  }

  static generateMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var md5 = crypto.md5;
    var digest = md5.convert(content);
    print(hex.encode(digest.bytes));
    return hex.encode(digest.bytes);
  }

  static void hideKeyboard(context) {
    FocusScope.of(context).unfocus();
  }


}

/// Log utils
class Logging {
  static int tet;

  static void log(dynamic data) {
    if (!kReleaseMode) print(data);
  }
}