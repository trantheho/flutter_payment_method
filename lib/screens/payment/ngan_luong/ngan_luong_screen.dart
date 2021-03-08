import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'ngan_luong_bloc.dart';

class NganLuongScreen extends StatefulWidget {
  @override
  _NganLuongScreenState createState() => _NganLuongScreenState();
}

class _NganLuongScreenState extends State<NganLuongScreen> {
  final bloc = NganLuongBloc();

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Stack(
        children: [
          SafeArea(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '250.000đ',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextButton(
                          onPressed: () =>
                              bloc.checkoutNganLuong(250000, context),
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.deepOrange),
                          child: Text(
                            'Pay now'.toUpperCase(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          StreamBuilder<bool>(
            stream: bloc.loading.stream,
            initialData: false,
            builder: (context, snapshot) {
              return snapshot.data
                  ? Container(
                      color: Colors.black.withOpacity(0.4),
                      child: Center(
                        child: SpinKitFadingCircle(
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    )
                  : SizedBox();
            },
          ),
        ],
      ),
    );
  }

}
