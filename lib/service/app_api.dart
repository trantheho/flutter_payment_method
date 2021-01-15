import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_payment_method/model/ngan_luong_model.dart';
import 'package:flutter_payment_method/service/api.dart';
import 'package:flutter_payment_method/utils/app_constants.dart';
import 'package:flutter_payment_method/utils/app_helper.dart';

class AppApi extends Api{
  static AppApi instance = AppApi._private();
  AppApi._private();




  /// TiTi: check out ngan luong
  Future<Response> checkoutNL(SendDeposit sendDeposit ) async {
    /// header = access token
    final header = await getAuthorizedHeader();
    Logging.log(json.encode({"func": sendDeposit.mFunc,
      "version": sendDeposit.mVersion,
      "merchant_id": sendDeposit.mMerchantID,
      "merchant_account": sendDeposit.mMerchantAccount,
      "order_code": sendDeposit.mOrderCode,
      "total_amount": sendDeposit.mTotalAmount,
      "currency": sendDeposit.mCurrency,
      "language": sendDeposit.mLanguage,
      "return_url": sendDeposit.mReturnUrl,
      "cancel_url": sendDeposit.mCancelUrl,
      "notify_url": sendDeposit.mNotifyUrl,
      "buyer_fullname": sendDeposit.mBuyerFullName,
      "buyer_email": sendDeposit.mBuyerEmail,
      "buyer_mobile": sendDeposit.mBuyerMobile,
      "buyer_address": sendDeposit.mBuyerAddress,
      "checksum": sendDeposit.mChecksum,}));

    return dioExceptionWrapper(() => dio.post(AppConstant.nganLuongUrl,
        options: Options(headers: header),
        queryParameters:{
          "func": sendDeposit.mFunc,
          "version": sendDeposit.mVersion,
          "merchant_id": sendDeposit.mMerchantID,
          "merchant_account": sendDeposit.mMerchantAccount,
          "order_code": sendDeposit.mOrderCode,
          "total_amount": sendDeposit.mTotalAmount,
          "currency": sendDeposit.mCurrency,
          "language": sendDeposit.mLanguage,
          "return_url": sendDeposit.mReturnUrl,
          "cancel_url": sendDeposit.mCancelUrl,
          "notify_url": sendDeposit.mNotifyUrl,
          "buyer_fullname": sendDeposit.mBuyerFullName,
          "buyer_email": sendDeposit.mBuyerEmail,
          "buyer_mobile": sendDeposit.mBuyerMobile,
          "buyer_address": sendDeposit.mBuyerAddress,
          "checksum": sendDeposit.mChecksum,
        }));
  }




}