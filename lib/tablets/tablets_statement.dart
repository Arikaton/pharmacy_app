import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pharmacy_app/utils/links.dart';
import 'package:pharmacy_app/utils/server_wrapper.dart';
import 'package:pharmacy_app/utils/utils.dart';
import 'package:uuid/uuid.dart';

import '../main.dart';

class TabletsStatement extends StatefulWidget{
  final Map<String, dynamic> data;

  const TabletsStatement({Key key, this.data}) : super(key: key);

  TabletsStatementState createState() => TabletsStatementState();
}

class TabletsStatementState extends State<TabletsStatement>{
  Map<String, String> schedule = Map();
  var controller = StreamController<String>();
  
  @override
  void initState() {
    super.initState();
    controller.stream.listen((value) => _timeChanged(value));
    switch (widget.data["TabletsPerDay"]){
      case 1:
        schedule = {"0": "12:00"};
        break;
      case 2:
        schedule = {"0": "08:00", "1": "20:00"};
        break;
      case 3:
        schedule = {"0": "08:00", "1": "14:00", "2": "20:00"};
        break;
      case 4:
        schedule = {"0": "08:00", "1": "14:00", "2": "17:00", "3": "20:00"};
        break;
      case 5:
        schedule = {"0": "08:00", "1": "12:00", "2": "15:00", "3": "18:00", "4": "20:00"};
        break;
      default:
        for (int i = 0; i < widget.data["TabletsPerDay"] - 1; i++){
          if (i == 0 || i == 1){
            schedule[i.toString()] = "0${8 + i}:00";
          } else
            schedule[i.toString()] = "${8 + i}:00";
        }
        schedule[(widget.data["TabletsPerDay"] - 1).toString()] = "${8 + widget.data["TabletsPerDay"] - 1}:00";
        break;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Шаг 3: Утверждение времени приёма"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () => Utils.launchUrl(References.tabletsPage),
            )
          ],
      ),
      body: Container(
        margin: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text("Из рецепта:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: <Widget>[
                  Text("Количество приёма в день: "),
                  Text(widget.data["TabletsPerDay"].toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Divider(color: Colors.black),
            Expanded(
              child: ListView(
                children: _createTimeRows(),
              ),
              flex: 4,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    child: FlatButton(
                      child: Text("Сохранить"),
                      color: Colors.blue,
                      onPressed: () {
                        saveTablet().then((_) => Navigator.of(context).pushNamedAndRemoveUntil('/HomeLogged', (Route<dynamic> route) => false, arguments: 1));
                      },
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: FlatButton(
                      child: Text("Отменить"),
                      color: Colors.blue,
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil('/HomeLogged', (route) => false, arguments: 1);
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _createTimeRows(){
    print("start creating");
    List<Widget> widgets = List();
    for (int i = 0; i < schedule.length; i++){
      TimeRow newRow = TimeRow(initialTime: schedule[i.toString()], last: i == schedule.length - 1, controller: controller, id: i.toString());
      widgets.add(newRow);
    }
    return widgets;
  }

  _timeChanged(value){
    var splitS = value.split(" ");
    schedule[splitS[0]] = splitS[1];
    List<String> scheduleValues = schedule.values.toList();
    scheduleValues.sort((a, b) => a.compareTo(b));
    schedule.clear();
    for (int i = 0; i < scheduleValues.length; i++){
      schedule[i.toString()] = scheduleValues[i];
    }
    setState(() {});
  }

  Future<void> saveTablet() async {
    LocalStorage localStorage = LocalStorage("tablets");
    await localStorage.ready;
    var newId = Uuid().v1();
    List<dynamic> ids = localStorage.getItem("ids") ?? List<dynamic>();
    ids.add(newId);
    localStorage.setItem("ids", ids);

    var newTablet = {"Id": newId, "Duration": widget.data["Duration"], "RecipeName": widget.data["RecipeName"], "TabletsPerDay": widget.data["TabletsPerDay"], "Schedule": schedule, "DateStart": widget.data["ChosenDate"], "Dosage": widget.data["Dosage"], "HaveNotification": false, "NotificationsON": true, "NotificationIds": null};
    localStorage.setItem(newId, newTablet);
    await ServerTablets.putTablets(newTablet);
  }

}

class TimeRow extends StatelessWidget{
  final id;
  final String initialTime;
  final bool last;
  final StreamController controller;

  const TimeRow({Key key, this.initialTime, this.last = false, this.controller, this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5),
      height: 70,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: 12,
                color: Colors.red,
                height: 40,
              ),
              Text(initialTime),
              SizedBox(
                  width: 40,
                  height: 40,
                  child: InkWell(
                      child: Icon(Icons.edit),
                      onTap: () => editTime(context)
                  )
              )
            ],
          ),
          !last ? Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Divider(color: Colors.black,),
          ) : Divider(color: Colors.black)
        ],
      ),
    );
  }

  void editTime(BuildContext context) {
    showTimePicker(context: context, initialTime: TimeOfDay.now()).then(
            (time) {
          String h = time.hour.toString();
          String m = time.minute.toString();
          if (h.length == 1) h = "0" + h;
          if (m.length == 1) m = "0" + m;
          String currentTime = "$h:$m";
          controller.add(id + " " + currentTime);
        });
  }
}