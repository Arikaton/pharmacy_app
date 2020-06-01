import 'package:flutter/material.dart';
import 'package:pharmacy_app/utils/server_wrapper.dart';
import 'package:progress_dialog/progress_dialog.dart';

class ChooseRecipe extends StatefulWidget{
  final List<String> recipeData;

  const ChooseRecipe(this.recipeData, {Key key,}) : super(key: key);

  _ChooseRecipeState createState() => _ChooseRecipeState();
}

class _ChooseRecipeState extends State<ChooseRecipe>{
  List<dynamic> data;
  List<Widget> goods = new List<Widget>();
  String city = "Неизвестно";
  ProgressDialog progressDialog;

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(context, type: ProgressDialogType.Normal);
    progressDialog.style(message: "Подождите...");
    return Scaffold(
      appBar: AppBar(title: Text("Рецепт " + widget.recipeData[1], style: TextStyle(fontSize: 16))),
      body: FutureBuilder(
        future: getGoodsData(context),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.done){
            return Container(
              color: Color.fromARGB(255, 228, 246, 243),
              padding: EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Ваш город: "),
                      Text(city, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20)),
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        height: 25,
                        child: FlatButton(
                          color: Colors.grey,
                          child: Text("Изменить"),
                          onPressed: () => changeTown(context),
                        ),
                      )
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text("Выберите препарат:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500), textAlign: TextAlign.left,),
                    ),
                  ),
                  Divider(),
                  Expanded(
                      child: ListView.builder(
                          itemCount: goods.length,
                          itemBuilder: (context, pos){
                            return goods[pos];
                          }
                      )
                  )
                ],
              ),
            );
          } else {
            return Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: CircularProgressIndicator(),
                  ),
                  Text("Подождите...")
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> getGoodsData(BuildContext context) async {
    goods.clear();
    //var geoInfo = await SharedPreferencesWrap.getCurrentCity();
    if (widget.recipeData.length == 2){
      data = await ServerRecipe.getGoodsList(widget.recipeData[0]) ?? List();
      city = data[0]["Town"].toString() ?? "Не выбран";
    } else {
      city = widget.recipeData[3];
      data = await ServerRecipe.getGoodsList(widget.recipeData[0], town: widget.recipeData[2]) ?? List();
    }
    if (data.length == 0){
      goods.add(Center(child: Text("В данном городе препарат не найден, измените город поиска."),));
    } else
      for (int i = 0; i < data.length; i++){
        goods.add(PharmacyCard(
          progressDialog: progressDialog,
            goodsID: data[i]["GoodsID"].toString(),
            title: data[i]["GoodsName"].toString(),
            description: data[i]['Description'].toString(),
            minPrice: data[i]['MinPrice'].toString(),
            maxPrice: data[i]['MaxPrice'].toString(),
            recipeID: widget.recipeData[0],
            onTap: () => Navigator.of(context).pushReplacementNamed('/BuyGoods', arguments: [widget.recipeData[0], widget.recipeData[1]])
        ));
      }
  }

  void changeTown(BuildContext context) async {
    var townsData = await ServerRecipe.getRecipeTowns();
    List<Widget> townButtons = List();
    for (int i = 0; i < townsData.length; i++){
      townButtons.add(
        FlatButton(
          onPressed: ()  {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed("/ChooseRecipe", arguments: [widget.recipeData[0], widget.recipeData[1], townsData[i]["ID"].toString(), townsData[i]["Town"].toString()]);
          },
          child: Text(townsData[i]["Town"].toString()),
        )
      );
    }
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("Выберите город"),
            children: townButtons
          );
        }
    );
  }
}

class PharmacyCard extends StatelessWidget{
  final recipeID;
  final goodsID;
  final minPrice;
  final maxPrice;
  final title;
  final description;
  final Function onTap;
  final ProgressDialog progressDialog;

  const PharmacyCard({Key key, this.minPrice, this.maxPrice, this.title, this.description, this.goodsID, this.recipeID, this.onTap, this.progressDialog}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        progressDialog.show();
        await ServerRecipe.handleGoods(recipeID, goodsID);
        progressDialog.hide();
        print("Tap card");
        onTap();
      },
      child: Card(
        elevation: 9,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: TextStyle(fontSize: 16),),
              Container(child: Text('Описание:'), margin: EdgeInsets.symmetric(vertical: 4),),
              Text(description),
              SizedBox(height: 6,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text("Минимальная цена:"),
                      Text(minPrice, style: TextStyle(fontSize: 26),)
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text('Максимальная цена:'),
                      Text(maxPrice, style: TextStyle(fontSize: 26))
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

}