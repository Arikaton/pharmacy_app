import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:localstorage/localstorage.dart';
import '../main.dart';

class TabletsMain extends StatefulWidget{
  TabletsMainState createState() => TabletsMainState();
}

class TabletsMainState extends State<TabletsMain>{
  LocalStorage localStorage = LocalStorage("tablets");

  @override
  void initState() {
    print("---------tablets init-----------");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: localStorage.ready,
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.done){
          List<dynamic> ids = localStorage.getItem("ids") ?? List();
          if (ids.length == 0){
            return Container(
              child: Center(
                child: Text("У вас нет ни одного курса.\nКак только у вас будет рецепт,\nВы сможете создать курс приёма лекарств", textAlign: TextAlign.center,),
              ),
            );
          } else {
            return Container(
              margin: EdgeInsets.all(5),
              height: double.infinity,
              child: ListView(
                children: _createTablets(ids),
                ),
              );
            }
        } else {
          return Center(child: CircularProgressIndicator(),);
        }
      },
    );
  }

  List<Widget> _createTablets(List<dynamic> ids){
    List<Widget> widgets = List(); //Виджеты курсов
    Map<DateTime, dynamic> allDates = Map(); //Все используемые даты
    Map<String, dynamic> recipeReadKeys; //Все курсы с информацией об их прочтении, в качестве ключа используется связка id препарата + месяц + день + время приёма
    List<dynamic> recipeNotificationUnusedIds; //Здесь храним все неиспользуемые ид для локальных нотификаций, используется для гарантии уникальности всех ид

    recipeReadKeys = localStorage.getItem("recipeReadItems") ?? Map();
    recipeNotificationUnusedIds = localStorage.getItem("notificationsUnusedIds") ?? List.generate(500, (index) => index);

    for (int i = 0; i < ids.length; i++){ //Проходим по каждой записи в базе
      Map<String, dynamic> data = localStorage.getItem(ids[i]); //Информация о курсе
      if (!data["HaveNotification"]) //Если препарат создаётся впервые, то автоматически создаём локальную нотификацию
      {
        _createNotifications(data, recipeNotificationUnusedIds, ids[i]); //Создаём нотификации для препарата
      }
      //TODO: Здесь будем удалять просроченные препарат
      for (int d = 0; d < int.parse(data["Duration"].toString()); d++){
        DateTime currentDate = DateTime.parse(data["DateStart"]).add(Duration(days: d)); //Находим дату как дата начала приёма плюс продолжительность приёма
        //List<Widget> tabSchedule = allDates[currentDate] ?? List(); //before
        List<Map<String, dynamic>> tabSchedule = allDates[currentDate] ?? List(); //Лист со всеми препаратами, которые необходимо принять в этот день
        Map<String, dynamic> schedule = data["Schedule"]; //Добавляем в него расписание текущего препарата
        for (int s = 0; s < schedule.keys.length; s++) // Проходимся по каждому времени приёма
        {
          var newRecipeKey = ids[i].toString() + currentDate.month.toString() + currentDate.day.toString() + data["Schedule"]["$s"].toString(); //Формируем ключ для каждого приёма
          if (!recipeReadKeys.containsKey(newRecipeKey))
            recipeReadKeys[newRecipeKey] = false; //Если нет признака прочтения, то добавляем его и устанавливаем как false

//          tabSchedule.add(TabletsRecipeSchedule(time: data["Schedule"]["$s"].toString(), recipeName: data["RecipeName"],
//            dosage: data["Dosage"], date: currentDate, id: ids[i], read: recipeReadKeys[newRecipeKey],
//            last: s == schedule.keys.length - 1, notification: data["NotificationsON"],));
          tabSchedule.add({data["Schedule"]["$s"].toString():
              {
                "recipeName": data["RecipeName"],
                "dosage": data["Dosage"],
                "date": currentDate,
                "id": ids[i],
                "read": recipeReadKeys[newRecipeKey] as bool,
                "notification": data["NotificationsON"],
              }
          });
        }
//        tabSchedule.add(Padding(
//          padding: const EdgeInsets.symmetric(vertical: 5),
//          child: Divider(color: Colors.black),
//        )); //Добавляем разделитель после всех приёмов
        allDates[currentDate] = tabSchedule; //Добавляем приёмы в общую таблицу
      }
    }
    localStorage.setItem("recipeReadItems", recipeReadKeys); //Сохраняем ключи приёмов
    localStorage.setItem("notificationsUnusedIds", recipeNotificationUnusedIds); //Сохраняем список свободных id нотификаций

    var dateKeys = allDates.keys.toList();
    dateKeys.sort((a, b) => a.compareTo(b)); //Сортировка дат по ключам
    for (var key in dateKeys)
    {
      List<Widget> dayWidgets = List();
      if (key.difference(DateTime.now()).inDays < 5 && !key.difference(DateTime.now().subtract(Duration(days: 1))).isNegative){
        List<Map<String, dynamic>> dateTimes = allDates[key];
        dateTimes.sort((a, b) => a.keys.toList()[0].compareTo(b.keys.toList()[0]));
        for (var tabletData in dateTimes){
          var time = tabletData.keys.toList()[0];
          dayWidgets.add(TabletsRecipeSchedule(
            time: time,
            recipeName: tabletData[time]["recipeName"].toString(),
            dosage: tabletData[time]['dosage'].toString(),
            date: key,
            id: tabletData[time]['id'].toString(),
            read: tabletData[time]['read'] ?? false,
            notification: tabletData[time]['notification'] as bool,
          ));
        }
        widgets.add(TabletsDaySchedule(date: key, children: dayWidgets));
      }
    }
    return widgets;
  }

  _createNotifications(Map<String, dynamic> data, List<dynamic> recipeNotificationUnusedIds, String id){
    List<int> notificationsIds = List(); // здесь храним все ид нотификаций, используемых именно этим препаратом
    Map<String, dynamic> schedule = data["Schedule"]; //Получаем расписание препарата
    for (var n in schedule.keys){ //Для каждого времени...
      var newId = (recipeNotificationUnusedIds.toList()..shuffle()).first; //Перемешиваем массив с неиспользуемыми идшниками и вытаскиваем оттуда первое значение
      notificationsIds.add(newId); //Добавляем его у общему списку нотификаций препарата
      recipeNotificationUnusedIds.removeAt(0); //Удаляем ид из спизка свободных идишников
      _showDailyAtTime(schedule[n], data["RecipeName"], newId, data["Dosage"], id.toString()); //Создаём нотификацию
    }
    data["HaveNotification"] = true; //Помечаем, что у нотификации уже есть идишники
    data["NotificationIds"] = notificationsIds; //Добавляем идишники в локальную базу, эту нужно для последующего удаления и взаимодействия с сервером
    localStorage.setItem(id, data);
  }

  int getRandomListItem(int len){
    final _random = Random();
    return _random.nextInt(len);
  }

  Future<void> _showDailyAtTime(String recipeTime, String recipeName, int id, String dosage, String kursId) async {
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
        payload: jsonEncode({"RecipeName": recipeName, "Dosage": dosage, "Time": recipeTime,
          "KursID": kursId, "Notification": true})
    );
    print("successful create nitification");
  }

}

class TabletsRecipeSchedule extends StatefulWidget{
  final DateTime date;
  final String time;
  final String recipeName;
  final String dosage;
  final String id;
  final bool read;
  final bool notification;

  const TabletsRecipeSchedule({Key key, this.time, this.recipeName, this.dosage, this.date, this.id, this.read, this.notification}) : super(key: key);

  TabletsRecipeScheduleState createState() => TabletsRecipeScheduleState();
}

class TabletsRecipeScheduleState extends State<TabletsRecipeSchedule>{
  // LocalStorage localStorage = LocalStorage("tablets");
  Color curColor;

  @override
  void initState() {
    curColor = defineColor();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed('/Tablets/Inside', arguments:{"RecipeName": widget.recipeName, "Dosage": widget.dosage, "Time": widget.time,
        "TabletId": widget.id + widget.date.month.toString() + widget.date.day.toString() + widget.time, "KursID": widget.id, "Notification": widget.notification}),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(color: curColor, height: 40, width: 15,),
                Padding(child: Text(widget.time), padding: EdgeInsets.symmetric(horizontal: 50),),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.recipeName, style: TextStyle(fontWeight: FontWeight.bold),),
                    Row(
                      children: <Widget>[
                        Text("Дозировка: "),
                        Text(widget.dosage, style: TextStyle(fontWeight: FontWeight.bold))
                      ],
                    ),
                  ],
                ),
                Expanded(
                    child: Align(
                        child: Icon(widget.notification ? Icons.volume_up: Icons.volume_off),
                        alignment: Alignment.centerRight,
                    )
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color defineColor() {
    var curTimeOfDay = widget.time.split(":");
    DateTime currentDayWithSchedule = widget.date.add(Duration(hours: int.parse(curTimeOfDay[0]), minutes: int.parse(curTimeOfDay[1])));
    Color curColor;
    if (widget.read){
      curColor = Colors.lightGreenAccent[700];
    } else {
      if (DateTime.now().day == widget.date.day){
        if (DateTime.now().difference(currentDayWithSchedule).inSeconds > 0)
        {
          curColor = Colors.red;
        } else {
          curColor = Colors.green[200];
        }
      } else curColor = Colors.yellow[300];
    }
    return curColor;
  }
}

class TabletsDaySchedule extends StatelessWidget{
  final DateTime date;
  final List<Widget> children;

  const TabletsDaySchedule({Key key, this.date, this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(" ${date.toIso8601String().substring(0, 10)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          Divider(color: Colors.black,),
          Column(
            children: children,
          ),
          //Divider(color: Colors.black,)
        ],
      ),
    );
  }
}