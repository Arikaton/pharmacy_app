import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pharmacy_app/utils/server_wrapper.dart';
import 'package:pharmacy_app/utils/utils.dart';

class RecipeCard extends StatelessWidget{
  final String id;
  final String recipeName;
  final String goods;
  final String hospital;
  final String personName;
  final String date;
  final int prioritet;
  final bool purchased;
  final bool notRead;
  final Function onTap;

  const RecipeCard({Key key, this.recipeName, this.personName, this.date, this.id, this.goods, this.hospital, this.notRead, this.onTap, this.prioritet, this.purchased = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(fontSize: 10, color: Colors.black);
    return GestureDetector(
      onTap: () => onTap(context),
      child: Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.lightBlue[50],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey),
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 152, 236, 255),
                  Color.fromARGB(255, 25, 155, 242)
                ]
            )
        ),
        height: 110,
        child: Row(
          children: <Widget>[
            Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.all(3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Рецепт: $recipeName",
                        style: TextStyle(fontWeight: FontWeight.bold),),
                      prioritet == 0 ? SizedBox() : Text("Срочность: " + (prioritet == 1 ? "Срочно" : prioritet  == 2 ? "Немедленно" : "")),
                      Text("Препарат: $goods"),
                      Text("Источник: $hospital",
                        style: TextStyle(fontSize: 10, color: Colors.black45),)
                    ],
                  ),
                )
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(5),
                      alignment: Alignment.topRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          /*ColoredIcon(
                             icon: Icons.shopping_cart,
                             color: Colors.black,
                             activeColor: Colors.red[800],
                           ),*/
                          notRead ? Icon(
                            Icons.brightness_1,
                            color: Colors.red,
                            size: 10,
                          ) : SizedBox()
                        ],
                      ),
                    ),
                  ),
                  purchased ? Container(
                    margin: EdgeInsets.only(bottom: 5, right: 3),
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text("Рецепт выкуплен", textAlign: TextAlign.center),
                  ) : SizedBox(),
                  Container(
                    padding: EdgeInsets.only(right: 4, bottom: 2),
                    child: Column(
                      children: <Widget>[
                        Align(alignment: Alignment.centerRight,
                            child: Text("Пациент", style: TextStyle(
                                fontSize: 10, color: Colors.black45))),
                        Align(alignment: Alignment.centerRight,
                            child: Text(
                              personName, style: textStyle, textAlign: TextAlign
                                .right,)),
                        Align(alignment: Alignment.centerRight,
                            child: Text('Дата: ${Utils.convertDate(
                                date.substring(0, 10))}', style: TextStyle(
                                fontSize: 10, color: Colors.black45)))
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

}