import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:pharmacy_app/utils/links.dart';
import 'package:pharmacy_app/utils/local_storage_wrapper.dart';
import 'package:pharmacy_app/utils/server_wrapper.dart';
import 'package:pharmacy_app/utils/utils.dart';

class MessagesWidget extends StatefulWidget{
  final String messageId;
  final bool goHome;

  const MessagesWidget({Key key, this.messageId, this.goHome = false}) : super(key: key);

  _MessagesWidgetState createState() => _MessagesWidgetState();
}

class _MessagesWidgetState extends State<MessagesWidget>{
  final formKey = GlobalKey<FormState>();
  String newMessage;
  TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onGoBack(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Сообщения'),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => onGoBack(context)
          ),
        ),
        body: FutureBuilder(
          future: ServerMessages.getMessage(widget.messageId),
          builder: (context, snapshot){
            if (snapshot.connectionState == ConnectionState.done){
              List<dynamic> messages = snapshot.data["Messages"];
              return Container(
                margin: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Тема: ${snapshot.data["Header"]}", style: TextStyle(fontSize: 16)),
                    Divider(),
                    Expanded(
                      flex: 3,
                      child: ListView.builder(
                        itemCount: messages.length,
                        itemBuilder: (context, index){
                          Map<String, dynamic> data = messages[index];
                          if (data["Source"] == "Service"){
                            return MessageAnswer(
                              text: data["Body"],
                              date: data["Date"],
                              sourceName: data["SourceName"],
                            );
                          } else {
                            return MessageQuestion(
                              text: data["Body"],
                              date: data["Date"],
                            );
                          }
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Form(
                        key: formKey,
                        child: TextFormField(
                          onSaved: (value) {newMessage = value;},
                          validator: (value){
                            if (value.isEmpty){
                              return 'Введите сообщение';
                            } else {
                              return null;
                            }
                          },
                          maxLines: 3,
                          controller: _textController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Введите текст сообщения'
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: FlatButton(
                        onPressed: () {_sendMessage(snapshot.data["Header"].toString());},
                        color: Colors.blue,
                        child: Text('Отправить сообщение'),
                      ),
                    )
                  ],
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        )
      ),
    );
  }

  Future<bool> onGoBack(BuildContext context){
    if (widget.goHome){
      Navigator.of(context).pushNamedAndRemoveUntil("/HomeLogged", (route) => false);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil('/Messages', (route) => route.isFirst);
    }
  }

  void _sendMessage(String header) async {
    if (formKey.currentState.validate()){
      formKey.currentState.save();
      _textController.clear();
      Map<String, String> mData = {"ParentID": widget.messageId, "Header": header, "Body": newMessage};
      await ServerMessages.sendMessage(mData);
      setState(() {
      });
    }
  }

}

class MessageAnswer extends StatelessWidget{
  final String text;
  final String date;
  final String sourceName;

  const MessageAnswer({Key key, this.text, this.date, this.sourceName}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text('$sourceName:', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                  child: Text(date.replaceAll("T", " ").substring(0, 16), textAlign: TextAlign.right, style: TextStyle(fontSize: 11))
              )
            ],
          ),
          SizedBox(height: 10),
          Container(child: Text(text, textAlign: TextAlign.right,), alignment: Alignment.centerRight,),
          Divider(color: Colors.black,)
        ],
      ),
    );
  }

}

class MessageQuestion extends StatelessWidget{
  final String text;
  final String date;

  const MessageQuestion({Key key, this.text, this.date}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(date.replaceAll("T", " ").substring(0, 16), textAlign: TextAlign.right, style: TextStyle(fontSize: 11)),
              Expanded(child: Text('Я', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right))
            ],
          ),
          SizedBox(height: 10),
          Container(child: Text(text, textAlign: TextAlign.left,), alignment: Alignment.centerLeft,),
          Divider(color: Colors.black,)
        ],
      ),
    );
  }

}

class MessagesListWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Сообщения"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () => Utils.launchUrl(References.messagesPage),
          )
        ],
      ),
      body: FutureBuilder(
        future: getMessagesData(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.done){
            List<dynamic> mList = snapshot.data ?? List();
            if (mList.length == 0){
              return Container(
                margin: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: Text("У вас нет ни одного сообщения"),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: FlatButton(
                        child: Text("Новое обращение"),
                        color: Colors.blue,
                        onPressed: () => Navigator.of(context).pushNamed('/Messages/New'),
                      ),
                    )
                  ],
                ),
              );
            }

            return Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                        itemCount: mList.length,
                        itemBuilder: (context, index){
                          var data = mList[index];
                          return Message(
                            nickName: data["Nikname"].toString(),
                            read: !data["NotRead"],
                            messageId: data["MessageID"].toString(),
                            header: data["Header"].toString(),
                            body: data["Data"]["Body"].toString(),
                            date: data["Data"]["Date"].toString(),
                          );
                        }),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FlatButton(
                      child: Text("Новое обращение"),
                      color: Colors.blue,
                      onPressed: () => Navigator.of(context).pushNamed('/Messages/New'),
                    ),
                  )
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<List<dynamic>> getMessagesData() async{
    bool internet = await Utils.checkInternet();
    if (internet){
      return ServerMessages.getMessageList();
    } else {
      return LocalStorageWrapper.getMessages();
    }
  }
}

class Message extends StatelessWidget{
  final String nickName;
  final String date;
  final bool read;
  final String header;
  final String messageId;
  final String body;

  const Message({Key key, this.nickName, this.date, this.read, this.header, this.messageId, this.body}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed("/Messages/Chat", arguments: messageId),
      child: Container(
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("$nickName: ", style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(child: Text(header, maxLines: 2,), width: 150,),
                Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        !read ? Icon(Icons.brightness_1, color: Colors.red, size: 15,) : SizedBox(),
                        Text(" " + date.substring(0, 10), textAlign: TextAlign.right, style: TextStyle(fontSize: 12),),
                      ],
                    )
                )
              ],
            ),
            Align(
                child: Text(body, maxLines: 2,),
                alignment: Alignment.centerLeft,
            ),
            Divider(color: Colors.black,)
          ],
        ),
      ),
    );
  }

}

class NewMessage extends StatefulWidget{
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage>{
  final formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<HeaderChips> chips = List();
  List<GlobalKey<HeaderChipsState>> chipsKeys = List();
  String currentTheme;
  String newMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Сообщения: Новое обращение")),
      body: FutureBuilder(
        future: getHeaders(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.done){
            return Container(
              child: ListView(
                controller: scrollController,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.all(5),
                      child: Text("Выберите тему обращения:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.left,)
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Wrap(
                      direction: Axis.horizontal,
                      spacing: 5,
                      children: chips,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Form(
                      key: formKey,
                      child: TextFormField(
                        onTap: () {
                          print("on tap");
                            Future.delayed(Duration(milliseconds: 300)).then((_) => scrollController.animateTo(200.0, duration: Duration(milliseconds: 500), curve: Curves.easeOut));
                          } ,
                        onSaved: (value) {newMessage = value;},
                        validator: (value){
                          if (value.isEmpty){
                            return 'Введите сообщение';
                          } else {
                            return null;
                          }
                        },
                        maxLines: 7,
                        controller: _textController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Введите текст сообщения'
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.all(10),
                      child: SizedBox(
                        width: double.infinity,
                        child: FlatButton(
                          child: Text("Отправить сообщение"),
                          onPressed: () => sendMessage(context),
                          color: Colors.blue,
                        ),
                      ),
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
      ),
    );
  }

  void sendMessage(BuildContext context) async {
    if (currentTheme == null){
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("Выберите тему сообщения"),
        duration: Duration(seconds: 2),
      ));
    } else
    if (formKey.currentState.validate()){
      formKey.currentState.save();
      Map<String, String> mData = {"ParentID": "", "Header": currentTheme, "Body": newMessage};
      await ServerMessages.sendMessage(mData);
      var messages = await ServerMessages.getMessageList();
      Navigator.of(context).pushReplacementNamed("/Messages/Chat", arguments: messages[0]['MessageID'].toString());
    }
  }

  Future<void> getHeaders() async {
    var headers = await ServerMessages.getMessageHeader();
    for (int i = 0; i < headers.length; i++){
      chipsKeys.add(GlobalKey<HeaderChipsState>());
      chips.add(
        HeaderChips(
          key: chipsKeys[i],
          label: headers[i].toString(),
          onTap: (String label) {
            currentTheme = label;
            print(label);
            for(var key in chipsKeys){
              key.currentState.setState(() => key.currentState.selected = false);
            }
          },
        )
      );
    }
  }

}

class HeaderChips extends StatefulWidget{
  final Function onTap;
  final String label;

  const HeaderChips({Key key, this.onTap, this.label}) : super(key: key);

  HeaderChipsState createState() => HeaderChipsState();
}

class HeaderChipsState extends State<HeaderChips>{
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(widget.label),
      selected: selected,
      onSelected: (newValue) {
        widget.onTap(widget.label);
        selected = true;
        setState(() {});
      },
    );
  }

}