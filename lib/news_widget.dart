import 'package:flutter/material.dart';
import 'package:pharmacy_app/home_widget.dart';
import 'package:pharmacy_app/utils/links.dart';
import 'package:pharmacy_app/utils/server_wrapper.dart';
import 'package:pharmacy_app/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsWidget extends StatelessWidget{
  final String newsID;
  final int pageType;

  const NewsWidget(this.newsID, {Key key, this.pageType = 1}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onComeBack(context),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Главная - Новости'),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => _onComeBack(context)
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () => Utils.showHelpInfo(context, References.newsPage),
            )
          ],
        ),
        body: FutureBuilder(
          future: ServerNews.getNewsBody(newsID),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done){
              Map<String, dynamic> data = snapshot.data;
              return Container(
                padding: EdgeInsets.all(4),
                color: Color.fromARGB(255, 217, 253, 255),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Column(
                        children: <Widget>[
                          Text(data['Header'], style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(data["Date"], style: TextStyle(
                                    fontSize: 9, color: Colors.black54),),
                              ),
                              Text(data["Source"], style: TextStyle(
                                  fontSize: 9, color: Colors.black54))
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: <Widget>[
                          Text(data["Body"]),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: FlatButton(
                        color: Colors.blue,
                        child: Text('Перейти на сайт'),
                        onPressed: () => _launchURL(data),
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
      ),
    );
  }

  _onComeBack(BuildContext context){
    switch (pageType){
      case 0:
        Navigator.pop(context);
        break;
      case 1:
        Navigator.of(context).pushNamedAndRemoveUntil('/HomeLogged', (route) => false);
        break;
      case 2:
        Navigator.of(context).pushNamedAndRemoveUntil('/HomeLogged', (route) => false, arguments: 2);
    }
  }

  _launchURL(Map<String, dynamic> data) async {
    if (await canLaunch(data["ext_link"]))
      await launch(data["ext_link"]);
  }
}
