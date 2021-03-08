import 'package:flutter/material.dart';
import 'package:flutter_payment_method/model/product_model.dart';
import 'package:flutter_payment_method/utils/app_assets.dart';
import 'package:flutter_payment_method/utils/app_helper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'revenue_purchase_bloc.dart';

class RevenueCatPurchase extends StatefulWidget {
  @override
  _RevenueCatPurchaseState createState() => _RevenueCatPurchaseState();
}

class _RevenueCatPurchaseState extends State<RevenueCatPurchase> {
  final bloc = RevenuePaymentBloc();

  final List<ProductModel> listProduct = [
    ProductModel(imageAsset: AppImages.beemo, name: "Beemo", price: "99.000đ"),
    ProductModel(
        imageAsset: AppImages.teemoPro, name: "Teemo Omega", price: "99.000đ"),
    ProductModel(
        imageAsset: AppImages.teemoVip,
        name: "Teemo Phong Linh",
        price: "99.000đ"),
  ];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    bloc.context = context;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'IAP with RevenueCat'.toUpperCase(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.blueGrey,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.blueGrey,
          ),
          iconSize: 24,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(AppImages.logoRevenueCat),
          ),
          Column(
            children: [
              FittedBox(
                child: Row(
                  children: [
                    for (var pro in listProduct)
                      ItemProduct(
                        product: pro,
                      )
                  ],
                ),
              ),
              SizedBox(
                height: 50,
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blueGrey),
                ),
                child: Text(
                  'Payment'.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  AppHelper.showToaster("Please check logic", context);
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> initPlatformState() async {
    await Purchases.setDebugLogsEnabled(true);
    await Purchases.setup("your revenue key", appUserId: "app user id");
  }
}

class ItemProduct extends StatelessWidget {
  final ProductModel product;

  ItemProduct({this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 150,
          height: 250,
          child: Image.asset(
            product.imageAsset,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          product.name,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        Text(
          product.price,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
