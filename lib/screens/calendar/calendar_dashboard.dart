
import 'package:flutter/material.dart';
import 'package:flutter_payment_method/screens/calendar/event/event_calendar_screen.dart';
import 'package:flutter_payment_method/screens/calendar/month/month_calendar.dart';
import 'package:flutter_payment_method/screens/calendar/week/week_calendar.dart';
import 'package:flutter_payment_method/utils/app_helper.dart';
import 'package:flutter_payment_method/utils/app_screen_name.dart';

class CalendarDashboard extends StatefulWidget {
  @override
  _CalendarDashboardState createState() => _CalendarDashboardState();
}

class _CalendarDashboardState extends State<CalendarDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Calendar Dashboard'.toUpperCase(),
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

              SizedBox(height: 20,),

              _buildItemPayment(
                  title: 'Event calendar',
                  onPressed: (){
                    AppHelper.navigatePush(context, AppScreenName.eventCalendar,
                        EventCalendarScreen());
                  }
              ),

              SizedBox(height: 10,),

              _buildItemPayment(
                  title: 'Month',
                  onPressed: (){
                    AppHelper.navigatePush(context, AppScreenName.monthCalendar,
                        MonthCalendarScreen());
                  }
              ),

              SizedBox(height: 10,),

              _buildItemPayment(
                  title: 'Week',
                  onPressed: (){
                    AppHelper.navigatePush(context, AppScreenName.weekCalendar,
                        WeekCalendarScreen());
                  }
              ),

              SizedBox(height: 10,),

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