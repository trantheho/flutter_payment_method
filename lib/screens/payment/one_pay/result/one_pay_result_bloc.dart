/*
 * Developed by TiTi on 10/2/20 10:29 AM.
 * Last modified 9/28/20 9:21 AM.
 * Copyright (c) 2020 Beesight Soft. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:flutter_payment_method/base/bloc.dart';
import 'package:flutter_payment_method/utils/app_constants.dart';
import 'package:flutter_payment_method/utils/app_helper.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// info test
/// ABBank:
/// name: NGUYEN VAN A
/// card number: 9704 2500 0000 0001
/// date: 01/13
/// otp: 123456



class OnePayResultBloc extends AppBloc {
  final loading = BlocDefault<bool>();

  WebViewController webViewController;
  String authorUrl = 'https://mtf.onepay.vn/paygate/api/v1/authorizations';

  @override
  void dispose() {
    loading.dispose();
  }

  @override
  void initLogic() {
  }

  /// need to contact one pay supporter to get info test

  Future<void> handleUrlChange(String url, BuildContext context) async {

    if (url.startsWith(AppConstant.onePayReturnUrl) ) {
      var uri = Uri.dataFromString(url);
      loading.push(true);

      print(uri.queryParameters);

      if(uri.queryParameters['vpc_TxnResponseCode'].compareTo('0') == 0){
        // finish transaction
        //finishTransaction.push(uri.queryParameters['vpc_MerchTxnRef']);
        await Future.delayed(Duration(seconds: 1));
        loading.push(false);
        AppHelper.showToaster('payment success', context);
        Navigator.of(context).pop();
      }
      else{
        print('one pay failed');
        Navigator.of(context).pop();
      }
    }

    if (url.startsWith(authorUrl)){
      loading.push(true);
      // need remove below code
      await Future.delayed(Duration(seconds: 1));
      loading.push(false);
      AppHelper.showToaster('payment success', context);
      Navigator.of(context).pop();
    }

  }



}
