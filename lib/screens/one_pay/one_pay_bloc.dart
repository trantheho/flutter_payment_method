import 'package:flutter/material.dart';
import 'package:flutter_payment_method/base/bloc.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:convert/convert.dart';
import 'package:flutter_payment_method/utils/app_constants.dart';
import 'package:flutter_payment_method/utils/app_helper.dart';
import 'package:flutter_payment_method/utils/app_screen_name.dart';
import 'package:get_ip/get_ip.dart';
import 'package:flutter_payment_method/screens/one_pay/result/one_pay_result_screen.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class OnePayBloc extends AppBloc{
  final loading = BlocDefault<bool>();

  @override
  void dispose() {
    loading.dispose();
  }

  @override
  void initLogic() {
    // TODO: implement initLogic
  }

  Future<void> checkoutOnePay(int amount, BuildContext context) async{
    if(AppConstant.onePayAccessCode.isEmpty && AppConstant.onePaySecret.isEmpty){
      AppHelper.showToaster('Please add your access code and secret code');
    }
    else{
      loading.push(true);
      String param = await createUrl(amount.toString(),'1234');
      String url = AppConstant.onePayUrl + param;

      loading.push(false);
      AppHelper.navigatePush(context, AppScreenName.onePay,
        OnePayResultScreen(
          url: url,
        ),
      );
    }
  }

  Future<String> createUrl(String amount, String orderId) async {

    final String time = DateTime.now().millisecondsSinceEpoch.toString();

    String ip = 'Unknown';

    try {
      ip = await GetIp.ipAddress;
    } on PlatformException {
      ip = 'Unknown';
    }

    Map<String, String> data = {
      'vpc_AccessCode': AppConstant.onePayAccessCode,
      'vpc_Amount': amount + "00",
      'vpc_Command':"pay",
      'vpc_Currency':"VND",
      'vpc_Locale':"vn",
      'vpc_MerchTxnRef':time,
      'vpc_Merchant':"TESTONEPAY",
      'Title': "test",
      'vpc_OrderInfo':orderId,
      'vpc_ReturnURL': AppConstant.onePayReturnUrl,
      'AgainLink':"https://mtf.onepay.vn",
      'vpc_SecureHash':genSecureHash(amount,time, orderId, ip),
      'vpc_TicketNo': ip,
      'vpc_Version':"2",
    };


    return data.keys.map((key) => "${Uri.encodeComponent(key)}=${Uri.encodeComponent(data[key])}").join("&");
  }

  // gen secureHash

  String genSecureHash(String amount, String time, String orderId, String ip){

    Map<String, String> mapField = {
      'vpc_AccessCode': AppConstant.onePayAccessCode,
      'vpc_Amount': amount + '00',
      'vpc_Command':'pay',
      'vpc_Currency':'VND',
      'vpc_Locale':'vn',
      'vpc_MerchTxnRef':time,
      'vpc_Merchant':'TESTONEPAY',
      'vpc_OrderInfo':orderId,
      'vpc_ReturnURL': AppConstant.onePayReturnUrl,
      'vpc_TicketNo': ip,
      'vpc_Version':'2',
    };

    List<String> sortList = [];
    sortList.addAll(mapField.keys);
    sortList.sort();
    String resultHash = '';
    for(int i=0; i <sortList.length; i++){
      if(i == sortList.length -1){
        resultHash += sortList[i] + '=${mapField[sortList[i]]}';
      }
      else {
        resultHash += sortList[i] + '=${mapField[sortList[i]]}&';
      }
    }

    print(resultHash);

    var key = hex.decode(AppConstant.onePaySecret);

    print('key: $key');

    var hmac = new crypto.Hmac(crypto.sha256, key);
    var digest = hmac.convert(utf8.encode(resultHash));
    var upperCase = digest.toString().toUpperCase();
    return upperCase;

  }

}