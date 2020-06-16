import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:pharmacy_app/utils/shared_preferences_wrapper.dart';
import 'package:http/http.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'news_card_widget.dart';
import 'utils/server_wrapper.dart';

class LoginWidget extends StatefulWidget{
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget>{
  final formKey = GlobalKey<FormState>();
  final phoneMask = MaskTextInputFormatter(mask: '###-###-##-##', filter: {'#': RegExp(r'[0-9]')});
  final scaKey = GlobalKey<ScaffoldState>();
  final snackBar = SnackBar(
    content: Text('Ошибка на сервере. Повторите запрос позже'),
    duration: Duration(seconds: 3),
    action: SnackBarAction(
      label: 'Назад',
      onPressed: () {},
    ),
  );

  String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaKey,
      body: Container(
        margin: EdgeInsets.only(left: 10, top: 40, right: 10, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('009 Электронные рецепты', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              SvgPicture.asset('assets/logo.svg', width: 180),
              Text('Введите номер телефона', style: TextStyle(fontSize: 16),),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Form(
                  key: formKey,
                  child: TextFormField(
                    validator: (value) {
                      if (value.isEmpty){
                        return 'Введите номер';
                      } else if (value.length < 13){
                        return 'Введите корректный номер телефона';
                      } else {
                        return null;
                      }
                    },
                    inputFormatters: [phoneMask],
                    //keyboardType: TextInputType.numberWithOptions(),
                    textAlign: TextAlign.start,
                    onSaved: (value) => phoneNumber = value,
                    style: TextStyle(fontSize: 20, letterSpacing: 1),
                    decoration: InputDecoration(
                      prefixText: "8-",
                      contentPadding: EdgeInsets.only(left: 85),
                      hintText: '___-___-__-__',
                      prefixStyle: TextStyle(color: Colors.black, fontSize: 20),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Продолжая регистрацию я подтверждаю, что ознакомился c ',
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'Лицензионным соглашением',
                      style: TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()..onTap = () => _launchURL("https://кэшбэк.009.рф/terms")
                    ),
                    TextSpan(text: ' и '),
                    TextSpan(
                      text: 'Политикой конфидециальности,',
                      style: TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()..onTap = () => _launchURL("https://кэшбэк.009.рф/privacy-policy")
                    ),
                    TextSpan(
                      text: ' и выражаю своё согласие на обработку персональных данных'
                    )
                  ]
                )
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                width: 300,
                child: FlatButton(
                  color: Color.fromARGB(255, 68, 156, 202),
                  textColor: Colors.black,
                  child: Text("Далее"),
                  onPressed: _tapNextButton
                ),
              ),
              Expanded(
                child: FutureBuilder(
                  future: ServerNews.getNewsCard(page: "Login"),
                  builder: (_, snapshot){
                    if (snapshot.connectionState == ConnectionState.done){
                      List<dynamic> data = snapshot.data ?? List();
                      if (data.length == 0){
                        return SizedBox();
                      }
                      return ListView(
                        children: createNewsCards(data),
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                )
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text('Версия 0.8.0'),
              ),
            ],
          )
        ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _tapNextButton() async {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      Response response = await ServerLogin.loginPhone(phoneNumber);
      if (response.statusCode == 200) {
        String token = jsonDecode(response.body);
        await SharedPreferencesWrap.setConfirmationToken(token);
        Navigator.of(context).pushNamed('LoginCheckNumber');
      }
      else {
        scaKey.currentState.showSnackBar(snackBar);
      }
    }
  }

  List<Widget> createNewsCards(List<dynamic> content){
    List<Widget> widgets = List();
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
          pageType: 0,
        )
        );
      }
    }
    return widgets;
  }

}

class LoginCheckNumberWidget extends StatefulWidget{
  _LoginCheckNumberWidgetState createState() => _LoginCheckNumberWidgetState();
}

class _LoginCheckNumberWidgetState extends State<LoginCheckNumberWidget>{
  final formKey = new GlobalKey<FormState>();
  final scaKey = new GlobalKey<ScaffoldState>();
  final snackBar = SnackBar(
    content: Text("Проблемы с интернет соединением, повторите запрос позже"),
    action: SnackBarAction(label: "Ок", onPressed: () {},),
  );

  String sms;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaKey,
      appBar: null,
      body: Container(
          margin: EdgeInsets.symmetric(vertical: 40, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('009 Электронные рецепты', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Container(
                height: 60,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text('На номер указанного Вами телефона отправленна СМС с 4-х значным кодом доступа в приложение', textAlign: TextAlign.center,),
              ),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(10),
                child: Form(
                  key: formKey,
                  child: TextFormField(
                    onSaved: (value) => sms = value,
                    validator: (value) {
                      if (value.isEmpty){
                        return 'Введите код из смс';
                      } else if (value.length < 4){
                        return 'Код должен быть 4-х значным';
                      } else {
                        return null;
                      }
                    },
                    keyboardType: TextInputType.numberWithOptions(),
                    textAlign: TextAlign.center,
                    maxLength: 4,
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Введите 4-х значный код из СМС'
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                width: 300,
                child: FlatButton(
                    color: Color.fromARGB(255, 68, 156, 202),
                    textColor: Colors.black,
                    child: Text("Продолжить"),
                    onPressed: _onPressedNext,
                ),
              ),
              Container(
                height: 20,
              ),
              Text('Если СМС не пришло, проверьте правильность введеного Вами номера телефона и повторите запрос'),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                width: 300,
                child: FlatButton(
                    color: Color.fromARGB(255, 68, 156, 202),
                    textColor: Colors.black,
                    child: Text("Назад"),
                    onPressed: () => Navigator.pop(context)
                ),
              ),
              Expanded(
                child: FutureBuilder(
                  future: ServerNews.getNewsCard(page: "Login"),
                  builder: (_, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done){
                      List<dynamic> data = snapshot.data ?? List();
                      if (data.length == 0){
                        return SizedBox();
                      }
                      return ListView(
                        children: createNewsCards(data),
                      );
                    } else {
                      return Center(child: CircularProgressIndicator(),);
                    }
                  }
                )
              ),
              Text('Версия 0.8.0')
            ],
          )
      ),
    );
  }

  void _onPressedNext() async {
    if (formKey.currentState.validate()){
      formKey.currentState.save();

      final token = await SharedPreferencesWrap.getConfirmationToken();
      final info = await SharedPreferencesWrap.getDeviceInfo();
      info.remove("AccessToken");

      final url = "${ServerWrapper.serverUrl}/oauth/Phone/Login?ConfirmationCode=$sms&ConfirmationToken=$token";

      Response response = await put(url, headers: info);

      if (response.statusCode == 200){
        var tokens = jsonDecode(response.body);
        await SharedPreferencesWrap.setRefreshToken(tokens["RefreshToken"]);
        await SharedPreferencesWrap.setAccessToken(tokens["AccessToken"]);
        await SharedPreferencesWrap.setLoginInfo(true);
        print(tokens['edit_profile']);
        Navigator.of(context).pushNamedAndRemoveUntil('/HomeLogged', (Route<dynamic> route) => false);
        if (tokens['edit_profile'])
        {
          Navigator.of(context).pushNamed('/MyProfile', arguments: tokens["message"]);
        }
      } else {
        scaKey.currentState.showSnackBar(snackBar);
      }
    }
  }

  List<Widget> createNewsCards(List<dynamic> content){
    List<Widget> widgets = List();
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
          pageType: 0,
        )
        );
      }
    }
    return widgets;
  }

}

class SplashScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    //return Container(
    return Scaffold(
      body: Container(
      color: Colors.white,

      margin: EdgeInsets.all(1),
        child: Column(
            children: <Widget>[
            Expanded(
              child: Text('', style: TextStyle(
                          fontSize: 10,
                          ),
                      ),
          ),
          Expanded(
            child: Text("009 Электронные рецепты", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          ),
          Expanded(
            child: SvgPicture.asset('assets/logo.svg', width: 300),
          ),
          Expanded(
            child: Container(
                alignment: Alignment.bottomCenter,
                child: Text("Версия 0.8.0")
            ),
          )
        ],
      ),
    ),
    );

  }

}