import 'package:flutter/material.dart';
import 'package:pharmacy_app/utils/links.dart';
import 'package:pharmacy_app/utils/server_wrapper.dart';
import 'package:pharmacy_app/utils/utils.dart';

class RelativesWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Мои близкие"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => Utils.showHelpInfo(context, References.myRelativesPages),
          )
        ],
      ),
      body: FutureBuilder(
        future: ServerRelatives.getRelatives(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.done){
            List<Widget> widgets = List();
            List<dynamic> data = List();
            if ((snapshot.data as Map<String, dynamic>).containsKey("Relatives")){
               data = snapshot.data["Relatives"];
            }
            if (data.length == 0){
              widgets.add(SizedBox());
            }
            for (var rel in data){
              widgets.add(RelativesCard(
                userId: rel["UserID"].toString(),
                fio: rel["FIO"].toString(),
                nickname: rel["Nikname"].toString(),
                esiaConfirmed: rel["ESIA_Confirmed"] as bool,
                phoneConfirmed: rel["Phone_Confirmed"] as bool,
              ));
            }
            if (widgets.length == 0) widgets.add(SizedBox());
            return Container(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      children: widgets,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 20),
                    width: double.infinity,
                    child: FlatButton(
                      child: Text("Добавить родственника"),
                      onPressed: () => Navigator.of(context).pushNamed('/Relatives/New', arguments: ""),
                      color: Colors.blue,
                    ),
                  )
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

}

class RelativesCard extends StatelessWidget{
  final String userId;
  final String fio;
  final String nickname;
  final bool esiaConfirmed;
  final bool phoneConfirmed;

  const RelativesCard({Key key, this.userId, this.fio, this.nickname, this.esiaConfirmed, this.phoneConfirmed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed('/Relatives/Inside', arguments: userId),
      child: Container(
        padding: EdgeInsets.all(6),
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black54),
          borderRadius: BorderRadius.circular(6)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(fio, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text("Телефон:  ${phoneConfirmed ? " Подтверждён" : " Не подтверждён"}", style: TextStyle(fontSize: 18),),
            ),
            Text("Госуслуги: ${esiaConfirmed ? "Вход выполнен" : "Вход не выполнен"}", style: TextStyle(fontSize: 18))
          ],
        ),
      ),
    );
  }

}