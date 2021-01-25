/*
 * Developed by Ti Ti on 1/20/21 2:54 PM.
 * Last modified 1/20/21 2:54 PM.
 * Copyright (c) 2021. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:flutter_payment_method/model/note_model.dart';
import 'package:flutter_payment_method/screens/calendar/expand_table_calendar.dart';
import 'package:flutter_payment_method/screens/calendar/month/month_calendar_bloc.dart';
import 'package:flutter_payment_method/utils/app_assets.dart';
import 'package:flutter_payment_method/utils/app_colors.dart';
import 'package:flutter_payment_method/utils/app_helper.dart';
import 'package:flutter_payment_method/widgets/divider_line.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class MonthCalendarScreen extends StatefulWidget {

  @override
  _MonthCalendarScreenState createState() => _MonthCalendarScreenState();
}

class _MonthCalendarScreenState extends State<MonthCalendarScreen> {
  final bloc = MonthCalendarBloc();
  final now = DateTime.now();
  CalendarController calendarController;
  DateTime selectedDay;

  @override
  void initState() {
    calendarController = CalendarController();
    selectedDay = now;
    bloc.genListItem(now);
    super.initState();
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
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
        title: Text('Month Calendar'),
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
                bloc.genListItem(selectedDay);
              },
              onMonthChange: (dateTime){
                bloc.genListItem(dateTime);
              },
              dayOfWeekInHeader: true,
              rowHeight: AppHelper.responsiveSize(context, value: 35),
              startingDayOfWeek: StartingDayOfWeek.sunday, // set starting day
              availableCalendarFormats: {CalendarFormat.month: 'Month'}, // set type month
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

            ListItem(
              bloc: bloc,
            ),

          ],
        ),
      ),
    );
  }
}

class ListItem extends StatefulWidget {
  final MonthCalendarBloc bloc;

  ListItem({this.bloc});

  @override
  _ListItemState createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: AppColors.white,
        child: StreamBuilder(
            stream: widget.bloc.loading.stream,
            initialData: true,
            builder: (context,AsyncSnapshot<bool> loadingPage) {
              if(loadingPage.data){
                return Center(
                  child: SpinKitFadingCircle(
                    color: AppColors.greyishBrown,
                    size: 40,
                  ),
                );
              }
              else{
                return StreamBuilder<List<NoteModel>>(
                    stream: widget.bloc.listNote.stream,
                    builder: (context, noteData) {
                      if(noteData.data != null){
                        if(noteData.data.length != 0){
                          return ListView.builder(
                            itemCount: noteData.data.length,
                            padding: EdgeInsets.only(bottom: 50),
                            itemBuilder: (context, index){
                              return ItemNote(
                                note: noteData.data[index],
                                index: index,
                              );
                            },
                          );
                        }
                        else{
                          return Center(
                            child: Text(
                              'No Log',
                              style: TextStyle(
                                  color: AppColors.nightRider,
                                  fontSize: 16
                              ),
                            ),
                          );
                        }
                      }
                      else
                        return SizedBox();
                    }
                );
              }
            }
        ),
      ),
    );
  }
}


class ItemNote extends StatelessWidget {
  final NoteModel note;
  final int index;

  ItemNote({this.note, this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: index.isOdd ? AppColors.terraCotta.withOpacity(0.07) : Colors.white,
      child: _buildItemContent(),
    );
  }


  Widget _buildLeading(){
    return Column(
      children: [
        DividerLine(
          height: 10,
          width: 1,
          color: AppColors.greyish.withOpacity(0.5),
        ),
        SizedBox(height: 8,),

        Image.asset(
          AppImages.icBookmark,
          color: AppColors.greyish,
          width: 18,
        ),
        SizedBox(height: 4,),
        Expanded(
          child: DividerLine(
            width: 1,
            color: AppColors.greyish.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildItemContent(){
    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20,),
        child: Row(
          children: [
            _buildLeading(),

            SizedBox(width: 15,),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8,),
                  Row(
                    children: [
                      Text(
                        AppHelper.formatDateTime(note.createAt.toLocal()),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.terraCotta,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      Spacer(),

                      Icon(
                        Icons.access_time_outlined,
                        color: AppColors.greyish,
                        size: 20,
                      ),

                      SizedBox(width: 10,),

                      Text(
                        AppHelper.formatDateToTimeHHMM(note.createAt.toLocal()).toLowerCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),

                  SizedBox(height: 10,),

                  Text(
                    note.title,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w700
                    ),
                  ),

                  SizedBox(height: 20,),
                ],
              ),
            )
          ],
        ),
      ),
    );

  }
}



