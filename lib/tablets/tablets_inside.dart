import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pharmacy_app/utils/links.dart';
import 'package:pharmacy_app/utils/utils.dart';

import '../main.dart';

class TabletsInside extends StatefulWidget{
  final Map<String, dynamic> data;

  const TabletsInside({Key key, this.data}) : super(key: key);

  TabletsInsideState createState() => TabletsInsideState();
}

class TabletsInsideState extends State<TabletsInside>{
  bool notifications;

  @override
  void initState() {
    super.initState();
    notifications = widget.data["Notification"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data["RecipeName"]),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => Utils.showHelpInfo(context, References.tabletsPage),
          ),
          PopupMenuButton<int>(
            onSelected: (value) async {
              switch (value){
                case 1:
                  if (notifications) await removeNotifications();
                  else await createNotifications();
                  notifications = !notifications;
                  break;
                case 2:
                  _showAlertDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(notifications ? "Отключить уведомления " : "Включить уведомления "),
                    Icon(notifications ? Icons.notifications : Icons.notifications_off, color: Colors.black54,)
                  ],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 2,
                child: Text("Удалить весь курс приёма"),
              ),
//              PopupMenuDivider(),
//              PopupMenuItem(
//                value: 3,
//                child: Text("Перейти в рецепт"),
//              )
            ],
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(5),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 10),
              height: 60,
              child: Row(
                children: <Widget>[
                  Text("Дозировка: ", style: TextStyle(fontSize: 18),),
                  Text(widget.data["Dosage"], style: TextStyle(fontSize: 18),)
                ],
              ),
            ),
            Divider(color: Colors.black,),
            Container(
              padding: EdgeInsets.only(left: 10),
              height: 60,
              child: Row(
                children: <Widget>[
                  Text("Время: ", style: TextStyle(fontSize: 18),),
                  Text(widget.data["Time"], style: TextStyle(fontSize: 18),)
                ],
              ),
            ),
            Divider(color: Colors.black),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Ink(
                      decoration: ShapeDecoration(
                          color: Colors.red[400],
                          shape: CircleBorder()
                      ),
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.black54,),
                        iconSize: 120,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Ink(
                      decoration: ShapeDecoration(
                        color: Colors.lightGreen,
                        shape: CircleBorder()
                      ),
                      child: IconButton(
                        iconSize: 120,
                        icon: Icon(Icons.check, color: Colors.black54,),
                        onPressed: () async {
                          await takeTablet();
                          //await _showNotification();
                          goToStartPage(context);
                        },
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> removeNotifications() async {
    LocalStorage localStorage = LocalStorage("tablets");
    await localStorage.ready;
    Map<String, dynamic> kurs = localStorage.getItem(widget.data["KursID"]);
    List<dynamic> notificationIds = kurs["NotificationIds"];
    for (int i = 0; i < notificationIds.length; i++){
      flutterLocalNotificationsPlugin.cancel(int.parse(notificationIds[i].toString()));
    }
    kurs["NotificationsON"] = false;
    localStorage.setItem(widget.data["KursID"], kurs);
  }

  Future<void> createNotifications() async {
    LocalStorage localStorage = LocalStorage("tablets");
    await localStorage.ready;
    var kurs = localStorage.getItem(widget.data["KursID"]);
    List<dynamic> notificationIds = kurs["NotificationIds"];
    Map<String, dynamic> schedule = kurs["Schedule"];
    for (int i = 0; i < notificationIds.length; i++){
      _showDailyAtTime(schedule[i.toString()].toString(), widget.data["RecipeName"], int.parse(notificationIds[i].toString()));
    }
    kurs["NotificationsON"] = true;
    localStorage.setItem(widget.data["KursID"], kurs);
  }

  Future<void> _showDailyAtTime(String recipeTime, String recipeName, int id) async {
    print("create notification at $recipeTime with id: $id");
    var hour = int.parse(recipeTime.split(':')[0]);
    var minutes = int.parse(recipeTime.split(':')[1]);
    var time = Time(hour, minutes, 0);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'repeatDailyAtTime channel id',
      'repeatDailyAtTime channel name',
      'repeatDailyAtTime description',);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
      id,
      '009.РФ',
      'Время принять $recipeName',
      time,
      platformChannelSpecifics,
    );
    print("successful create nitification");
  }


  void goToStartPage(BuildContext context){
    Navigator.of(context).pushNamedAndRemoveUntil('/HomeLogged', (route) => false, arguments: 1);
  }

  Future<void> deleteKurs() async {
    LocalStorage localStorage = LocalStorage("tablets");
    await localStorage.ready;
    List<dynamic> ids = localStorage.getItem("ids");
    localStorage.deleteItem(widget.data["KursId"]);
    bool succesRemove = ids.remove(widget.data["KursID"]);
    print(succesRemove);
    localStorage.setItem("ids", ids);
  }

  Future<void> takeTablet() async {
    LocalStorage localStorage = LocalStorage("tablets");
    await localStorage.ready;
    Map<String, dynamic> recipeItems = localStorage.getItem("recipeReadItems");
    print(widget.data["TabletId"]);
    recipeItems[widget.data["TabletId"]] = true;
    localStorage.setItem("recipeReadItems", recipeItems);
  }

  _showAlertDialog(){
    final dialog = AlertDialog(
      content: Text("Вы действительно хотите удалить курс?"),
      actions: <Widget>[
        FlatButton(
          child: Text("Нет"),
          onPressed: () => Navigator.pop(context),
        ),
        FlatButton(
          child: Text("Да"),
          onPressed: () async {
            await removeNotifications();
            deleteKurs().then((_) => goToStartPage(context));
          },
        )
      ],
    );
    showDialog(context: context, child: dialog);
  }
}