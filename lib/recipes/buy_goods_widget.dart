import 'package:flutter/material.dart';
import 'package:pharmacy_app/utils/server_wrapper.dart';

class MedicamentCard extends StatefulWidget{
  final Function onPressed;
  final recipeId;
  final goodsID;
  final name;
  final pharmName;
  final town;
  final street;
  final phone;
  final time;
  final price;
  final cashback;
  final aptekaID;
  final manufactured;
  final bool selected;

  const MedicamentCard({Key key, this.name, this.pharmName, this.town, this.street, this.phone, this.time, this.price,
    this.cashback, this.goodsID, this.recipeId, this.aptekaID, this.onPressed, this.selected, this.manufactured}) : super(key: key);

  _MedicamentCardState createState() => _MedicamentCardState();
}

class _MedicamentCardState extends State<MedicamentCard>{

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(5),
        width: 330,
        height: 210,
        child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.name, style: TextStyle(fontSize: 16), maxLines: 2,),
                    widget.manufactured != "" ? Text("Производитель: " + widget.manufactured) : SizedBox(),
                    Text(widget.pharmName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2,),
                    Row(
                      children: <Widget>[
                        Icon(Icons.location_city),
                        Text(widget.town)
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Icon(Icons.location_on),
                        Text(widget.street)
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Icon(Icons.phone),
                        Text(widget.phone)
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Icon(Icons.access_time),
                        Text(widget.time)
                      ],
                    )
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.star, color: widget.selected ? Colors.green : Colors.black),
                      Text("${widget.price} ₽")
                    ],
                  ),
                  //Text('Кэшбэк до ${widget.cashback} ₽', style: TextStyle(fontSize: 10),),
                  Expanded(
                    child: Container(
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 2),
                    child: FlatButton(
                      color: !widget.selected ? Colors.lightGreenAccent : Colors.red[800],
                      onPressed: () async {
                        if (!widget.selected){
                          await ServerRecipe.handlePharmacies(widget.recipeId, widget.goodsID, double.parse(widget.price), widget.aptekaID, widget.manufactured);
                        } else {
                          await ServerRecipe.deleteGoods(widget.recipeId, widget.goodsID, widget.aptekaID);
                        }
                        widget.onPressed();
                      },
                      child: !widget.selected ? Text('Запомнить') :
                      Text("Отменить"),
                    ),
                  )
                ],
              )
            ]
        ),
      ),
    );
  }

}

class BuyGoods extends StatefulWidget{
  final recipeData;

  const BuyGoods(this.recipeData, {Key key}) : super(key: key);

  _BuyGoodsState createState() => _BuyGoodsState();
}

class _BuyGoodsState extends State<BuyGoods>{
  List<Widget> widgets = List<Widget>();
  String city;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Рецепт " + widget.recipeData[1], style: TextStyle(fontSize: 16)),
      ),
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done){
            return Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Выбор аптеки", style: TextStyle(fontSize: 18), textAlign: TextAlign.center,),
                  ),
                  Divider(),
                  Expanded(
                    child: ListView(
                      children: widgets,
                    ),
                  ),
                  Container(
                    height: 60,
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: 5),
                            child: FlatButton(
                              color: Colors.lightBlueAccent,
                              child: Text("Удалить всё"),
                              onPressed: () async {
                                await ServerRecipe.deleteGoods(widget.recipeData[0], "", "");
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 5),
                            child: FlatButton(
                                color: Colors.lightBlueAccent,
                                child: Text("Закончить выбор", style: TextStyle(fontSize: 16),),
                                onPressed: () => Navigator.of(context).pop()
                            ),
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
        },
      ),
    );
  }

  Future<void> getData() async {
    widgets.clear();
    var data = await ServerRecipe.getPharmacies(widget.recipeData[0]);
    print(data);
    for (int i = 0; i < data.length; i++){
      widgets.add(MedicamentCard(
        manufactured: data[i]["Manufactured009"].toString(),
        recipeId: widget.recipeData[0],
        goodsID: data[i]["Goods009ID"].toString(),
        name: data[i]["Goods009Name"].toString(),
        pharmName: data[i]["Apteka"]["Name"].toString(),
        town: data[i]["Apteka"]["Town"].toString(),
        street: data[i]["Apteka"]["Address"].toString(),
        phone: data[i]["Apteka"]["Phone"].toString(),
        time: data[i]["Apteka"]["Schedule"].toString(),
        price: data[i]["Price"].toString(),
        aptekaID: data[i]["Apteka"]["ID"],
        cashback: "10",
        selected: data[i]["Selected"] as bool,
        onPressed: () { setState(() {}); },
      ));
    }
  }

}