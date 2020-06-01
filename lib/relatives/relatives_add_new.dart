import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:pharmacy_app/utils/links.dart';
import 'package:pharmacy_app/utils/server_wrapper.dart';
import 'package:url_launcher/url_launcher.dart';

class RelativesAddNew extends StatefulWidget{
  final userID;

  const RelativesAddNew({Key key, this.userID}) : super(key: key);

  RelativesAddNewState createState() => RelativesAddNewState();
}

class RelativesAddNewState extends State<RelativesAddNew>{
  final topTextPadding = const EdgeInsets.only(bottom: 8);
  final upTextStyle = const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  final scaKey = GlobalKey<ScaffoldState>();

  final _key = GlobalKey<FormState>();

  //final phoneMask = MaskTextInputFormatter(mask: '###-###-##-##', filter: {'#': RegExp(r'[0-9]')});
  final dateMask = MaskTextInputFormatter(mask: '##/##/####', filter: {'#': RegExp(r'[0-9]')});
  final phoneMask = MaskTextInputFormatter(mask: '###-###-##-##', filter: {'#': RegExp(r'[0-9]')});

  String surname = "";
  String name = "";
  String patronymic = "";
  String date = "";
  String phoneNumber = "";
  bool male = true;
  bool agree = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaKey,
      appBar: AppBar(title: Text("Добавление родственника"),),
      body: Container(
        margin: EdgeInsets.all(14),
        child: Form(
          key: _key,
          child: ListView(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 3),
                    child: TextFormField(
                        //initialValue: widget.data["surname"] ?? "",
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
                    margin: EdgeInsets.symmetric(vertical: 3),
                    child: TextFormField(
                        //initialValue: widget.data["name"] ?? "",
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
                    margin: EdgeInsets.symmetric(vertical: 3),
                    child: TextFormField(
                        //initialValue: widget.data["patronymic"] ?? "",
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
                    margin: EdgeInsets.symmetric(vertical: 3),
                    child: TextFormField(
                        //initialValue: widget.data["date"] ?? "",
                        validator: (value) {if (value.isEmpty){return 'Введите дату рождения';} else if (value.length < 10){return null;} else {
                          return null;}
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
                    margin: EdgeInsets.symmetric(vertical: 3),
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
                      keyboardType: TextInputType.numberWithOptions(),
                      textAlign: TextAlign.start,
                      onSaved: (value) => phoneNumber = value,
                      style: TextStyle(fontSize: 20, letterSpacing: 1),
                      decoration: InputDecoration(
                        prefixText: "8-",
                        contentPadding: EdgeInsets.only(left: 85),
                        hintText: '___-___-__-__',
                        prefixStyle: TextStyle(color: Colors.black, fontSize: 20),
                        border: OutlineInputBorder(),
                        labelText: "Номер телефона"
                      ),
                    ),
                  ),
                  Text("Пол", style: TextStyle(fontSize: 20),),
                  Container(
                    child: Row(
                      children: <Widget>[
                        ChoiceChip(
                          onSelected: (_) {setState(() {male = true;});},
                          label: Text("Мужской"),
                          selected: male == true,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        ChoiceChip(
                          onSelected: (_) {setState(() {male = false;});},
                          label: Text("Женский"),
                          selected: male == false,
                        ),
                      ],
                    ),
                  ),
                  Text("Согласие на обработку данных", style: TextStyle(fontSize: 20)),
                  Container(
                    child: Row(
                      children: <Widget>[
                        ChoiceChip(
                          onSelected: (_) {setState(() {agree = !agree;});},
                          label: Text("Нет"),
                          selected: !agree,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        ChoiceChip(
                          onSelected: (_) {setState(() {agree = !agree;});},
                          label: Text("Да"),
                          selected: agree,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FlatButton(
                      color: agree ? Color.fromARGB(255, 68, 156, 202) : Colors.black54,
                      child: Text("Сохранить", style: TextStyle(fontSize: 18, color: Colors.grey[900]), textAlign: TextAlign.center),
                      onPressed: () async {
                        if (_key.currentState.validate() && agree){
                          _key.currentState.save();

                          String token = await ServerRelatives.addRelative(agree, {"Nikname": "", "Surname": surname, "Name": name, "MiddleName": patronymic, "Gender": male ? "M" : "F", "Birthday": convertDate(date), "Phone": phoneNumber} );
                          if (token != ""){
                            Navigator.of(context).pushNamed('/Relatives/Confirm', arguments: token);
                          } else {
                            scaKey.currentState.showSnackBar(SnackBar(content: Text("Ошибка на сервере, повторите запрос позже")));
                          }
                        }
                      },
                    ),
                  ),
                  Center(
                    child: GestureDetector(
                        onTap: () => _launchURL(References.license),
                        child: Text("Лицензионное соглашение", style: TextStyle(color: Colors.lightBlueAccent, fontSize: 16))
                    ),
                  ),
                  Center(
                    child: GestureDetector(
                        onTap: () => _launchURL(References.police),
                        child: Text("Политика конфиденциальности", style: TextStyle(color: Colors.lightBlueAccent, fontSize: 16))
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
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

class RelativesConfirmToken extends StatefulWidget{
  final String token;

  const RelativesConfirmToken({Key key, this.token}) : super(key: key);

  RelativesConfirmTokenState createState() => RelativesConfirmTokenState();
}

class RelativesConfirmTokenState extends State<RelativesConfirmToken>{
  final formKey = GlobalKey<FormState>();
  String sms = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Подтверждение")),
      body: Container(
          margin: EdgeInsets.symmetric(vertical: 40, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('009. Электронные рецепты', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Container(
                height: 60,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text('На номер указанного Вами телефона родственника отправленна СМС с 4-х значным кодом доступа в приложение', textAlign: TextAlign.center,),
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
                  onPressed: () async {
                    if (formKey.currentState.validate()){
                      formKey.currentState.save();
                      if (await ServerRelatives.confirmMessage(widget.token, sms)){
                        Navigator.of(context).pushNamedAndRemoveUntil('/Relatives', (route) => route.isFirst);
                      }
                    }
                  },
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
            ],
          )
      ),
    );
  }

}