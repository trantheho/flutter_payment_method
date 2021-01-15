/*
 * Developed by Cuong Truong on 6/5/20 11:47 AM.
 * Last modified 6/5/20 11:02 AM.
 * Copyright (c) 2020 BeeSight Soft. All rights reserved.
 */

import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_payment_method/service/hive_store.dart';

class Api {
  final Dio dio = new Dio();


  Api() {
    if (!kReleaseMode) {
      dio.interceptors.add(LogInterceptor(responseBody: true));
    }
  }

  Future<Map<String, String>> getHeader() async {
    return {
      "content-type": "application/json",
    };
  }

  Future<Map<String, String>> getAuthorizedHeader() async {
    Map<String, String> _header = await getHeader();
    String accessToken = await HiveStore.instance.getAccessToken();
    _header.addAll({
      "content-type": "application/json",
      "Authorization": "Bearer $accessToken",
    });
    return _header;
  }

  Future<Response<dynamic>> dioExceptionWrapper(Function() dioApi) async {
    try {
      return await dioApi();
    } catch (error) {
      var errorMessage = error.toString();
      if (error is DioError && error.type == DioErrorType.RESPONSE) {
        final response = error.response;
        errorMessage = 'Code ${response.statusCode} - ${response.statusMessage} ${response.data != null ? '\n' : ''} ${response.data}';
        throw new DioError(
            request: error.request,
            response: error.response,
            type: error.type,
            error: errorMessage);
      }
      throw error;
    }
  }
}
