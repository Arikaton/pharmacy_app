import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:pharmacy_app/utils/server_wrapper.dart';
import 'package:url_launcher/url_launcher.dart';

class RelativesEdit extends StatefulWidget{
  final data;

  const RelativesEdit({Key key, this.data}) : super(key: key);

  RelativesEditState createState() => RelativesEditState();
}

class RelativesEditState extends State<RelativesEdit>{
  final topTextPadding = const EdgeInsets.only(bottom: 8);
  final upTextStyle = const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  final scaKey = GlobalKey<ScaffoldState>();

  final _key = GlobalKey<FormState>();

  final dateMask = MaskTextInputFormatter(mask: '##/##/####', filter: {'#': RegExp(r'[0-9]')});

  String surname = "";
  String name = "";
  String patronymic = "";
  String date = "";
  bool male = true;

  @override
  void initState() {
    super.initState();
    male = widget.data["gender"] == "M" ? true : false;
    surname = widget.data["surname"];
    name = widget.data["name"];
    patronymic = widget.data["patronymic"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaKey,
      appBar: AppBar(title: Text("Редактирование родственника"),),
      body: Container(
        margin: EdgeInsets.all(14),
        child: Form(
          key: _key,
          child: Column(
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
                    initialValue: widget.data["surname"],
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
                    initialValue: widget.data["name"],
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
                    initialValue: widget.data["patronymic"],
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
                    initialValue: widget.data["date"],
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
              SizedBox(
                width: double.infinity,
                child: FlatButton(
                  color: Color.fromARGB(255, 68, 156, 202),
                  child: Text("Сохранить", style: TextStyle(fontSize: 18, color: Colors.grey[900]), textAlign: TextAlign.center),
                  onPressed: () async {
                    if (_key.currentState.validate()){
                      _key.currentState.save();
                      Map<String, String> data = {"Surname": surname, "Name": name, "MiddleName": patronymic,
                        "Gender": male == true ? "M" : "F", "Birthday": convertDate(date), "eMail": ""};
                      await ServerProfile.changeUserData(data, userId: widget.data["userID"]);
                      Navigator.of(context).pushNamedAndRemoveUntil('/Relatives/Inside', (route) => route.isFirst ,arguments: widget.data["userID"]);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
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