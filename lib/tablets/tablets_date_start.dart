import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pharmacy_app/utils/links.dart';
import 'package:pharmacy_app/utils/server_wrapper.dart';
import 'package:pharmacy_app/utils/utils.dart';

class TabletsDate extends StatefulWidget{
  final Map<String, dynamic> data;

  const TabletsDate({Key key, this.data}) : super(key: key);

  TabletsDateState createState() => TabletsDateState();
}

class TabletsDateState extends State<TabletsDate>{
  static const TextStyle infoStyle = TextStyle(fontWeight: FontWeight.bold);
  var scaffoldState = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    print("---------tablets date start init-----------");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldState,
      appBar: AppBar(
          title: Text("Шаг 2: дата начала приёма"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () => Utils.showHelpInfo(context, References.tabletsPage),
            )
          ],
      ),
      body: widget.data["HaveRecipe"] ? TabletsDateHaveRecipe(recipeId: widget.data["RecipeId"], scaffoldState: scaffoldState) :
      TabletsDateNoRecipe(recipeName: widget.data["RecipeName"], scaffoldState: scaffoldState),
    );
  }

  void showDateTimePicker(BuildContext context) async {
    print("I'm here");
    DateTime newDateTime = await showRoundedDatePicker(
        context: context,
        locale: Locale("ru"),
        initialDatePickerMode: DatePickerMode.day,
        initialDate: DateTime.now(),
        firstDate: DateTime(DateTime.now().month - 1),
        lastDate: DateTime(DateTime.now().year + 1),
        borderRadius: 16
    );
  }
}

class TabletsDateHaveRecipe extends StatefulWidget {
  final String recipeId;
  final scaffoldState;

  const TabletsDateHaveRecipe({Key key, this.recipeId, this.scaffoldState}) : super(key: key);

  TabletsDateHaveRecipeState createState() => TabletsDateHaveRecipeState();
}

class TabletsDateHaveRecipeState extends State<TabletsDateHaveRecipe>{
  static const TextStyle infoStyle = TextStyle(fontWeight: FontWeight.bold);
  String choosenDate = "";

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ServerRecipe.getRecipeBody(widget.recipeId),
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.done){
          Map<String, dynamic> data = snapshot.data;
          return Container(
            margin: EdgeInsets.all(5),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text("Описание назначения врача"),
                      ),
                      Text('Лечебное учреждение:'),
                      Text(data['Hospital'].toString(), style: infoStyle,),
                      Text('Ваш врач:'),
                      Text(data['Doctor'].toString(), style: infoStyle,),
                      //Text('Наименование МНН:'),
                      //Text(data['Goods']["MNN"].toString(), style: infoStyle,),
                      Text("Препарат:"),
                      Text(data['Goods']["Purpose"].toString(), style: infoStyle,),
                      Row(
                        children: <Widget>[
                          Text('Количество стандартов: '),
                          Text(data['Goods']["Count_standarts"].toString(), style: infoStyle,),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text('Дозировка: '),
                          Text(data['Goods']["Dose"].toString(), style: infoStyle,),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text('Форма выпуска: '),
                          Text(data['Goods']["Form_release"].toString(), style: infoStyle,),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text('Количество дней приёма препарата: '),
                          Text(data['Goods']["Count_days_use_drug"].toString(), style: infoStyle,),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text('Количество приёма в день: '),
                          Text(data['Goods']["Count_per_day"].toString(), style: infoStyle,),
                        ],
                      ),
                      Text('Описание приёма препарата врачем:'),
                      Text(data['Goods']["DescriptionFromDoctor"].toString(), style: infoStyle),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20, bottom: 10),
                  width: double.infinity,
                  child: FlatButton(
                    child: Text("Введите дату"),
                    color: Colors.blue,
                    onPressed: () {
                      showRoundedDatePicker(
                          context: context,
                          locale: Locale("ru"),
                          initialDatePickerMode: DatePickerMode.day,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(DateTime.now().month - 1),
                          lastDate: DateTime(DateTime.now().year + 1),
                          borderRadius: 16
                      ).then((date){
                        setState(() {
                          choosenDate = date.toIso8601String().substring(0, 10);
                        });
                      });
                    },
                  ),
                ),
                Align(
                  child: Text(
                    choosenDate != "" ? "Выбранная дата: ${choosenDate.substring(0, 10)}" : "Выбранная дата:",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18),
                  ),
                  alignment: Alignment.centerLeft,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        child: FlatButton(
                          child: Text("Далее"),
                          color: Colors.blue,
                          onPressed: () {
                            if (choosenDate != ""){
                              Navigator.of(context).pushNamed('/Tablets/Statement', arguments: {"TabletsPerDay": data['Goods']["Count_per_day"], "RecipeName": data['Goods']["Purpose"].toString(), "Duration": data['Goods']["Count_days_use_drug"], "ChosenDate": choosenDate, "Dosage": data["Goods"]["Dose"].toString(), "RecipeID": widget.recipeId});
                            } else {
                              widget.scaffoldState.currentState.showSnackBar(SnackBar(
                                content: Text("Введите дату"),
                                duration: Duration(seconds: 2),
                              ));
                            }
                          },
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: FlatButton(
                          child: Text("Назад"),
                          color: Colors.blue,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
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
      }
    );
  }

}

class TabletsDateNoRecipe extends StatefulWidget {
  final String recipeName;
  final scaffoldState;

  const TabletsDateNoRecipe({Key key, this.recipeName, this.scaffoldState}) : super(key: key);

  TabletsDateNoRecipeState createState() => TabletsDateNoRecipeState();
}

class TabletsDateNoRecipeState extends State<TabletsDateNoRecipe>{
  final formKey = GlobalKey<FormState>();
  int duration;
  int tabletsPerDay;
  String dosage;

  String choosenDate = "";
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text("Препарат: ${widget.recipeName}", style: TextStyle(fontSize: 18)),
          ),
          Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                //Text("Длительность приёма: "),
                Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  height: 50,
                  child: TextFormField(
                    onSaved: (value) => duration = int.parse(value),
                    validator: (value) {
                      if (value.isEmpty){
                        return "Введите длительность приёма";
                      } else if (value.contains(".") || value.contains("-")){
                        return "Введите целое число";
                      } else if (value.length > 2){
                        return "Введите число меньше 100";
                      } else {return null; }
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Длительность приёма (дней)",
                      border: OutlineInputBorder()
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  height: 50,
                  child: TextFormField(
                    onSaved: (value) => dosage = value,
                    validator: (value) {
                      if (value.isEmpty){
                        return "Введите дозировку";
                      } else if (value.contains("-")){
                        return "Удалите '-'";
                      } else {return null; }
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: "Дозировка",
                        border: OutlineInputBorder()
                    ),
                  ),
                ),
                //Text("Количество приёма в день: "),
                Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  height: 50,
                  child: TextFormField(
                    onSaved: (value) => tabletsPerDay = int.parse(value),
                    validator: (value) {
                      if (value.isEmpty){
                        return "Введите кол-во приёма в день";
                      } else if (value.contains(".") || value.contains("-")){
                        return "Введите целое число";
                      } else if (int.parse(value) > 15){
                        return "Введите значение меньше 15";
                      } else {
                        return null;
                      }
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Количество приёма в день",
                      border: OutlineInputBorder()
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20, bottom: 10),
            width: double.infinity,
            child: FlatButton(
              child: Text("Введите дату"),
              color: Colors.blue,
              onPressed: () {
                showRoundedDatePicker(
                    context: context,
                    locale: Locale("ru"),
                    initialDatePickerMode: DatePickerMode.day,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(DateTime.now().month - 1),
                    lastDate: DateTime(DateTime.now().year + 1),
                    borderRadius: 16
                ).then((date){
                  setState(() {
                    choosenDate = date.toIso8601String().substring(0, 10);
                  });
                });
              },
            ),
          ),
          Align(
            child: Text(
              choosenDate != "" ? "Выбранная дата: ${choosenDate.substring(0, 10)}" : "Выбранная дата:",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 18),
            ),
            alignment: Alignment.centerLeft,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  child: FlatButton(
                      child: Text("Далее"),
                      color: Colors.blue,
                      onPressed: pushNext
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: FlatButton(
                    child: Text("Назад"),
                    color: Colors.blue,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void pushNext(){
    if (choosenDate != ""){
      if (formKey.currentState.validate()){
        formKey.currentState.save();
        Navigator.of(context).pushNamed('/Tablets/Statement', arguments: {"TabletsPerDay": tabletsPerDay, "RecipeName": widget.recipeName, "Duration": duration, "ChosenDate": choosenDate, "Dosage": dosage});
      }
    } else {
      widget.scaffoldState.currentState.showSnackBar(SnackBar(
        content: Text("Введите дату"),
        duration: Duration(seconds: 2),
      ));
    }
  }

}