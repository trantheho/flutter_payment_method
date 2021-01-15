
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_payment_method/network/network_util.dart';
import 'package:flutter_payment_method/screens/main_screen.dart';
import 'package:flutter_payment_method/utils/app_helper.dart';
import 'package:flutter_payment_method/generated/l10n.dart';
import 'package:flutter_payment_method/main_bloc.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

Future<void> initMyApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final globalScaffoldKey = GlobalKey<NavigatorState>();
  final mainBloc = MainBloc.instance;
  StreamSubscription networkSubscription;


  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => postBuild(context));
    return AnnotatedRegion(
      value: AppHelper.statusBarOverlayUI(Brightness.light),
      child: MaterialApp(
        localizationsDelegates: [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: Locale(ui.window.locale?.languageCode),
        supportedLocales: S.delegate.supportedLocales,
        navigatorKey: globalScaffoldKey,
        debugShowCheckedModeBanner: false,
        title: 'All Payment Method',
        home: Scaffold(
          body: FutureBuilder(
              future: Future.delayed(Duration(seconds: 1)),
              builder: (context, seconds) {

                if(seconds.connectionState == ConnectionState.done){
                  return MainScreen();
                }
                else{
                  return Container(
                    color: Colors.blueGrey,
                    child: Center(
                      child: Text(
                        'Payment method in app',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }
              }),
        ),
      ),
    );
  }


  void postBuild(BuildContext context) {
    mainBloc.initContext(context, globalScaffoldKey);
    checkNetworkResult();
  }

  void checkNetworkResult() {
    networkSubscription?.cancel();
    networkSubscription = NetworkingUtil().networkStatus.stream.distinct().listen((network){
      Logging.log('connect network: $network');
      if(!network){
        AppHelper.showNetworkDialog(
            'Network',
            'Network disconnect');
      }
    });
  }

}