/*
 * Developed by TiTi on 10/2/20 10:27 AM.
 * Last modified 9/29/20 2:45 PM.
 * Copyright (c) 2020 Beesight Soft. All rights reserved.
 */

import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_payment_method/screens/one_pay/result/one_pay_result_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webview_flutter/webview_flutter.dart';


class OnePayResultScreen extends StatefulWidget {
  final String url;

  OnePayResultScreen({this.url});

  @override
  OnePayResultScreenState createState() => OnePayResultScreenState();
}

class OnePayResultScreenState extends State<OnePayResultScreen> {
  final bloc = OnePayResultBloc();
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  String authorUrl;
  bool fail = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          leading: InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        body: Stack(
          children: [
            WebView(
              initialUrl: widget.url,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
                bloc.webViewController = webViewController;
              },
              onPageFinished: (url){
                print("url: $url");
                bloc.handleUrlChange(url, context);
              },

            ),

            StreamBuilder(
              initialData: false,
              stream: bloc.loading.stream,
              builder: (context, snapshot) {
                if(snapshot.hasData && snapshot.data){
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
            ),


          ],
        ),
      ),
    );
  }


}
