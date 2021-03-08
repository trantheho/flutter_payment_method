/*
 * Developed by TiTi on 9/22/20 11:38 AM.
 * Last modified 8/27/20 6:02 PM.
 * Copyright (c) 2020 Beesight Soft. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_payment_method/utils/app_assets.dart';
import 'package:flutter_payment_method/utils/app_helper.dart';
import 'package:flutter_payment_method/utils/input_formatter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'stripe_card_payment_bloc.dart';
import 'stripe_service/stripe_service.dart';

class StripeCardPaymentScreen extends StatefulWidget {
  final String clientSecret;
  final double totalAmount;

  StripeCardPaymentScreen({
    this.clientSecret,
    this.totalAmount,
  });

  @override
  _StripeCardPaymentScreenState createState() => _StripeCardPaymentScreenState();
}

class _StripeCardPaymentScreenState extends State<StripeCardPaymentScreen> {
  final bloc = StripeCardPaymentBloc();
  List<TextEditingController> textControllers = List<TextEditingController>(3);
  List<FocusNode> focusNodes = List<FocusNode>(3);
  String cardNumber = '', expDate = '', cvc = '';


  @override
  void initState() {
    super.initState();
    StripeService.init();

    bloc.totalAmount = widget.totalAmount;
    bloc.secret = widget.clientSecret;
    for (int i = 0; i < textControllers.length; i++ ) {
      textControllers[i] = TextEditingController();
    }
    for (int i = 0; i < focusNodes.length; i++ ) {
      focusNodes[i] = FocusNode();
    }

    focusNodes.forEach((focus) {
      focus.addListener(() {
        if(focus.hasFocus){
          bloc.focusInputText.push(false);
        }
        else{
          bloc.focusInputText.push(true);
        }
      });
    });

    textControllers[0].addListener(_getCardTypeFromNumber);

  }

  @override
  void dispose() {
    super.dispose();
    textControllers.forEach((element) { element.dispose();});
    focusNodes.forEach((element) {element.dispose();});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          leading: InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          title: Text(
            'Credit card payment'.toUpperCase(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return GestureDetector(
      onTap: (){
        AppHelper.hideKeyboard(context);
      },
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    children: [
                      SizedBox(height: 40,),
                      /// card number input
                      _buildInputFieldCardNumber(
                        AppImages.icBankCard,
                        'Card number',
                        textControllers[0],
                        focusNodes[0],
                        '4242 4242 4242 4242',
                        TextInputAction.next,
                        TextInputType.number,
                        bloc.cardNumberWarning.stream,
                          (numberChange){
                            cardNumber = numberChange;
                            bloc.cardNumberWarning.push('');
                            bloc.cardNumberInput.push(cardNumber);
                          },
                          (submitted){
                            focusNodes[1].requestFocus();
                          },
                        ),

                      /// exp date input
                      _buildInputFieldCardMonth(
                        AppImages.icDateValidCard,
                        'Exp date',
                        textControllers[1],
                        focusNodes[1],
                        'MM/YY',
                        TextInputAction.next,
                        TextInputType.number,
                        bloc.expDateWarning.stream,
                          (expChange) {
                            expDate = expChange;
                            bloc.expDateWarning.push('');
                            bloc.expDateInput.push(expDate);
                          },
                          (submitted) {
                            focusNodes[2].requestFocus();
                          },
                        ),

                      /// cvv input
                      _buildInputFieldCardCVV(
                        AppImages.icPassword,
                        'CVC',
                        textControllers[2],
                        focusNodes[2],
                        'CVC',
                        TextInputAction.done,
                        TextInputType.number,
                        bloc.cvcWarning.stream,
                          (cvvChange) {
                            cvc = cvvChange;
                            bloc.cvcWarning.push('');
                            bloc.cvcInput.push(cvc);
                          },
                          (submitted) {
                            // payment stripe with card info
                            bloc.validateInputField(
                                [cardNumber, expDate, cvc], context);
                          },
                        ),

                    ],
                  )
                ),
              ],
            ),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Spacer(),
                  _buildButtonPay(),
                ],
              ),
            ),
            StreamBuilder(
              initialData: false,
              stream: bloc.loading.stream,
              builder: (context, snapshot) {
                if(snapshot.data){
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                    ),
                    child: SpinKitFadingCircle(color: Colors.white),
                    alignment: Alignment.center,
                  );
                }
                else{
                  return SizedBox();
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildButtonPay(){
    return StreamBuilder(
      stream: bloc.focusInputText.stream,
      initialData: true,
      builder: (context,AsyncSnapshot<bool> snapshot) {
        return Visibility(
          visible: snapshot.data,
          child: StreamBuilder(
              stream: bloc.validInput.stream,
              initialData: false,
              builder: (context,AsyncSnapshot<bool> active) {
                return Container(
                  height: 50,
                  margin: EdgeInsets.only(left: 20, right: 20, bottom: 4),
                  decoration: BoxDecoration(
                    color: active.data ? Colors.deepOrange : Colors.deepOrange.withOpacity(0.32),
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  child: MaterialButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Center(
                        child: Text(
                          'pay now'.toUpperCase(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      onPressed: () {
                        bloc.validateInputField([cardNumber, expDate, cvc], context);
                      }),
                );
              }
          ),
        );
      }
    );
  }

  Widget _buildInputFieldCardNumber(_icon, _title, _controller, _focusNode, _placeholder, _textInputAction, _textInputType, _bloc, [Function(String) _onChanged, Function(String) _onSubmitted]) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 10,
      ),
      width: 335,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            _title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          StreamBuilder(
              stream: _bloc,
              initialData: '',
              builder: (context, snapshot) {
                return Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: (snapshot.hasData && snapshot.data.isNotEmpty) ? Colors.red : Colors.blueGrey, width: 1),
                    borderRadius: BorderRadius.circular(5),
                    color: (snapshot.hasData && snapshot.data.isNotEmpty) ? Colors.red : Colors.white,
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: StreamBuilder(
                          stream: bloc.cardType.stream,
                          initialData: CardType.Others,
                          builder: (context,AsyncSnapshot<CardType> cardType) {
                            // set image card with card type

                            if(cardType.data == CardType.Visa){
                              _icon = AppImages.icVisa;
                            }
                            else if(cardType.data == CardType.Master){
                              _icon = AppImages.icMaster;
                            }
                            else if(cardType.data == CardType.Verve){
                              _icon = AppImages.icVerve;
                            }
                            else if(cardType.data == CardType.DinersClub){
                              _icon = AppImages.icDinnerClub;
                            }
                            else if(cardType.data == CardType.Discover){
                              _icon = AppImages.icDiscover;
                            }
                            else if(cardType.data == CardType.AmericanExpress){
                              _icon = AppImages.icAmericanExpress;
                            }
                            else if(cardType.data == CardType.Jcb){
                              _icon = AppImages.icJCB;
                            }
                            else if(cardType.data == CardType.Union){
                              _icon = AppImages.icUnion;
                            }
                            else{
                              _icon = AppImages.icBankCard;
                            }

                            return Image.asset(
                              _icon,
                              fit: BoxFit.fill,
                              //color: Color.fromRGBO(118, 76, 196, 1),
                              width: (cardType.data == CardType.Visa || cardType.data == CardType.Master || cardType.data == CardType.Verve
                              || cardType.data == CardType.Discover || cardType.data == CardType.DinersClub || cardType.data == CardType.Jcb
                              || cardType.data == CardType.AmericanExpress || cardType.data == CardType.Union)
                                  ? 35.0 : 20.0,
                              height: (cardType.data == CardType.Visa) ? 15.0 :  ((cardType.data == CardType.Master) ? 20.0 : 20.0),
                            );
                          }
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        width: 1,
                        height: 30,
                        color: Colors.blueGrey,
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(left: 10),
                          child: TextField(
                            maxLines: 1,
                            controller: _controller,
                            focusNode: _focusNode,
                            onChanged: (value){
                              _onChanged(value);
                            },
                            inputFormatters: [
                              WhitelistingTextInputFormatter.digitsOnly,
                              new LengthLimitingTextInputFormatter(16),
                              new CreditCardNumberInputFormatter(),
                            ],
                            textAlignVertical: TextAlignVertical.center,
                            textAlign: TextAlign.left,
                            textInputAction: TextInputAction.next,
                            keyboardType: _textInputType,
                            decoration: InputDecoration(
                              isDense: true,
                              filled: false,
                              border: InputBorder.none,
                              hintText: _placeholder,
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              hintMaxLines: 1,
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            onSubmitted: (value) {
                              _onSubmitted(value);
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }
          ),
          SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 4, bottom: 4),
            child: StreamBuilder(
                stream: _bloc,
                initialData: '',
                builder: (context,snapshot) {
                  if(snapshot.hasData && snapshot.data.isNotEmpty){
                    return Text(
                      snapshot.data,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                      maxLines: 2,
                    );
                  }
                  else{
                    return SizedBox();
                  }
                }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputFieldCardMonth(_icon, _title, _controller, _focusNode, _placeholder, _textInputAction, _textInputType, _bloc, [Function(String) _onChanged, Function(String) _onSubmitted]) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 10,
      ),
      width: 335,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            _title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          StreamBuilder(
              stream: _bloc,
              initialData: '',
              builder: (context, snapshot) {
                return Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: (snapshot.hasData && snapshot.data.isNotEmpty) ? Colors.red : Colors.blueGrey, width: 1),
                    borderRadius: BorderRadius.circular(5),
                    color: (snapshot.hasData && snapshot.data.isNotEmpty) ? Colors.red : Colors.white,
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: Image.asset(
                          _icon,
                          fit: BoxFit.cover,
                          color: Color.fromRGBO(118, 76, 196, 1),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        width: 1,
                        height: 30,
                        color: Colors.blueGrey,
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(left: 10),
                          child: TextField(
                            maxLines: 1,
                            controller: _controller,
                            focusNode: _focusNode,
                            onChanged: (value){
                              _onChanged(value);
                            },
                            inputFormatters: [
                              WhitelistingTextInputFormatter.digitsOnly,
                              new LengthLimitingTextInputFormatter(4),
                              new CreditCardMonthInputFormatter(),
                            ],
                            textAlignVertical: TextAlignVertical.center,
                            textAlign: TextAlign.left,
                            textInputAction: TextInputAction.next,
                            keyboardType: _textInputType,
                            decoration: InputDecoration(
                              isDense: true,
                              filled: false,
                              border: InputBorder.none,
                              hintText: _placeholder,
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              hintMaxLines: 1,
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            onSubmitted: (value) {
                              _onSubmitted(value);
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }
          ),
          SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 4, bottom: 4),
            child: StreamBuilder(
                stream: _bloc,
                initialData: '',
                builder: (context,snapshot) {
                  if(snapshot.hasData && snapshot.data.isNotEmpty){
                    return Text(
                      snapshot.data,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                      maxLines: 2,
                    );
                  }
                  else{
                    return SizedBox();
                  }
                }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputFieldCardCVV(_icon, _title, _controller, _focusNode, _placeholder, _textInputAction, _textInputType, _bloc, [Function(String) _onChanged, Function(String) _onSubmitted]) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 10,
      ),
      width: 335,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            _title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          StreamBuilder(
              stream: _bloc,
              initialData: '',
              builder: (context, snapshot) {
                return Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: (snapshot.hasData && snapshot.data.isNotEmpty) ? Colors.red : Colors.blueGrey, width: 1),
                    borderRadius: BorderRadius.circular(5),
                    color: (snapshot.hasData && snapshot.data.isNotEmpty) ? Colors.red : Colors.white,
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: Image.asset(
                          _icon,
                          fit: BoxFit.cover,
                          color: Color.fromRGBO(118, 76, 196, 1),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        width: 1,
                        height: 30,
                        color: Colors.blueGrey,
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(left: 10),
                          child: TextField(
                            maxLines: 1,
                            controller: _controller,
                            focusNode: _focusNode,
                            onChanged: (value){
                              _onChanged(value);
                            },
                            inputFormatters: [
                              WhitelistingTextInputFormatter.digitsOnly,
                              new LengthLimitingTextInputFormatter(4),
                            ],
                            textAlignVertical: TextAlignVertical.center,
                            textAlign: TextAlign.left,
                            textInputAction: TextInputAction.done,
                            keyboardType: _textInputType,
                            decoration: InputDecoration(
                              isDense: true,
                              filled: false,
                              border: InputBorder.none,
                              hintText: _placeholder,
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              hintMaxLines: 1,
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            onSubmitted: (value) {
                              _onSubmitted(value);
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }
          ),
          SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 4, bottom: 4),
            child: StreamBuilder(
                stream: _bloc,
                initialData: '',
                builder: (context,snapshot) {
                  if(snapshot.hasData && snapshot.data.isNotEmpty){
                    return Text(
                      snapshot.data,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                      ),
                      maxLines: 2,
                    );
                  }
                  else{
                    return SizedBox();
                  }
                }
            ),
          ),
        ],
      ),
    );
  }

  void _getCardTypeFromNumber() {
    String input = CardUtils.getCleanedNumber(textControllers[0].text);
    CardType cardType = CardTypeExtension.fromNumber(input);
    bloc.cardType.push(cardType);
    print('card type: $cardType');
  }
}