/*
 * Developed by TiTi on 9/22/20 1:32 PM.
 * Last modified 9/22/20 1:32 PM.
 * Copyright (c) 2020 Beesight Soft. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:flutter_payment_method/base/bloc.dart';
import 'package:flutter_payment_method/screens/stripe/stripe_service/stripe_service.dart';
import 'package:flutter_payment_method/utils/app_constants.dart';
import 'package:flutter_payment_method/utils/app_helper.dart';
import 'package:flutter_payment_method/utils/input_formatter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stripe_payment/stripe_payment.dart';

class StripeCardPaymentBloc extends AppBloc {
  final cardNumberWarning = BlocDefault<String>();
  final expDateWarning = BlocDefault<String>();
  final cvcWarning = BlocDefault<String>();
  final focusInputText = BlocDefault<bool>();
  final validInput = BlocDefault<bool>();
  final cardType = BlocDefault<CardType>();
  final finishTransaction = Bloc<String, bool>();
  final loading = BlocDefault<bool>();

  //card input valid
  final cardNumberInput = Bloc<String, bool>();
  final expDateInput = Bloc<String, bool>();
  final cvcInput = Bloc<String, bool>();
  int _month, _year;
  double totalAmount = 0;
  String secret;

  StripeCardPaymentBloc() {
    initLogic();
  }

  @override
  void dispose() {
    cardNumberWarning.dispose();
    focusInputText.dispose();
    expDateWarning.dispose();
    cvcWarning.dispose();
    validInput.dispose();
    cardType.dispose();
    cardNumberInput.dispose();
    expDateInput.dispose();
    cvcInput.dispose();
    loading.dispose();
  }

  @override
  void initLogic() {
    cardNumberInput.logic = (input) => input.map((value) {
          return value.isNotEmpty;
        });

    /// valid country
    expDateInput.logic = (input) => input.map((value) {
          return value.isNotEmpty;
        });

    /// valid phone
    cvcInput.logic = (input) => input.map((value) {
          return value.isNotEmpty;
        });

    Rx.combineLatest3(
        cardNumberInput.stream, expDateInput.stream, cvcInput.stream,
        (number, exp, cvv) {
      validInput.push(number && exp && cvv);
    }).listen(null);
  }

  void validateInputField(List<String> value, BuildContext context) {
    bool numberValidate = false, dateValid = false, cvcValid = false;

    cvcValid = validateCVC(value[2]);

    numberValidate = validateCardNum(value[0]);

    dateValid = validateDate(value[1]);

    if (numberValidate && dateValid && cvcValid) {
      if (secret.isEmpty &&
          AppConstant.stripeSecretKey.isEmpty &&
          AppConstant.stripePublishableKey.isEmpty) {
        AppHelper.showToaster(
            'Please check your secret code and stripe key.', context);
      } else {

        loading.push(true);
        String number = CardUtils.getCleanedNumber(value[0]);

        /// payment with card info
        StripeService.payViaExistingCard(
          amount: totalAmount.toInt().toString(),
          currency: 'vnd',
          secret: secret,
          card: CreditCard(
            name: 'user email',
            number: number,
            expMonth: _month,
            expYear: _year,
            cvc: value[2],
          ),
        ).then((value) {
          if (value.success) {
            /// finish transaction with client secret stripe code
            AppHelper.showToaster('Payment success', context);
            Navigator.of(context).pop();
          } else {
            loading.push(false);
            if (value.message.compareTo('error') == 0) {
              AppHelper.showToaster('your error message ', context);
            } else if (value.message.compareTo('authenticationFailed') == 0) {
              AppHelper.showToaster('your error message ', context);
            } else if (value.message.compareTo('expired') == 0) {
              AppHelper.showToaster('your error message ', context);
            } else if (value.message.compareTo('cvc') == 0) {
              AppHelper.showToaster('your error message ', context);
            } else if (value.message.compareTo('processing') == 0) {
              AppHelper.showToaster('your error message ', context);
            } else if (value.message.compareTo('number') == 0) {
              AppHelper.showToaster('your error message ', context);
            } else {
              AppHelper.showToaster(value.message, context);
            }
          }
        }).catchError((error) {
          print('error stripe: ${error.toString()}');
        });
      }
    } else {
      print('data invalid');
    }
  }

  bool validateDate(String value) {
    bool result = true;
    int year;
    int month;

    if (value.isEmpty) {
      //expDateWarning.push(AppLocalizations.of(_context).translate(AppString.titleMonthValid));
      result = false;
    }

    // The value contains a forward slash if the month and year has been
    // entered.
    if (value.contains(new RegExp(r'(\/)'))) {
      var split = value.split(new RegExp(r'(\/)'));
      // The value before the slash is the month while the value to right of
      // it is the year.
      month = int.parse(split[0]);
      year = int.parse(split[1]);

      _month = month;
      _year = year;
    } else {
      // Only the month was entered
      month = int.parse(value.substring(0, (value.length)));
      year = -1; // Lets use an invalid year intentionally
    }

    if ((month < 1) || (month > 12)) {
      // A valid month is between 1 (January) and 12 (December)
      expDateWarning.push('month is invalid');
      result = false;
    }

    var fourDigitsYear = convertYearTo4Digits(year);
    if ((fourDigitsYear < 1) || (fourDigitsYear > 2099)) {
      // We are assuming a valid should be between 1 and 2099.
      // Note that, it's valid doesn't mean that it has not expired.
      expDateWarning.push('year is invalid');
      result = false;
    }

    if (!hasDateExpired(month, year)) {
      expDateWarning.push('card is expired');
      result = false;
    }

    return result;
  }

  /// validate data input

  bool validateCardNum(String input) {
    bool result = true;

    input = CardUtils.getCleanedNumber(input);

    if (input.isEmpty)
      result = false;
    else if (input.length < 14 || input.length > 16) {
      cardNumberWarning.push('card number is invalid');
      result = false;
    }

    return result;
  }

  /// Convert the two-digit year to four-digit year if necessary
  int convertYearTo4Digits(int year) {
    if (year < 100 && year >= 0) {
      var now = DateTime.now();
      String currentYear = now.year.toString();
      String prefix = currentYear.substring(0, currentYear.length - 2);
      year = int.parse('$prefix${year.toString().padLeft(2, '0')}');
    }
    return year;
  }

  bool hasDateExpired(int month, int year) {
    return !(month == null || year == null) && isNotExpired(year, month);
  }

  bool isNotExpired(int year, int month) {
    // It has not expired if both the year and date has not passed
    return !hasYearPassed(year) && !hasMonthPassed(year, month);
  }

  bool hasYearPassed(int year) {
    int fourDigitsYear = convertYearTo4Digits(year);
    var now = DateTime.now();
    // The year has passed if the year we are currently is more than card's
    // year
    return fourDigitsYear < now.year;
  }

  bool hasMonthPassed(int year, int month) {
    var now = DateTime.now();
    // The month has passed if:
    // 1. The year is in the past. In that case, we just assume that the month
    // has passed
    // 2. Card's month (plus another month) is more than current month.
    return hasYearPassed(year) ||
        convertYearTo4Digits(year) == now.year && (month < now.month + 1);
  }

  /// valid cvc
  bool validateCVC(String value) {
    bool result = true;

    if (value.isEmpty) {
      //cvcWarning.push(AppLocalizations.of(_context).translate(AppString.titleCvcValid));
      result = false;
    } else if (value.length < 3 || value.length > 4) {
      cvcWarning.push('cvc is invalid');
      result = false;
    }
    return result;
  }
}
