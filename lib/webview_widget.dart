import 'dart:async';

import 'package:flutter/material.dart';
import "package:flutter_webview_plugin/flutter_webview_plugin.dart";
import 'package:pharmacy_app/utils/server_wrapper.dart';
import 'package:pharmacy_app/utils/shared_preferences_wrapper.dart';

class WebViewWidget extends StatefulWidget{
  final List<String> url;

  const WebViewWidget({Key key, this.url}) : super(key: key);

  _WebViewWidgetState createState() => _WebViewWidgetState();

}

class _WebViewWidgetState extends State<WebViewWidget>{
  final flutterWebviewPlugin = FlutterWebviewPlugin();

  StreamSubscription<String> _onUrlChanged;
  StreamSubscription<WebViewStateChanged> _onStateChanged;

  @override
  void initState() {
    super.initState();
    flutterWebviewPlugin.close();

    _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen((String url) {
      var uri = Uri.parse(url);
      var query = uri.queryParameters;
      if (query["error"] != null){
        catchError(query['error_description']);
      }
      if (query["code"] != null){
        postEsiaAndClose(query['code'], query['state']);
      }
    });

    /*_onStateChanged = flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      var uri = Uri.parse(state.url);
      uri.queryParameters.forEach((k, v) {
        print('key: $k - value: $v');
      });
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      clearCache: true,
      clearCookies: true,
      appCacheEnabled: false,
      hidden: true,
      url: widget.url[0],
      appBar: AppBar(
        title: Text('Вход через "Госуслуги"'),
      ),
    );
  }
  
  void catchError(String state) async {
    await ServerLogin.postDataFromEsia("", state);
    Navigator.of(context).pushNamedAndRemoveUntil("/HomeLogged", (route) => false);
    showDialog(context: context,
    child: AlertDialog(
      content: Text("Во время авторизации произошла ошибка. Данные переданы в техническую поддержку. Попробуйте позже."),
      actions: <Widget>[
        FlatButton(child: Text("Закрыть"), onPressed: () => Navigator.of(context).pop(),)
      ],
    ));
  }

  void postEsiaAndClose(String code, String state) async {
    bool success;
    print('Ща будем отправлять на сервак всякое');
    if (widget.url.length == 1){
      print('шлем на сервак из профиля');
      success = await ServerLogin.postDataFromEsia(code, state);
    } else {
      success = await ServerLogin.postDataFromEsia(code, state, userID: widget.url[1]);
      print('Шлем на сервак из родствеников');
    }
    if (!success){
      _showSnackBar(context);
    } else {
      if (widget.url.length == 1){
        await SharedPreferencesWrap.setHelpState(true);
        Navigator.of(context).pushNamedAndRemoveUntil("/HomeLogged", (route) => false);
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil("/Relatives", (route) => route.isFirst, arguments: "");
      }
    }
  }

  void _showSnackBar(BuildContext context){
    var snackBar = SnackBar(
        content: Text("Сервер авторизации Госуслуги временно не доступен."),
        action: SnackBarAction(label: "ок", onPressed: () {},)
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }
}