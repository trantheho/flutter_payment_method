import 'package:flutter/material.dart';
import 'package:flutter_payment_method/screens/calendar/calendar_dashboard.dart';
import 'package:flutter_payment_method/screens/payment/payment_dashboard.dart';
import 'package:flutter_payment_method/utils/app_helper.dart';
import 'package:flutter_payment_method/utils/app_screen_name.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'App method'.toUpperCase(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.blueGrey,
          ),
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
                'Dashboard',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.blueGrey,
                ),
              ),

              SizedBox(height: 20,),

              _buildItemPayment(
                title: 'Calendar',
                onPressed: (){
                  AppHelper.navigatePush(
                      context,
                      AppScreenName.calendarDashboard,
                      CalendarDashboard(),
                    );
                  }
              ),

              SizedBox(height: 20,),

              _buildItemPayment(
                  title: 'Payment',
                  onPressed: (){
                    AppHelper.navigatePush(
                      context,
                      AppScreenName.paymentDashboard,
                      PaymentDashboard(),
                    );
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
