import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppAlertDialog extends StatelessWidget {
  final title;
  final message;
  final Function onClose;

  const AppAlertDialog({Key key, this.title = "Alert", this.message, this.onClose})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            onClose();
            Navigator.pop(context);
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}