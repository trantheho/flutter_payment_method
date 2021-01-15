import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_payment_method/utils/app_constants.dart';
import 'package:stripe_payment/stripe_payment.dart';

class StripeTransactionResponse {
  String message;
  bool success;
  StripeTransactionResponse({this.message, this.success});
}

class StripeService {
  static String apiBase = 'https://api.stripe.com/v1';
  static String paymentApiUrl = '${StripeService.apiBase}/payment_intents';
  static String secret = AppConstant.stripeSecretKey;
  static Map<String, String> headers = {
    'Authorization': 'Bearer ${StripeService.secret}',
    'Content-Type': 'application/x-www-form-urlencoded'
  };
  static init() {
    StripePayment.setOptions(
      StripeOptions(
        publishableKey: AppConstant.stripePublishableKey,
        merchantId: "Test",
        androidPayMode: 'test'
      )
    );
  }

  static Future<StripeTransactionResponse> payViaExistingCard({String amount, String currency, String  secret, CreditCard card}) async{
    try {

      var paymentMethod = await StripePayment.createPaymentMethod(
        PaymentMethodRequest(card: card)
      );
      /*var paymentIntent = await StripeService.createPaymentIntent(
        amount,
        currency,
        orderId,
      );*/
      var response = await StripePayment.confirmPaymentIntent(
        PaymentIntent(
          clientSecret: secret,//paymentIntent['client_secret'],
          paymentMethodId: paymentMethod.id,
        )
      );
      if (response.status == 'succeeded') {
        return new StripeTransactionResponse(
          message: '1',
          success: true
        );
      } else {
        return new StripeTransactionResponse(
          message: 'error',
          success: false
        );
      }
    } on PlatformException catch(err) {
      return StripeService.getPlatformExceptionErrorResult(err);
    } catch (err) {
      return new StripeTransactionResponse(
        message: 'Transaction failed: ${err.toString()}',
        success: false
      );
    }
  }

  static Future<StripeTransactionResponse> payWithNewCard({String amount, String currency, String secret}) async {
    try {
      var paymentMethod = await StripePayment.paymentRequestWithCardForm(
        CardFormPaymentRequest()
      );
      /*var paymentIntent = await StripeService.createPaymentIntent(
        amount,
        currency,
      );*/
      var response = await StripePayment.confirmPaymentIntent(
        PaymentIntent(
          clientSecret: secret,//paymentIntent['client_secret'],
          paymentMethodId: paymentMethod.id
        )
      );
      if (response.status == 'succeeded') {
        return new StripeTransactionResponse(
          message: '1',
          success: true
        );
      } else {
        return new StripeTransactionResponse(
          message: '0',
          success: false
        );
      }
    } on PlatformException catch(err) {
      return StripeService.getPlatformExceptionErrorResult(err);
    } catch (err) {
      return new StripeTransactionResponse(
        message: 'Stripe transaction failed: ${err.toString()}',
        success: false
      );
    }
  }

  static getPlatformExceptionErrorResult(err) {
    String message = err.message.toString();
    if (err.code == 'cancelled') {
      message = 'cancel';
    }

    if (err.message.toString().compareTo('Your card was declined') == 0) {
      message = 'authenticationFailed';
    }

    if (err.message.toString().compareTo('Your card has expired') == 0) {
      message = 'expired';
    }

    if (err.message.toString().compareTo("Your card's security code is invalid") == 0) {
      message = 'cvc';
    }

    if (err.message.toString().compareTo("There was an error processing your card -- try again in a few seconds") == 0) {
      message = 'processing';
    }

    if (err.message.toString().compareTo("Your card's number is invalid") == 0) {
      message = 'number';
    }

    return new StripeTransactionResponse(
      message: message,
      success: false
    );
  }

  /// function create payment intent for client

  /*static Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency, int orderId) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      var response = await http.post(
        StripeService.paymentApiUrl,
        body: body,
        headers: StripeService.headers
      );
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
    return null;
  }*/
}
