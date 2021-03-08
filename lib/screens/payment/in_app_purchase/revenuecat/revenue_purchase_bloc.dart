import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_payment_method/utils/app_helper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenuePaymentBloc {

  BuildContext context;
  PurchaserInfo purchaserInfo;
  Offerings offerings;
  bool hasPayment = false;

  /// REVENUE PAYMENT ==========================================

  Future<void> payment({BuildContext context, @required RevenueEntitlementType revenueEntitlementType, @required RevenuePackageType revenuePackageType}) async {
    if(Platform.isIOS){
      // show loading
    }
    await getOfferings(context);

    if (offerings != null) {
      if (offerings.all.isNotEmpty) {
        Package offeringType;

        try {
          bool result = false;

          switch(revenueEntitlementType){

            case RevenueEntitlementType.all:

              if(revenuePackageType == RevenuePackageType.monthly){
                offeringType = offerings.all['offering_name'].monthly;
              }

              if(revenuePackageType == RevenuePackageType.annual){
                offeringType = offerings.all['offering_name'].annual;
              }

              purchaserInfo = await Purchases.purchasePackage(offeringType);

              result = purchaserInfo.entitlements.all["entitlements_name"].isActive;
              break;
          }

          if (result) {
            // push payment success

            if(Platform.isIOS){
             // hide loading
            }

            AppHelper.showToaster('Payment success', context);

          }


        } on PlatformException catch (error) {
          print('----xx-----');
          if(Platform.isIOS){
            // hide loading
          }
          var errorCode = PurchasesErrorHelper.getErrorCode(error);
          if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
            AppHelper.showToaster('User cancelled', context);
            //info.add("User cancelled");
          } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
            AppHelper.showToaster('User not allowed to purchase', context);
            //info.add("User not allowed to purchase");
          }
        }
      } else {
        // push info failed
        AppHelper.showToaster('offerings current is null', context);

        //info.add('offerings current is null');
      }
    } else {

      if(Platform.isIOS){
        // hide loading
      }
      // push info failed
      AppHelper.showToaster('offerings current is null', context);
    }
  }

  Future<void> getOfferings(context) async {
    try {

      offerings = await Purchases.getOfferings();

    } on PlatformException catch (e) {
      AppHelper.showToaster(e.toString());
    }
  }

  Future<bool> checkPaymentInfo() async {

    hasPayment = false;

    try {
      purchaserInfo = await Purchases.getPurchaserInfo();
      print(purchaserInfo);
      // check purchase
      if(purchaserInfo != null){
        if(purchaserInfo.allPurchasedProductIdentifiers.isNotEmpty && purchaserInfo.entitlements.active.isNotEmpty){
          hasPayment = true;
        }
      }

      return hasPayment;

    } on PlatformException catch (e) {
      AppHelper.showToaster(e.toString(), context);
      return hasPayment;
    }

  }

}

enum RevenueEntitlementType{
  all,
}

enum RevenuePackageType{
  monthly,
  annual,
}