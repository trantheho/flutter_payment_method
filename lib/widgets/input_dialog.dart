import 'package:flutter/material.dart';

class InputDialogBuild extends StatefulWidget {
  final String title;
  final Function(EventData) onDataChange;

  InputDialogBuild({this.title, this.onDataChange});

  @override
  _InputDialogBuildState createState() => _InputDialogBuildState();
}

class _InputDialogBuildState extends State<InputDialogBuild> {
  FocusNode focusNode = FocusNode();
  String eventName = '';
  DateTime startTime, endTime;
  DateTime now = DateTime.now();
  bool changed = false;


  @override
  void initState() {
    changed = false;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: GestureDetector(
          onTap: () => null,
          child: Container(
            color: Colors.white,
            height: 280,
            margin: EdgeInsets.only(left: 30, right: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: 10,),

                Text(
                    widget.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black,
                    )
                ),

                Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.grey),
                          color: Colors.grey[50]
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: TextField(
                          keyboardType: TextInputType.text,
                          focusNode: focusNode,
                          textInputAction: TextInputAction.done,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                          onChanged: (value){
                            eventName = value;
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10,),

                _buildSelectStartTime(),

                SizedBox(height: 10,),

                _buildSelectEndTime(),

                SizedBox(height: 10,),

                _buildButton(),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(){
    return Container(
      height: 55,
      color: Colors.deepOrange,
      child: MaterialButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Center(
            child: Text(
              'OK',
              style: TextStyle(
                fontSize: 16,
                letterSpacing: 1.3,
                color: Colors.white,
              ),
            ),
          ),
          onPressed: () {
            if(changed){
              widget.onDataChange(EventData(
                  name: eventName, startTime: startTime, endTime: endTime));
            }
            Navigator.pop(context);
          }),
    );
  }

  Widget _buildSelectStartTime(){
    return Container(
      height: 35,
      color: Colors.blueGrey,
      margin: EdgeInsets.only(left: 50, right: 50),
      child: MaterialButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Center(
            child: Text(
              startTime == null ? 'select start time' : startTime.toString(),
              style: TextStyle(
                fontSize: 13,
                letterSpacing: 1.3,
                color: Colors.white,
              ),
            ),
          ),
          onPressed: () {
            showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
              builder: (BuildContext context, Widget child) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: child,
                );
              },
            ).then((value){
              if(value != null){
                setState(() {
                  changed = true;
                  startTime = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    value.hour,
                    value.minute,
                  );
                });
              }
            });
          }),
    );
  }

  Widget _buildSelectEndTime(){
    return Container(
      height: 35,
      color: Colors.blueGrey,
      margin: EdgeInsets.only(left: 50, right: 50),
      child: MaterialButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Center(
            child: Text(
              endTime == null ? 'select end time' : endTime.toString(),
              style: TextStyle(
                fontSize: 13,
                letterSpacing: 1.3,
                color: Colors.white,
              ),
            ),
          ),
          onPressed: () {
            showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
              builder: (BuildContext context, Widget child) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: child,
                );
              },
            ).then((value){
              if(value != null){
                setState(() {
                  changed = true;
                  endTime = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    value.hour,
                    value.minute,
                  );
                });
              }
            });
          }),
    );
  }

}

class EventData {
  String name;
  DateTime startTime;
  DateTime endTime;

  EventData({this.name, this.startTime, this.endTime});
}