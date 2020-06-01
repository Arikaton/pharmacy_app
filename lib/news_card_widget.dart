import 'package:flutter/material.dart';
import 'package:pharmacy_app/news_widget.dart';
import 'package:pharmacy_app/utils/server_wrapper.dart';
import 'package:pharmacy_app/utils/utils.dart';

class NewsCard extends StatelessWidget{
  final String newsID;
  final String titleText;
  final String bodyText;
  final String botSource;
  final String date;
  final String url;
  final bool read;
  final int pageType; //0 - login, 1 - typical, 2 - profile

  const NewsCard({Key key, this.titleText, this.bodyText, this.botSource, this.date, this.url, this.newsID, this.read, this.pageType = 1}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color.fromARGB(255, 195, 243, 208), Color.fromARGB(255, 73, 201, 224)]
            )
        ),
        height: 100.0,
        child: InkWell(
        onTap: () => _onTapCard(context),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: 300,
                  alignment: Alignment(-1.0, -1.0),
                  child: Text(
                    "Новость: $titleText",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    textAlign: TextAlign.start,
                    maxLines: 1,
                  ),
                  padding: EdgeInsets.fromLTRB(4, 4, 0, 0),
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: read ? Icon(
                    Icons.brightness_1,
                    color: Colors.red,
                    size: 10,
                  ) : SizedBox()
                )
              ],
            ),
            Expanded(
              child: Container(
                  child: Text(
                    bodyText,
                    maxLines: 2,
                    style: TextStyle(fontSize: 11),
                  ),
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.all(4)
              ),
            ),
            Container(
              padding: EdgeInsets.all(4),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      botSource,
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  Text(
                      Utils.convertDate(date.substring(0, 10)),
                      style: TextStyle(fontSize: 11)
                  )
                ],
              ),
            ),
          ],
        ),
        ),
    );
  }

  _onTapCard(BuildContext context){
    readNews(newsID);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => NewsWidget(newsID, pageType: pageType)));
  }

  void readNews(String newsID) async {
    await ServerNews.readNews(newsID);
  }
}