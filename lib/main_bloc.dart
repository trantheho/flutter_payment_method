/*
 * Developed by Ti Ti on 11/16/20 11:03 AM.
 * Last modified 11/16/20 11:03 AM.
 * Copyright (c) 2020. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'base/bloc.dart';

class MainBloc extends AppBloc{
  MainBloc._private() {
    initLogic();
  }
  static final instance = MainBloc._private();

  bool isLogin = false;
  bool showDialog = false;

  GlobalKey<NavigatorState> _globalKey;

  BuildContext _context;

  void initContext(BuildContext context, GlobalKey globalKey) {
    _context = context;
    _globalKey = globalKey;
  }

  GlobalKey<NavigatorState> getKey(){
    return _globalKey;
  }

  BuildContext getContext() {
    if (_context == null)
      throw Exception(
          'You need to init context after root widget initialized.');
    return _context;
  }

  BuildContext getOverLayContext(){
    if (_globalKey == null)
      throw Exception(
          'You need to init context after root widget initialized.');
    return _globalKey.currentState.overlay.context;
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  void initLogic() {
    // TODO: implement initLogic
  }

}