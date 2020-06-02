import 'package:flutter/material.dart';
import 'package:pharmacy_app/utils/links.dart';
import 'package:pharmacy_app/utils/utils.dart';

class TabletsNotRecipe extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Создание курса приёма"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () => Utils.showHelpInfo(context, References.tabletsPage),
            )
          ],
      ),
      body: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(bottom: 120),
            child: Text(
              "Для создания курса необходимы\nвыписанные электронные рецепты.\n\nУ вас нет ни одного выписанного рецепта.",
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            alignment: Alignment.bottomCenter,
            child: SizedBox(
                width: double.infinity,
                child: FlatButton(
                  child: Text("Назад"),
                  color: Colors.blue,
                  onPressed: () => Navigator.of(context).pop(),
                )
            ),
          )
        ],
      ),
    );
  }
}