/*
 * Developed by Ti Ti on 1/20/21 2:54 PM.
 * Last modified 1/20/21 2:54 PM.
 * Copyright (c) 2021. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:flutter_payment_method/screens/calendar/expand_table_calendar.dart';
import 'package:flutter_payment_method/utils/app_assets.dart';
import 'package:flutter_payment_method/utils/app_colors.dart';
import 'package:flutter_payment_method/utils/app_helper.dart';
import 'package:intl/intl.dart';

class WeekCalendarScreen extends StatefulWidget {

  @override
  _WeekCalendarScreenState createState() => _WeekCalendarScreenState();
}

class _WeekCalendarScreenState extends State<WeekCalendarScreen> {
  final now = DateTime.now();
  CalendarController calendarController;
  DateTime selectedDay;

  @override
  void initState() {
    calendarController = CalendarController();
    selectedDay = now;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.verdigris,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          iconSize: 24,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('App Bar'),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: [
            TableCalendar(
              calendarController: calendarController,
              onDaySelected: (day, events, holiday){
                selectedDay = day;
              },
              onMonthChange: (dateTime){

              },
              dayOfWeekInHeader: true,
              rowHeight: AppHelper.responsiveSize(context, value: 35),
              startingDayOfWeek: StartingDayOfWeek.sunday, // set starting day
              initialCalendarFormat: CalendarFormat.week,
              availableCalendarFormats: {CalendarFormat.week: 'Week'}, // set type week
              bottomVisible: false, // button drag like event calendar
              calendarStyle: CalendarStyle(
                outsideDaysVisible: true,
                weekdayStyle: TextStyle(
                  fontSize: AppHelper.screenWidth(context) <= 375 ? 11 : 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                weekendStyle: TextStyle(
                    fontSize: AppHelper.screenWidth(context) <= 375 ? 11 : 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black),
                holidayStyle: TextStyle(
                    fontSize: AppHelper.screenWidth(context) <= 375 ? 11 : 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.terraCotta),
                eventDayStyle: TextStyle(
                    fontSize: AppHelper.screenWidth(context) <= 375 ? 11 : 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.terraCotta),
                selectedStyle: TextStyle(
                    fontSize: AppHelper.screenWidth(context) <= 375 ? 11 : 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
                selectedColor: AppColors.terraCotta,
                selectedDayBoxShapeCircle: true,
                cellMargin: EdgeInsets.zero,
                todayStyle:  TextStyle(
                    fontSize: AppHelper.screenWidth(context) <= 375 ? 11 : 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
                todayColor: AppColors.terraCotta.withOpacity(0.5),
                highlightToday: true,
                outsideWeekendStyle: TextStyle(
                    fontSize: AppHelper.screenWidth(context) <= 375 ? 11 : 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey),
                outsideStyle: TextStyle(
                    fontSize: AppHelper.screenWidth(context) <= 375 ? 11 : 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey),
                markersColor: Colors.transparent, // marker point
                makerSize: 4.0,
              ),
              locale: 'en',
              daysOfWeekStyle: DaysOfWeekStyle(
                isUpperCase: true,
                weekendStyle: TextStyle(
                    fontSize: AppHelper.screenWidth(context) <= 375 ? 11 : 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
                weekdayStyle: TextStyle(
                    fontSize: AppHelper.screenWidth(context) <= 375 ? 11 : 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              headerStyle: HeaderStyle(
                leftChevronIcon: Icon(Icons.arrow_back, color: Colors.grey, size: 24,),
                rightChevronIcon: Icon(Icons.arrow_forward, color: Colors.grey, size: 24,),
                centerHeaderTitle: true,
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
                titleTextBuilder: (dateTime, _){
                  return DateFormat.MMMM().format(dateTime).toUpperCase();
                },
                headerPadding: EdgeInsets.only(top: 40 + MediaQuery.of(context).padding.top, bottom: 10),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      AppImages.headerCalendarBackground,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

