import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_payment_method/base/bloc.dart';
import 'package:flutter_payment_method/utils/app_constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NganLuongResultBloc extends AppBloc{

  WebViewController webViewController;
  int start = 0;
  bool fail = false;

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  void initLogic() {
    // TODO: implement initLogic
  }

  void handleUrlChange(String url, BuildContext context){

    if(url.startsWith(AppConstant.nlErrorUrl)){
      /// push payment error
      Navigator.of(context).pop();
    }

    if (url.startsWith(AppConstant.nlSuccessUrl) ) {
      /// push payment success
      /// using token and amount to post order to your server
      Navigator.of(context).pop();
    }

    if(url.startsWith(AppConstant.nlFailedUrl)){
      /// fail url return 2 time for ios
      if(Platform.isIOS){
        if(start > 2){
          fail = true;
          /// push result payment failed
          Navigator.of(context).pop();
        }
      }
      if(Platform.isAndroid){
        if(start > 0){
          fail = true;
          /// push result payment failed
          Navigator.of(context).pop();
        }
      }
      start++;
    }

    if (url.startsWith(AppConstant.RETURN_URL)){
      /// push result payment success
      Navigator.of(context).pop();

    }

  }




}