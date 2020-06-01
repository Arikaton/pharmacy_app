import 'package:flutter/material.dart';

class ESIAWarning extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Предупреждение"),),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Для того чтобы выписанные Вам рецепты появились в приложении:\n",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              "1. Авторизуйтесь в приложении с помощью учётной записи сервиса Госуслуги\n",
              style: TextStyle(fontSize: 18),
            ),
            Text(
              '''2. Просите вашего врача выписать Вам рецепт в электронном виде согласно приказа Министерства здравоохранения №4н от 14 января 2019г.\n\nНажмите кнопку "Перейти в профиль" чтобы войти в Ваш профиль и авторизоваться через Госуслуги.\n\nЕсли вы не авторизуетесь в приложении через Госуслуги, то приложение будет работать в ДЕМО режиме.''',
              style: TextStyle(fontSize: 18),
            ),
            Expanded(child: SizedBox(),),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                SizedBox(
                  width: 150,
                  height: 60,
                  child: FlatButton(
                    child: Text("Отмена", style: TextStyle(fontSize: 18),),
                    onPressed: () => Navigator.of(context).pop(),
                    color: Colors.black12,
                  ),
                ),
                SizedBox(
                  width: 150,
                  height: 60,
                  child: FlatButton(
                    child: Text("Перейти в профиль", textAlign: TextAlign.center, style: TextStyle(fontSize: 18),),
                    color: Colors.blue,
                    onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/MyProfile', (route) => route.isFirst),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

}