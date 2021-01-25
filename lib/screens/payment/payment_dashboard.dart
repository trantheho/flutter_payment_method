import 'package:flutter/material.dart';
import 'package:flutter_payment_method/screens/ngan_luong/ngan_luong_screen.dart';
import 'package:flutter_payment_method/screens/one_pay/one_pay_screen.dart';
import 'package:flutter_payment_method/screens/stripe/stripe_card_payment_screen.dart';
import 'package:flutter_payment_method/utils/app_helper.dart';
import 'package:flutter_payment_method/utils/app_screen_name.dart';

class PaymentDashboard extends StatefulWidget {
  @override
  _PaymentDashboardState createState() => _PaymentDashboardState();
}

class _PaymentDashboardState extends State<PaymentDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Payment Dashboard'.toUpperCase(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.blueGrey,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blueGrey,),
          iconSize: 24,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50,),

              Text(
                'Out App Method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.blueGrey,
                ),
              ),

              SizedBox(height: 20,),

              _buildItemPayment(
                  title: 'Ngân Lượng',
                  onPressed: (){
                    AppHelper.navigatePush(
                      context,
                      AppScreenName.nganLuong,
                      NganLuongScreen(),
                    );
                  }
              ),

              SizedBox(height: 10,),

              _buildItemPayment(
                  title: 'MoMo',
                  onPressed: (){

                  }
              ),

              SizedBox(height: 10,),

              _buildItemPayment(
                  title: 'Stripe',
                  onPressed: (){

                    AppHelper.navigatePush(
                      context,
                      AppScreenName.stripe,
                      StripeCardPaymentScreen(
                        clientSecret: '',
                        totalAmount: 250000,
                      ),
                    );

                  }
              ),

              SizedBox(height: 10,),


              _buildItemPayment(
                  title: 'One Pay',
                  onPressed: (){

                    AppHelper.navigatePush(
                      context,
                      AppScreenName.onePay,
                      OnePayScreen(),
                    );
                  }
              ),

              SizedBox(height: 10,),

              _buildItemPayment(
                  title: 'Hyper Pay',
                  onPressed: (){

                  }
              ),

              SizedBox(height: 20,),

              Text(
                'In App Purchase',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.blueGrey,
                ),
              ),

              SizedBox(height: 20,),

              _buildItemPayment(
                  title: 'In App Purchase',
                  onPressed: (){

                  }
              ),



            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemPayment({String title, Function onPressed}){
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: RawMaterialButton(
        onPressed: () => onPressed(),
        child: Row(
          children: [
            SizedBox(width: 10,),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.black,
              size: 24,
            ),
            SizedBox(width: 10,),
          ],
        ),
      ),
    );
  }
}
