import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pharmacy_app/utils/links.dart';
import 'package:pharmacy_app/utils/server_wrapper.dart';
import 'package:pharmacy_app/utils/utils.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class RelativesInside extends StatelessWidget{
  final String userId;
  final upTextStyle = const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  final botTextStyle = const TextStyle(fontSize: 14);
  final topTextPadding = const EdgeInsets.only(bottom: 8);

  const RelativesInside({Key key, this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Профиль - близкие'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () => Utils.launchUrl(References.myRelativesPages),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteRelative(context),
            )
          ],
        ),
        body: FutureBuilder(
          future: ServerRelatives.getRelatives(userId: userId),
          builder: (context, snapshot){
            if (snapshot.connectionState == ConnectionState.done){
              ProgressDialog progressDialog = ProgressDialog(context, type: ProgressDialogType.Normal);
              progressDialog.style(message: "Подождите...");
              Map<String, dynamic> data = snapshot.data;
              String snils;

              switch (data["SNILSConfirm"].toString()){
                case "0":
                  snils = "СНИЛС не вводился";
                  break;
                case "1":
                  snils = data["SNILS"].toString();
                  break;
                case "2":
                  snils = "СНИЛС не распознан";
                  break;
                case "3":
                  snils = "СНИЛС на распознавании";
                  break;
              }
              return Container(
                margin: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Text("Фамилия", style: upTextStyle),
                              ),
                              Text("${data["Surname"]}", style: botTextStyle,)
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Text("Имя", style: upTextStyle),
                              ),
                              Text(data["Name"] ,style: botTextStyle,)
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Text("Отчество", style: upTextStyle),
                              ),
                              Text(data["MiddleName"], style: botTextStyle,)
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 3),
                                    child: Text("Дата рождения", style: upTextStyle),
                                  ),
                                  Text(data["Birthday"].toString().substring(0, 10), style: botTextStyle,)
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 3),
                                    child: Text("Пол", style: upTextStyle,),
                                  ),
                                  Text(data["Gender"], style: botTextStyle,)
                                ],
                              )
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Text("СНИЛС", style: upTextStyle,),
                              ),
                              Text(snils, style: botTextStyle,)
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Text("Номер телефона", style: upTextStyle),
                              ),
                              Text("8-${data["Phone"]}", style: botTextStyle,)
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Row(
                                  children: <Widget>[
                                    Text("Электронная почта   ", style: upTextStyle),
                                    //Icon(Icons.check_circle, color: emailConfirm ? Colors.lightGreen : Colors.red,)
                                  ],
                                ),
                              ),
                              Text(data["eMail"], style: botTextStyle,)
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Text("Авторизация через Госуслуги", style: upTextStyle,),
                              ),
                              Text(data["ESIAConfirm"] as bool ? "Пройдена" : "Не пройдена", style: botTextStyle,)
                            ],
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          !data["ESIAConfirm"] ? SizedBox(
                            width: double.infinity,
                            child: FlatButton(
                              child: Text("Редактировать профиль"),
                              color: Colors.blue,
                              onPressed: () => Navigator.of(context).pushNamed('/Relatives/Edit',
                                  arguments: {"userID": userId, "gender": data["Gender"], "name": data["Name"], "surname": data["Surname"], "patronymic": data["MiddleName"], "date": convertDate(data["Birthday"].toString().substring(0, 10))}),
                            ),
                          ) : SizedBox(),
                          !data["ESIAConfirm"] ? SizedBox(
                            width: double.infinity,
                            child: FlatButton(
                              child: Text("Авторизация через Госуслуги"),
                              color: Colors.blue,
                              onPressed: () async {
                                var esiaState = await ServerProfile.getUserProfile();
                                if (!esiaState["ESIAConfirm"] as bool){
                                  showDialog(context: context,
                                  child: AlertDialog(
                                    content: Text("Для авторизации родственника пройдите самостоятельную авторизацию.", textAlign: TextAlign.center,),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text("Ок"),
                                        onPressed: () => Navigator.of(context).pop(),
                                      )
                                    ],
                                  ));
                                  return;
                                }
                                //print(esiaState);
                                progressDialog.show();
                                var url = await ServerLogin.loginEsia();
                                progressDialog.hide();
                                if (url != ""){
                                  Navigator.of(context).pushNamed("/Webview", arguments: [url, userId]);
                                } else {
                                  _showSnackBar(context);
                                }
                              },
                            ),
                          ) :
                          SizedBox(
                            width: double.infinity,
                            child: FlatButton(
                              child: Text("Отозвать регистрацию через Госуслуги"),
                              color: Colors.blue,
                              onPressed: () => showEsiaAlert(context),
                            ),
                          ),
                          RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                  text: 'Проходя авторизацию через сервис "ГосУслуги" Вы принимаете ',
                                  style: TextStyle(color: Colors.black),
                                  children: [
                                    TextSpan(
                                        text: 'лицензионное соглашение',
                                        style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                        recognizer: TapGestureRecognizer()..onTap = () => _launchURL(References.license)
                                    ),
                                    TextSpan(text: ' и '),
                                    TextSpan(
                                        text: 'политику конфидециальности',
                                        style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                        recognizer: TapGestureRecognizer()..onTap = () => _launchURL(References.police)
                                    ),
                                  ]
                              )
                          ),
                        ],
                      )
                    )
                  ],
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        )
    );
  }

  _deleteRelative(BuildContext context) async {
    showDialog(
        context: context,
        child: AlertDialog(
          content: Text("Вы действительно удалить родственника?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Нет"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FlatButton(
              child: Text("Да"),
              onPressed: () async {
                Map<String, dynamic> data = await ServerRelatives.getRelatives(userId: userId);
                await ServerProfile.addRelatives("false", body: jsonEncode({"Phone": "${data["Phone"]}"}) );
                Navigator.of(context).pushNamedAndRemoveUntil('/Relatives', (route) => route.isFirst, arguments: 2);
              },
            ),
          ],
        )
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  static String convertDate(String date){
    if (date.length < 10) return "";
    return date[8] + date[9] + "/" + date[5] + date[6] + "/" +  date[0] + date[1] + date[2] + date[3] ;
  }

  void showEsiaAlert(BuildContext context){
    AlertDialog alert = AlertDialog(
      content: Text("Вы действительно хотите отозвать доступ к Госуслугам?", textAlign: TextAlign.center),
      actions: <Widget>[
        FlatButton(child: Text("нет"), onPressed: () => Navigator.of(context).pop(),),
        FlatButton(child: Text("Да"), onPressed: () async {
          await ServerProfile.changeUserData({"ESIAConfirm": "false"}, userId: userId);
          Navigator.of(context).pushNamedAndRemoveUntil("/Relatives", (rouute) => rouute.isFirst);
        },)
      ],
    );

    showDialog(
        context: context,
        builder: (BuildContext context){
          return alert;
        }
    );
  }

  void _showSnackBar(BuildContext context){
    var snackBar = SnackBar(
        content: Text("Сервер авторизации Госуслуги временно не доступен"),
        action: SnackBarAction(label: "ок", onPressed: () {},)
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

}