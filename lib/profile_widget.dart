import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:pharmacy_app/camera_widget.dart';
import 'package:pharmacy_app/utils/links.dart';
import 'package:pharmacy_app/utils/server_wrapper.dart';
import 'package:pharmacy_app/utils/shared_preferences_wrapper.dart';
import 'package:pharmacy_app/utils/utils.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'dart:async';

import 'package:url_launcher/url_launcher.dart';

import 'news_card_widget.dart';

class MainProfile extends StatelessWidget{
  var textStyle = TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(3)
            ),
            width: double.infinity,
            height: 50,
            child: FlatButton(
              child: Text('Мой профиль', style: textStyle,),
              onPressed: () async {
                  Navigator.of(context).pushNamed('/MyProfile');
                },
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(3)
            ),
            width: double.infinity,
            height: 50,
            child: FlatButton(
              child: Text('Мои близкие', style: textStyle,),
              onPressed: () => Navigator.of(context).pushNamed('/Relatives'),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(3)
            ),
            width: double.infinity,
            height: 50,
            child: FlatButton(
              child: Text('Сообщения', style: textStyle,),
              onPressed: () => Navigator.of(context).pushNamed('/Messages'),
            ),
          ),
          Expanded(
            child: Container(),
          ),
          ProfileNewsWidget()
        ],
      ),
    );
  }
}

class ProfileNewsWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ServerNews.getNewsCard(page: "Profile"),
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.done){
          List<Widget> news = createNewsCards(snapshot.data ?? List());
          return Expanded(
            child: ListView( children: news,),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  List<Widget> createNewsCards(List<dynamic> content){
    List<Widget> widgets = List();
    if (content.length == 0){
      return [SizedBox()];
    }
    for (int i = 0; i < content.length; i++) {
      Map<String, dynamic> data = content[i]['Data'];
      if (content[i]["TypeData"] == "News"){
        widgets.add(NewsCard(
          newsID: content[i]["ID"].toString(),
          titleText: data['Header'].toString(),
          bodyText: data['Body'].toString(),
          botSource: data['Source'].toString(),
          date: data['Date'].toString().replaceAll("T", ' '),
          url: content[i]['ext_link'].toString(),
          read: content[i]['NotRead'] as bool,
          pageType: 2,
        )
        );
      }
    }
    return widgets;
  }
}

class MyProfile extends StatefulWidget {
  final String greetMessage;

  const MyProfile({Key key, this.greetMessage = ""}) : super(key: key);

  MyProfileState createState() => MyProfileState();
}

class MyProfileState extends State<MyProfile>{
  final upTextStyle = const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  final botTextStyle = const TextStyle(fontSize: 14);
  final topTextPadding = const EdgeInsets.only(bottom: 8);
  bool pinCodeOn = false;
  ProgressDialog progressDialog;

  String surname = "";
  String name = "";
  String patronymic = "";
  String date = "";
  String town = "";
  String snils = "";
  String number = "";
  String mail = "";
  String snilsConfirm = "";
  String gender = "";
  bool esiaConfirm = false;
  bool emailConfirm = false;
  Widget snilsButton = SizedBox();

  @override
  void initState() {
    super.initState();
    getPincodeState();
  }

  getPincodeState() async {
    String pin = await SharedPreferencesWrap.getPincode();
    pinCodeOn = pin != null;
  }

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(context, type: ProgressDialogType.Normal);
    progressDialog.style(message: "Подождите...");
    return Scaffold(
      appBar: AppBar(
        title: Text('Мой профиль'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => Utils.showHelpInfo(context, References.profilePage),
          ),
          FlatButton(
            child: Text('Выйти', style: TextStyle(color: Colors.white),),
            onPressed: _logout
          )
        ],
      ),
      body: FutureBuilder(
        future: setDataFromServer(context),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.done){
            return Container(
              margin: EdgeInsets.all(14),
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
                            Text("$surname", style: botTextStyle,)
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: Text("Имя", style: upTextStyle),
                            ),
                            Text("$name" ,style: botTextStyle,)
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: Text("Отчество", style: upTextStyle),
                            ),
                            Text("$patronymic", style: botTextStyle,)
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
                                Text("${date.substring(0, 10)}", style: botTextStyle,)
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 3),
                                  child: Text("Пол", style: upTextStyle,),
                                ),
                                Text(gender, style: botTextStyle,)
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
                            Text("$snils", style: botTextStyle,)
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: Text("Номер телефона", style: upTextStyle),
                            ),
                            Text("$number", style: botTextStyle,)
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
                            Text("$mail", style: botTextStyle,)
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: Text("Авторизация через Госуслуги", style: upTextStyle,),
                            ),
                            Text(esiaConfirm ? "Пройдена" : "Не пройдена", style: botTextStyle,)
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: <Widget>[
                        Text("Безопасность  "),
                        Expanded(child: Divider(color: Colors.black,))
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text("Использовать PIN-код"),
                      Switch(
                        value: pinCodeOn,
                        onChanged: (value) {
                          if (value){
                            Navigator.of(context).pushNamed('/PincodeAddNew');
                          } else {
                            SharedPreferencesWrap.setPincode(null);
                            setState(() => pinCodeOn = false );
                          }
                        } ,
                      )
                    ],
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        !esiaConfirm ? SizedBox() : Container(
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey)
                          ),
                              child: FlatButton(
                                child: Text("Изменить электронный адрес"),
                                onPressed: () => Navigator.of(context).pushNamed('/EditProfile', arguments: {
                                  "surname": surname, "name": name, "patronymic": patronymic, "date": convertDate(date), "mail": mail, "gender": gender, "canEdit": false})
                            ),
                        ),
                        snilsButton,
                        !esiaConfirm ? FlatButton(
                          child: Text("Авторизация через Госуслуги"),
                          onPressed: () async {
                            progressDialog.show();
                            var url = await ServerLogin.loginEsia();
                            progressDialog.hide();
                            if (url != ""){
                              Navigator.of(context).pushNamed("/Webview", arguments: [url]);
                            } else {
                              showMessagePopUp(context, "Сервис авторизации Госуслуг временно недоступен");
                            }
                          },
                          color: Colors.blueAccent,
                        ) : FlatButton(
                          color: Colors.blueAccent,
                          child: Text("Отозвать доступ к Госуслугам"),
                          onPressed: () => showEsiaAlert(context),
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
                    ),
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

  _logout() async {
    showDialog(
      context: context,
      child: AlertDialog(
        content: Text("Вы действительно хотите выйти?"),
        actions: <Widget>[
          FlatButton(
            child: Text("Нет"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          FlatButton(
            child: Text("Да"),
            onPressed: () async {
              await ServerProfile.logout();
              //SharedPreferencesWrap.setFirstOpen();
              await SharedPreferencesWrap.setLoginInfo(false);
              await SharedPreferencesWrap.setPincode(null);
              SharedPreferencesWrap.setConfirmationToken("");
              SharedPreferencesWrap.setAccessToken("");
              Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
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

  Future<void> setDataFromServer(BuildContext context) async {
    final data = await ServerProfile.getUserProfile();
    name = data["Name"].toString() ?? "";
    surname = data["Surname"].toString() ?? "";
    patronymic = data["MiddleName"].toString() ?? "";
    date = data["Birthday"].toString().replaceAll("T", " ") ?? "";
    number = "8-" + data["Phone"].toString() ?? "";
    mail = data["eMail"].toString() ?? "";
    gender = data["Gender"].toString() == "M" ? "Мужской" : "Женский";
    esiaConfirm = data["ESIAConfirm"] as bool;
    emailConfirm = data["eMailConfirmed"] as bool;

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
    if (widget.greetMessage != "" && widget.greetMessage != null) showMessagePopUp(context, widget.greetMessage);

  }

  void showMessagePopUp(BuildContext context, String message){
    AlertDialog alert = AlertDialog(
      content: Text(message, textAlign: TextAlign.center),
      actions: <Widget>[
        FlatButton(child: Text("Закрыть"), onPressed: () => Navigator.of(context).pop(),)
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      }
    );
  }

  void showEsiaAlert(BuildContext context){
    AlertDialog alert = AlertDialog(
      content: Text("Вы действительно хотите отозвать доступ к Госуслугам?", textAlign: TextAlign.center),
      actions: <Widget>[
        FlatButton(child: Text("Нет"), onPressed: () => Navigator.of(context).pop(),),
        FlatButton(child: Text("Да"), onPressed: () async {
          await ServerProfile.changeUserData({"ESIAConfirm": "false"});
          Navigator.of(context).pushNamedAndRemoveUntil("/MyProfile", (route) => route.isFirst);
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

}

class ProfileEdit extends StatefulWidget{
  final data;

  const ProfileEdit({Key key, this.data}) : super(key: key);

  ProfileEditState createState() => ProfileEditState();
}

class ProfileEditState extends State<ProfileEdit>{
  final topTextPadding = const EdgeInsets.only(bottom: 8);
  final upTextStyle = const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

  final _key = GlobalKey<FormState>();

  //final phoneMask = MaskTextInputFormatter(mask: '###-###-##-##', filter: {'#': RegExp(r'[0-9]')});
  final dateMask = MaskTextInputFormatter(mask: '##/##/####', filter: {'#': RegExp(r'[0-9]')});

  String surname = "";
  String name = "";
  String patronymic = "";
  String date = "";
  String mail = "";
  bool male;

  @override
  void initState() {
    super.initState();
    male = widget.data["gender"] == "Мужской" ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(14),
      child: ListView(
        children: [
          Form(
            key: _key,
            child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: TextFormField(
                  enabled: widget.data["canEdit"],
                  initialValue: widget.data["surname"] ?? "",
                  validator: (value) {if (value.isEmpty){return 'Введите фамилию';} else {
                  return null;}
                  },

                  onSaved: (value) => surname = toUpFirstLetter(value),
                    decoration: InputDecoration(
                        hintText: "Ваша фамилия",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.person),
                        labelText: "Фамилия"
                    )
                ),
              ), //surname
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: TextFormField(
                    enabled: widget.data["canEdit"],
                    initialValue: widget.data["name"] ?? "",
                    validator: (value) {if (value.isEmpty){return 'Введите имя';} else {
                      return null;}
                    },
                    onSaved: (value) => name = toUpFirstLetter(value),
                    decoration: InputDecoration(
                        hintText: "Ваше имя",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.person),
                        labelText: "Имя"
                    )
                ),
              ), //name
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: TextFormField(
                    enabled: widget.data["canEdit"],
                    initialValue: widget.data["patronymic"] ?? "",
                    validator: (value) {if (value.isEmpty){return 'Введите отчество';} else {
                      return null;}
                    },
                    onSaved: (value) => patronymic = toUpFirstLetter(value),
                    decoration: InputDecoration(
                        hintText: "Ваше отчество",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.person),
                        labelText: "Отчество"
                    )
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: TextFormField(
                    enabled: widget.data["canEdit"],
                  initialValue: widget.data["date"] ?? "",
                  validator: (value) {
                      if (value.isEmpty) {
                        return 'Введите дату рождения';
                      } else if (value.length < 10){
                        return null;
                      }
                      else {
                        return null;
                      }
                  },
                  maxLength: 10,
                  onSaved: (value) => date = value,
                    keyboardType: TextInputType.datetime,
                    inputFormatters: [dateMask],
                    decoration: InputDecoration(
                        hintText: "дд/мм/гггг",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.date_range),
                        labelText: "Дата рождения"
                    )
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: TextFormField(
                  initialValue: widget.data["mail"] ?? "",
                  onSaved: (value) => mail = value,
                  validator: (value) {
                    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)){
                      print(value);
                      print(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value));
                      return "Введите корректный eMail";
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                      hintText: "example@mail.ru",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.mail),
                      labelText: "Электронная почта"
                  )
                ),
              ),
              Text("Пол", style: TextStyle(fontSize: 20),),
              Container(
                child: Row(
                  children: <Widget>[
                    ChoiceChip(

                      onSelected: (_) {setState(() { if (widget.data["canEdit"]) male = true;});},
                      label: Text("Мужской"),
                      selected: male == true,
                    ),
                    Container(
                      width: 10,
                    ),
                    ChoiceChip(
                      onSelected: (_) {setState(() { if (widget.data["canEdit"]) male = false;});},
                      label: Text("Женский"),
                      selected: male == false,
                    ),
                  ],
                ),
              ),

              Container(
                alignment: Alignment.bottomCenter,
                margin: EdgeInsets.symmetric(vertical: 10),
                width: double.infinity,
                height: 40,
                child: FlatButton(
                  color: Color.fromARGB(255, 68, 156, 202),
                  child: Text("Сохранить", style: TextStyle(fontSize: 18, color: Colors.grey[900]), textAlign: TextAlign.center),
                  onPressed: () async {
                    if (_key.currentState.validate()){
                      _key.currentState.save();

                      Map<String, String> data = {"Surname": surname, "Name": name, "MiddleName": patronymic,
                      "Gender": male == true ? "M" : "F", "Birthday": convertDate(date), "eMail": mail};
                      await ServerProfile.changeUserData(data);

                      Navigator.of(context).pushNamedAndRemoveUntil('/MyProfile', (route) => route.isFirst);
                    }
                  },
                ),
              ),
              ],
            ),
          ),
        ]
      ),
    );
  }

  static String toUpFirstLetter(String input) {
    if (input == null) {
      throw new ArgumentError("string: $input");
    }
    if (input.length == 0) {
      return input;
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  static String convertDate(String date){
    String newDate = date[6] + date[7] + date[8] + date[9] + date[3] + date[4] + date[5] + date[0] + date[1] + date[2];
    return newDate;
  }
}

class SnilsCameraWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: CameraWidget(),
    );
  }

}
