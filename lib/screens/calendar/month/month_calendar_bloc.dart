import 'package:flutter_payment_method/model/note_model.dart';
import 'package:rxdart/rxdart.dart';

class MonthCalendarBloc {
  final listNote = BehaviorSubject<List<NoteModel>>();
  final loading = BehaviorSubject<bool>();




  void dispose(){
    listNote.close();
    loading.close();
  }

  Future<void> genListItem(DateTime dateTime) async{
    loading.add(true);
    await Future.delayed(Duration(seconds: 1));
    final now = DateTime.now();

    final list = List<NoteModel>.generate(5, (index) => NoteModel(
      title: "Item $index",
      description: "Description $index",
      createAt: DateTime(dateTime.year, dateTime.month, dateTime.day, now.hour + index, now.minute),
    ));

    listNote.add(list);
    loading.add(false);

  }




}