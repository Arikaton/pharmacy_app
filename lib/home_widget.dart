import 'dart:convert';
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:pharmacy_app/recipes/recipe_card_widget.dart';
import 'package:pharmacy_app/tablets/tablets_inside.dart';
import 'package:pharmacy_app/utils/links.dart';
import 'package:pharmacy_app/utils/local_storage_wrapper.dart';
import 'package:pharmacy_app/utils/server_wrapper.dart';
import 'dart:math';
import 'package:pharmacy_app/profile_widget.dart';
import 'package:pharmacy_app/tablets/tablets_widget.dart';
import 'package:pharmacy_app/utils/shared_preferences_wrapper.dart';
import 'package:pharmacy_app/utils/utils.dart';
import 'package:pharmacy_app/warning_ESIA.dart';
import 'message_card_widget.dart';
import 'news_card_widget.dart';
import 'package:pharmacy_app/main.dart';
import 'utils/utils.dart';

class HomeLogged extends StatefulWidget{
  final int firstTab;

  const HomeLogged({Key key, this.firstTab}) : super(key: key);

  @override
  _HomeLoggedState createState() => _HomeLoggedState();
}

class _HomeLoggedState extends State<HomeLogged> with WidgetsBindingObserver {
  static bool warningWasShowed = false;
  static bool helpMessageWasShowed = false;
  int _selectedIndex;

  List<String> _titleTexts = ['Главная', "Таблеточница", "Профиль"];
  List<Widget> _homeWidgets;

  static Map<String, dynamic> prevResumeMessage = Map();
  static Map<String, dynamic> prevMessage = Map();
  static String localPayload;

  @override
  void initState(){
    print("---------init Home logged-----------");
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    selectNotificationSubject.stream.listen((payload) => onLocalNotification(payload));
    onResumeStream.stream.listen((message) => onResume(message));
    onMessageStream.stream.listen((message) => onMessage(message));
    _selectedIndex = widget.firstTab ?? 0;
    _homeWidgets = [HomePageWidget(), TabletsMain(), MainProfile()];
    showWarningESIA();
    SharedPreferencesWrap.getHelpState().then((state) { if (state = true) showHelpESIAMessage(); } );
  }

  void showHelpESIAMessage(){
    AlertDialog alertDialog = AlertDialog(
      title: Text("Внимание!", style: TextStyle(fontWeight: FontWeight.bold)),
      content: Wrap(

        children: <Widget>[
          Text("Вновь выписанные рецепты становятся доступны"),
          Text("В течение 10-15 минут.\n", style: TextStyle(fontWeight: FontWeight.bold)),
          Text("Если по истечении этого времени вы не увидели нужный рецепт на главном экране, нажмите на кнопку "),
          Icon(Icons.info, color: Colors.blue,),
          Text(" в правом верхнем углу приложенияя, затем выберите строку "),
          Text('"Ожидаемый рецепт не получен".\n', style: TextStyle(fontWeight: FontWeight.bold),),
          Text("Вопрос будет решён в кратчайшие сроки")
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Закрыть и больше не напоминать"),
          onPressed: () async {
            await SharedPreferencesWrap.setHelpState(false);
            Navigator.pop(context);
          },
        ),
        FlatButton(
          child: Text("Закрыть"),
          color: Colors.blue,
          onPressed: (){
            helpMessageWasShowed = true;
            Navigator.of(context).pop();
          }
        )
      ],
    );
    if (!helpMessageWasShowed)
      showDialog(context: context, child: alertDialog);
  }

  void showWarningESIA() async {
    var profileData = await ServerProfile.getUserProfile();
    final bool esiaConfirm = profileData["ESIAConfirm"] as bool;
    if (!esiaConfirm && !warningWasShowed){
      Navigator.of(context).pushNamed('/ESIAWarning');
      warningWasShowed = true;
    }
  }

  void closeNotOnMes() {
    Navigator.of(context).pushNamedAndRemoveUntil('/HomeLogged', (route) => false);
  }

  void onMessage(Map<String, dynamic> message) async {
    if (message == prevMessage)
      return;
    else prevMessage = message;
    ServerNews.getNewsCard();
    ServerNews.getPages();

    await Future.delayed(Duration(seconds: 1));

    var messageType = message['data']['messageType'].toString();
    switch (messageType)
    {
      case "recipe":
        List<String> newData = <String>[message['data']['recipeID'].toString(), message['data']['recipeName'].toString()];
        showDialog(
          context: context,
          child: AlertDialog(
            content: Text("Вам поступил рецепт."),
            actions: <Widget>[
              FlatButton(
                child: Text("Перейти"),
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/RecipeWidget', (route) => route.isFirst, arguments: newData)
              ),
              FlatButton(
                child: Text("Закрыть"),
                onPressed: closeNotOnMes,
              )
            ],
          )
        );
        break;
      case "message":
        showDialog(
          context: context,
          child: AlertDialog(
            content: Text("Вам поступило сообщение."),
            actions: <Widget>[
              FlatButton(
                  child: Text("Перейти"),
                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil("/Messages/Chat", (route) => route.isFirst, arguments: message['data']['messageID'].toString())
              ),
              FlatButton(
                child: Text("Закрыть"),
                onPressed: closeNotOnMes,
              )
            ],
          )
        );
        break;
      case 'news':
        showDialog(
            context: context,
            child: AlertDialog(
              content: Text("Вам поступила новость."),
              actions: <Widget>[
                FlatButton(
                    child: Text("Перейти"),
                    onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/News', (route) => route.isFirst, arguments: message['data']['newsID'].toString())
                ),
                FlatButton(
                  child: Text("Закрыть"),
                  onPressed: closeNotOnMes,
                )
              ],
            )
        );
        break;
    }

  }

  void onResume(Map<String, dynamic> message) async {
    if (message == prevResumeMessage)
      return;
    else prevResumeMessage = message;
    await Future.delayed(Duration(seconds: 2));
    print(message);
    var messageType = message['data']['messageType'].toString();
    switch (messageType)
    {
      case "recipe":
        List<String> newData = <String>[message['data']['recipeID'].toString(), message['data']['recipeName'].toString()];
        ServerRecipe.readRecipe(message['data']['recipeID']);
        Navigator.of(context).pushNamed('/RecipeWidget', arguments: newData);
        break;
      case "message":
        Navigator.of(context).pushNamed("/Messages/Chat", arguments: message['data']['messageID'].toString());
        break;
      case 'news':
        ServerNews.readNews(message['data']['newsID']);
        Navigator.of(context).pushNamed('/News', arguments: message['data']['newsID'].toString());
    }
  }

  void onLocalNotification(String payload) async {
    if (localPayload == payload){
      return;
    } else localPayload = payload;
    await Future.delayed(Duration(seconds: 1));
    Map<String, dynamic> data = jsonDecode(payload);
    data["TabletId"] = data["KursID"].toString() + DateTime.now().month.toString() + DateTime.now().day.toString() + data["Time"];
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TabletsInside(data: data,)),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed){
      onResumeStream.stream.listen((message) => onResume(message));
      onMessageStream.stream.listen((message) => onMessage(message));
      selectNotificationSubject.stream.listen((payload) => onLocalNotification(payload));
    } else if (state == AppLifecycleState.paused){
      onMessageStream.close();
      onResumeStream.close();
      selectNotificationSubject.close();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    onMessageStream.close();
    onResumeStream.close();
    selectNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_titleTexts[_selectedIndex]),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () => Utils.showHelpInfo(context, References.mainPage),
            )
          ],
      ),

      body: _homeWidgets[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Главная'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            title: Text('Таблеточница'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('Профиль'),
          ),
        ],
      ),

      floatingActionButton: _selectedIndex == 1 ? FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.of(context).pushNamed('Tablets_ChooseRecipe'),
      ) : null
    );
  }

  void _onItemTapped(int index){
    setState((){
      _selectedIndex = index;
    });
  }
}

class HomePageWidget extends StatefulWidget{
  _HomePageWidgetState createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget>{
  final random = Random();
  final flutterWebViewPlugin = FlutterWebviewPlugin();

  List<Widget> mainContent = new List<Widget>();
  List<Widget> persistantContent = new List<Widget>();

//  ProgressDialog progressDialog;

  @override
  void initState() {
    print("--------------------Home Page-------------------");
    super.initState();
      refreshNews();
      //webViewListener();
    }

  @override
  Widget build(BuildContext context) {
//    progressDialog = ProgressDialog(context, type: ProgressDialogType.Normal);
//    progressDialog.style(message: "Новости загружаются...");
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                ChipsWidget(
                  onTap: filterNews,
                ),
              ],
            )
          ),
          Container(
            child: Expanded(
              child: RefreshIndicator(
                onRefresh: () async { refreshNews();},
                child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: persistantContent.length,
                    itemBuilder: (context, pos) => (
                        persistantContent[pos]
                    )
                ),
              )
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> createWidgets(List<dynamic> content) {
    if (content.length == 0){
      return [Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(child: Text("Данные загружаются...", textAlign: TextAlign.center,)),
      )];
    }
    List<Widget> contentWidgets = List();

    for (int i = 0; i < content.length; i++) {
      Map<String, dynamic> data = content[i]['Data'];
      if (content[i]["TypeData"] == "News"){
        contentWidgets.add(NewsCard(
          newsID: content[i]["ID"].toString(),
          titleText: data['Header'].toString(),
          bodyText: data['Body'].toString(),
          botSource: data['Source'].toString(),
          date: data['Date'].toString().replaceAll("T", ' '),
          url: content[i]['ext_link'].toString(),
          read: content[i]['NotRead'] as bool,
        )
        );
      }
      else if (content[i]["TypeData"] == "Recipe"){
        contentWidgets.add(RecipeCard(
          prioritet: data["Prioritet"],
          purchased: data["Purchased"],
          recipeName: data["Number"].toString(),
          goods: data["Goods"],
          hospital: data["Hospital"],
          date: data['Date'].toString(),
          personName: data["PatientFIO"].toString(),
          id: content[i]["ID"].toString(),
          notRead: content[i]["NotRead"] as bool,
          onTap: (context) async {
            bool internet = await Utils.checkInternet();
            if (internet)
              await ServerRecipe.readRecipe(content[i]["ID"].toString());
            Navigator.of(context).pushNamed("/RecipeWidget", arguments: [content[i]["ID"].toString(), data["Number"].toString()]);
          },
        ));
      }
      else if (content[i]["TypeData"] == "Message"){
        contentWidgets.add(MessageCard(
          messageID: content[i]["ID"],
          read: content[i]["NotRead"] as bool,
          titleText: data['Header'].toString(),
          bodyText: data['Body'].toString(),
          botSource: "Источник: " + data['SourceName'].toString(),
          date: data['Date'].toString().replaceAll("T", ' '),
        ));
      }
    }
    return contentWidgets;
  }

  void refreshNews() async {
    ServerWrapper.refreshAccessToken();
    var content = await LocalStorageWrapper.getNews() ?? List();
//    progressDialog.hide();
    mainContent = createWidgets(content);
    ServerNews.getNewsCard().then((newContent) {
      mainContent = createWidgets(newContent);
      filterNews();
    });
    filterNews();
  }

  void filterNews(){
    List<Widget> filteredContent = new List();
    var chipName = _ChipWithBadgeState.activeWidgetName;
    if (chipName == "Все") {
      for (int i = 0; i < mainContent.length; i++){
        if (mainContent[i].toStringShort() != "MessageCard"){
          filteredContent.add(mainContent[i]);
        }
      }
      persistantContent = filteredContent;
      setState(() {});
      return;
    }
    for (int i = 0; i < mainContent.length; i++){
      switch(mainContent[i].toStringShort()){
        case "NewsCard":
          if (chipName == "Новости"){
            filteredContent.add(mainContent[i]);
          }
          break;
        case "RecipeCard":
          if (chipName == "Рецепты"){
            filteredContent.add(mainContent[i]);
          }
          break;
        case "MessageCard":
          if (chipName == "Сообщения"){
            filteredContent.add(mainContent[i]);
          }
      }
    }
    persistantContent = filteredContent;
    setState(() {});
  }

}

class ChipsWidget extends StatefulWidget{
  final Function onTap;

  const ChipsWidget({Key key, this.onTap}) : super(key: key);

  _ChipsWidgetState createState() => _ChipsWidgetState();
}

class _ChipsWidgetState extends State<ChipsWidget>{
  List<Widget> chips = new List<Widget>();
  List<dynamic> homePages;
  List<GlobalKey> keys = new List();

  @override
  void initState() {
    super.initState();
    getPages();
    _ChipWithBadgeState.activeWidgetName = "Все";
    refreshChipsFast();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: chips
      ),
    );
  }

  void getPages() async {
    bool internet = await Utils.checkInternet();
    if (!internet){
      homePages = await LocalStorageWrapper.getNewsPages();
    } else {
      homePages = await ServerNews.getPages();
    }
    refreshChips();
  }

  void refreshChips(){
    chips.clear();
    keys.add(GlobalKey<_ChipWithBadgeState>());
    chips.add(ChipWithBadge(
      key: keys[0],
      name: "Все",
      newsCount: "0",
      id: "Все",
      onTap: () {
        refreshChipsFast();
        widget.onTap();
      },
    ));
    for (int i = 0; i < homePages.length; i++) {
      keys.add(GlobalKey<_ChipWithBadgeState>());
      chips.add(
          ChipWithBadge(
            key: keys[i+1],
            name: homePages[i]["Name"].toString(),
            newsCount: homePages[i]["New"].toString(),
            id: homePages[i]["Name"].toString(),
            onTap: () {
              refreshChipsFast();
              widget.onTap();
            },
          )
      );
    }
    setState(() {});
  }

  void refreshChipsFast() {
    for (int i = 0; i < keys.length; i++){
      keys[i].currentState.setState((){});
    }
  }
}

class ChipWithBadge extends StatefulWidget{
  final Function onTap;
  final String name;
  final String newsCount;
  final String id;

  const ChipWithBadge({Key key, this.name, this.newsCount, this.id, this.onTap}) : super(key: key);

  _ChipWithBadgeState createState() => _ChipWithBadgeState();
}

class _ChipWithBadgeState extends State<ChipWithBadge>{
  static String activeWidgetName;
  @override
  Widget build(BuildContext context) {
    if (widget.newsCount != "0"){
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Badge(
          position: BadgePosition.topRight(top: 0, right: -4),
          badgeColor: Colors.red,
          badgeContent: Text(widget.newsCount, style: TextStyle(fontSize: 10, color: Colors.white)),
          child: ChoiceChip(
            label: Text(widget.name),
            onSelected: (_) {
              activeWidgetName = widget.id;
              widget.onTap();
            },
            selected: widget.id == activeWidgetName
          ),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: ChoiceChip(
          label: Text(widget.name),
          onSelected: (_) {
            activeWidgetName = widget.id;
            widget.onTap();
          },
          selected: widget.id == activeWidgetName,
        ),
      );
    }
  }
}