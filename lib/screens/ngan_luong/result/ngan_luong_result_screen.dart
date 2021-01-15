import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_payment_method/screens/ngan_luong/result/ngan_luong_result_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NganLuongResultScreen extends StatefulWidget {
  final String url;
  final String token;
  final int amount;

  NganLuongResultScreen({this.url, this.token, this.amount,});

  @override
  _NganLuongResultScreenState createState() => _NganLuongResultScreenState();
}

class _NganLuongResultScreenState extends State<NganLuongResultScreen> {
  final bloc = NganLuongResultBloc();

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();



  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  void dispose() {
    bloc.dispose();
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
        body: WebView(
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
      ),
    );
  }




}
