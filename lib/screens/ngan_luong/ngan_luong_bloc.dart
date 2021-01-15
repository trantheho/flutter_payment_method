import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_payment_method/base/bloc.dart';
import 'package:flutter_payment_method/model/ngan_luong_model.dart';
import 'package:flutter_payment_method/screens/ngan_luong/result/ngan_luong_result_screen.dart';
import 'package:flutter_payment_method/service/app_api.dart';
import 'package:flutter_payment_method/utils/app_constants.dart';
import 'package:flutter_payment_method/utils/app_helper.dart';
import 'package:flutter_payment_method/utils/app_screen_name.dart';

class NganLuongBloc extends AppBloc{
  final loading = BlocDefault<bool>();



  @override
  void dispose() {
    loading.dispose();
  }

  @override
  void initLogic() {
    // TODO: implement initLogic
  }


  Future<void> checkoutNganLuong(int money, BuildContext context) async {
    loading.push(true);
    if(AppConstant.mMerchantID.isEmpty){

      await Future.delayed(Duration(milliseconds: 500));
      loading.push(false);
      AppHelper.showToaster( 'Please add your merchant info' ,context);

    }
    else{

      final data = submitDeposit(money, 'your order code from api return');
      final response =
      await AppApi.instance.checkoutNL(data).timeout(Duration(seconds: 60));

      var res = json.decode(response.toString());
      final nganLuongModel = NganLuongModel(res);
      print("checkout url: " + nganLuongModel.checkoutUrl);
      if (nganLuongModel.code == "00") {
        loading.push(false);

        AppHelper.navigatePush(context, AppScreenName.nganLuongResult,
            NganLuongResultScreen(
              url: nganLuongModel.checkoutUrl,
              token: nganLuongModel.tokenCode,
              amount: money,
            ));
      }
      else{
        loading.push(false);
      }

    }

  }

  SendDeposit submitDeposit(int money, String orderCode){

    // input your notify url
    final notifyUrl = "";

    SendDeposit sendDeposit = SendDeposit();
    sendDeposit.mFunc = AppConstant.mFunc;
    sendDeposit.mVersion = AppConstant.mVersion;
    sendDeposit.mMerchantID = AppConstant.mMerchantID;
    sendDeposit.mMerchantAccount = AppConstant.mMerchantAccount;
    sendDeposit.mOrderCode = orderCode;
    sendDeposit.mTotalAmount = money;
    sendDeposit.mCurrency = AppConstant.mCurrency;
    sendDeposit.mLanguage =  AppConstant.mLanguage;
    sendDeposit.mReturnUrl = AppConstant.RETURN_URL;
    sendDeposit.mCancelUrl = AppConstant.CANCEL_URL;
    sendDeposit.mNotifyUrl = notifyUrl;
    sendDeposit.mBuyerFullName = 'user name';
    sendDeposit.mBuyerEmail = 'user email';
    sendDeposit.mBuyerMobile = '0123456789'; // user phone
    sendDeposit.mBuyerAddress = 'user address';
    sendDeposit.mChecksum = getChecksum(sendDeposit);

    return sendDeposit;
  }


  String getChecksum(SendDeposit sendOrderBean) {
    String stringSendOrder = sendOrderBean.mFunc + "|" +
        sendOrderBean.mVersion + "|" +
        sendOrderBean.mMerchantID + "|" +
        sendOrderBean.mMerchantAccount + "|" +
        sendOrderBean.mOrderCode + "|" +
        sendOrderBean.mTotalAmount.toString() + "|" +
        sendOrderBean.mCurrency + "|" +
        sendOrderBean.mLanguage + "|" +
        sendOrderBean.mReturnUrl + "|" +
        sendOrderBean.mCancelUrl + "|" +
        sendOrderBean.mNotifyUrl + "|" +
        sendOrderBean.mBuyerFullName + "|" +
        sendOrderBean.mBuyerEmail + "|" +
        sendOrderBean.mBuyerMobile + "|" +
        sendOrderBean.mBuyerAddress + "|" +
        AppConstant.mMerchantPassword;
    String checksum = AppHelper.generateMd5(stringSendOrder);

    return checksum;
  }





}