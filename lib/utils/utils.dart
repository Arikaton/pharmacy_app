import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pharmacy_app/utils/server_wrapper.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils{
  static String createQuery(Map<String, String> query){
    String result = "";
    String check = "";
    for (var v in query.values){
      check += v;
    }
    if (check == "") return "";
    for (var s in query.keys){
      if (query[s] != "" && query[s] != null)
        result += "&$s=${query[s]}";
    }
    result = "?" + result.substring(1);
    return result;
  }

  static Future<bool> checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else
      return false;
  }

  static String convertDate(String date){
    if (date.length < 10) return "";
    return date[8] + date[9] + "." + date[5] + date[6] + "." +  date[0] + date[1] + date[2] + date[3] ;
  }

  static void launchUrl(String url) async {
    if (await canLaunch(url))
      await launch(url);
  }

  static void showHelpInfo(BuildContext context, String url){
    showDialog(
        context: context,
        child: AlertDialog(
          title: Text("Помощь"),
          content: Wrap(
            children: <Widget>[
              Container(
                width: double.infinity,
                child: FlatButton(
                  child: Text("Ожидаемый рецепт не получен"),
                  onPressed: () { Navigator.pop(context); sendMessageDialog(context); },
                  color: Colors.blue,
                ),
              ),
              Container(
                width: double.infinity,
                child: FlatButton(
                  child: Text("Справка по разделу"),
                  onPressed: () => Utils.launchUrl(url),
                  color: Colors.blue,
                ),
              )
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Закрыть"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        )
    );
  }

  static void sendMessageDialog(BuildContext context)
  {
    showDialog(
        context: context,
        child: MyDialog()
    );
  }
}

class MyDialog extends StatefulWidget{
  MyDialogState createState() => MyDialogState();
}

class MyDialogState extends State<MyDialog>{
  var formKey = GlobalKey<FormState>();
  String message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Ожидаемый рецепт не получен"),
      content: Wrap(
        children: <Widget>[
          Text("Сообщить в техническую поддержку информацию, что рецепт, выписанный Вам в медицинском учреждении не доставлен в приложение.\n"),
          Text("Укажите, пожалуйста, ниже в текстовом поле в каком мед. учреждении был выписан рецепт и специальность врача.\n", style: TextStyle(fontSize: 11),),
          Form(
            key: formKey,
            child: TextFormField(
              maxLines: 3,
              onSaved: (value) => message = value,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                )
            ),
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Отмена"),
          onPressed: () => Navigator.pop(context),
        ),
        FlatButton(
          child: Text("Отправить"),
          color: Colors.blue,
          onPressed: sendMessage,
        )
      ],
    );
  }

  void sendMessage() async {
    formKey.currentState.save();
    Map<String, String> mData = {"ParentID": "", "Header": "Ожидаемый рецепт не получен", "Body": message};
    print(mData);
    await ServerMessages.sendMessage(mData);
    Navigator.pop(context);
  }

}