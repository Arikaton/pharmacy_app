import 'package:flutter/material.dart';
import 'package:pharmacy_app/utils/server_wrapper.dart';
import 'package:pharmacy_app/utils/shared_preferences_wrapper.dart';
import 'package:pin_code_view/pin_code_view.dart';

class PincodeWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Создание пинкода"),),
      body: PinCode(
        backgroundColor: Colors.white,
        obscurePin: true,
        keyTextStyle: TextStyle(color: Colors.black),
        codeTextStyle: TextStyle(color: Colors.black, fontSize: 26),
        title: Text("Введите пинкод"),
        subTitle: Text(""),
        codeLength: 4,
        onCodeSuccess: (code) {
          print(code);
        },
        onCodeFail: (code){
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => PinCodeSave(rightCode: code)));
        },
      ),
    );
  }

}

class PinCodeSave extends StatelessWidget{
  final String rightCode;

  const PinCodeSave({Key key, this.rightCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Сохранение пинкода"),),
      body: PinCode(
        obscurePin: true,
        backgroundColor: Colors.white,
        keyTextStyle: TextStyle(color: Colors.black),
        codeTextStyle: TextStyle(color: Colors.black, fontSize: 26),
        title: Text("Повторите пароль"),
        subTitle: Text(""),
        codeLength: 4,
        correctPin: rightCode,
        onCodeSuccess: (code) async {
          await SharedPreferencesWrap.setPincode(rightCode);
          Navigator.of(context).pushNamedAndRemoveUntil('/MyProfile', (route) => route.isFirst);
        },
        onCodeFail: (code) {
          showDialog(context: context,
          child: AlertDialog(
            content: Text("Вы ввели неправильный пинкод"),
            actions: <Widget>[
              FlatButton(
                child: Text("Ок"),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ));
        },
      ),
    );
  }

}

class PinCodeLogin extends StatelessWidget{
  final String rightCode;

  const PinCodeLogin({Key key, this.rightCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PinCode(
        obscurePin: true,
        backgroundColor: Colors.white,
        keyTextStyle: TextStyle(color: Colors.black),
        codeTextStyle: TextStyle(color: Colors.black, fontSize: 26),
        title: Text("Введите пинкод"),
        subTitle: Text(""),
        codeLength: 4,
        correctPin: rightCode,
        onCodeSuccess: (code) async {
          await SharedPreferencesWrap.setPincode(rightCode);
          Navigator.of(context).pushNamedAndRemoveUntil('/HomeLogged', (route) => false);
        },
        onCodeFail: (code) {
          showDialog(context: context,
              child: AlertDialog(
                content: Text("Вы ввели неправильный пинкод"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Сбросить пинкод"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _logout(context);
                    }
                  ),
                  FlatButton(
                    child: Text("Повторить"),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ));
        },
      ),
    );
  }

  _logout(BuildContext context) async {
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
                await SharedPreferencesWrap.setPincode(null);
                await SharedPreferencesWrap.setLoginInfo(false);
                SharedPreferencesWrap.setConfirmationToken("");
                SharedPreferencesWrap.setAccessToken("");
                Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
              },
            ),
          ],
        )
    );
  }

}