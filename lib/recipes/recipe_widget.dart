import 'package:flutter/material.dart';
import 'package:pharmacy_app/utils/links.dart';
import 'package:pharmacy_app/utils/local_storage_wrapper.dart';
import 'package:pharmacy_app/utils/server_wrapper.dart';
import 'package:pharmacy_app/utils/utils.dart';
import 'package:qr_flutter/qr_flutter.dart';

class RecipeWidget extends StatefulWidget{
  final recipeId;

  const RecipeWidget({Key key, this.recipeId}) : super(key: key);

  RecipeWidgetState createState() => RecipeWidgetState();
}

class RecipeWidgetState extends State<RecipeWidget>{
  static const TextStyle infoStyle = TextStyle(fontWeight: FontWeight.bold);
  Map<String, dynamic> data;
  List<Widget> recipeWidgets;

  List<Widget> goodWidgets = new List<Widget>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pushNamedAndRemoveUntil("/HomeLogged", (Route<dynamic> route) => false);
        return Future(() => false);
      },
      child: Scaffold(
        appBar: AppBar(
            title: Text("Рецепт " + widget.recipeId[1], style: TextStyle(fontSize: 16),),
            leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil("/HomeLogged", (Route<dynamic> route) => false)),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.info_outline),
                onPressed: () => Utils.showHelpInfo(context, References.recipePage),
              )
            ],
          /*actions: <Widget>[Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(Icons.share, color: Colors.black87),
            )],*/
        ),
        body: FutureBuilder(
          future: getRecipeData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done){
              print(data["Prioritet"]);
              if (data.length == 0)
                return Center(child: Text("Проблемы с интернет соединением, повторите запрос позже."));
              return Container(
                color: Color.fromARGB(255, 228, 246, 243),
                padding: EdgeInsets.all(5),
                child: ListView(
                  children: <Widget>[
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text("Пациент:"),
                          Text(data['Patient'].toString())
                        ],
                      ),
                      alignment: Alignment.topRight,
                    ),
                    SizedBox(
                      height: 300,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(data["Purchased"] ? "Рецепт выкуплен" : "Рецепт не выкуплен"),
                          data["Prioritet"] as int == 0 ? SizedBox() : Text("Срочность: " + (data["Prioritet"] as int == 1 ? "Срочно" : "Немедленно"), style: TextStyle(color: Colors.red),),
                          Text('Лечебное учреждение:'),
                          Text(data['Hospital'].toString(), style: infoStyle,),
                          Text('Ваш врач:'),
                          Text(data['Doctor'].toString(), style: infoStyle,),
                          //Text('Наименование МНН:'),
                          //Text(data['Goods']["MNN"].toString(), style: infoStyle,),
                          Text("Препарат:"),
                          Text(data['Goods']["Purpose"].toString(), style: infoStyle,),
                          Row(
                            children: <Widget>[
                              Text('Количество стандартов: '),
                              Text(data['Goods']["Count_standarts"].toString(), style: infoStyle,),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text('Дозировка: '),
                              Text(data['Goods']["Dose"].toString(), style: infoStyle,),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text('Форма выпуска: '),
                              Text(data['Goods']["Form_release"], style: infoStyle,),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text('Количество дней приёма препарата: '),
                              Text(data['Goods']["Count_days_use_drug"].toString(), style: infoStyle,),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text('Количество приёма в день: '),
                              Text(data['Goods']["Count_per_day"].toString(), style: infoStyle,),
                            ],
                          ),
                          Text('Описание приёма препарата врачем:'),
                          Text(data['Goods']["DescriptionFromDoctor"].toString(), style: infoStyle),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: FlatButton(
                        child: Text('Найти препарат выгодно'),
                        onPressed: () async {
                          Navigator.of(context).pushNamed("/ChooseRecipe", arguments: widget.recipeId);
                        },
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: FlatButton(
                        color: Colors.blue,
                        child: Text("Создать курс приёма"),
                        onPressed: () => Navigator.of(context).pushNamed('Tablets/DateStart', arguments: {"HaveRecipe": true, "RecipeId": data["RecipeID"]}),
                      ),
                    ),
                    Divider(color: Colors.black,),
                    goodWidgets.length > 0 ? Container(
                      height: 400,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: goodWidgets.length,
                        itemBuilder: (context, index){
                          return goodWidgets[index];
                        },
                      ),
                    ) :
                    Center(
                      child: Column(
                        children: <Widget>[
                          Text('Покажите этот QR код в аптеке при покупке по рецепту', textAlign: TextAlign.center,),
                          QrImage(
                            data: data["QRCode"].toString(),
                            version: QrVersions.auto,
                            size: 200.0,
                            backgroundColor: Colors.white,
                          )
                        ],
                      )
                    ),
                  ],
                ),
              );
            }
            else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        )
      ),
    );
  }

  void buildGoods(dynamic goodsData) {
    goodWidgets.clear();
    for (int i = 0; i < goodsData.length; i++){
      goodWidgets.add(MedicamentCardRecipe(
        recipeId: widget.recipeId[0],
        goodsID: goodsData[i]["Goods009ID"].toString(),
        name: goodsData[i]["Goods009Name"].toString(),
        pharmName: goodsData[i]["Apteka"]["Name"].toString(),
        town: goodsData[i]["Apteka"]["Town"].toString(),
        street: goodsData[i]["Apteka"]["Address"].toString(),
        phone: goodsData[i]["Apteka"]["Phone"].toString(),
        time: goodsData[i]["Apteka"]["Schedule"].toString(),
        price: goodsData[i]["Price"].toString(),
        manufactured: goodsData[i]["Manufactured009"],
        aptekaID: goodsData[i]["Apteka"]["ID"].toString(),
        cashback: "10",
        qrCode: goodsData[i]["QRCode"].toString(),
        onClose: () async {
          await ServerRecipe.deleteGoods(widget.recipeId[0], goodsData[i]["Goods009ID"].toString(), goodsData[i]["Apteka"]["ID"].toString());
          setState(() {});
        }
      ));
    }
  }

  Future<void> getRecipeData() async {
    bool internet = await Utils.checkInternet();
    print(widget.recipeId[0]);
    if (internet)
      data = await ServerRecipe.getRecipeBody(widget.recipeId[0]);
    else
      data = await LocalStorageWrapper.getRecipeBody(widget.recipeId[0]) ?? Map();

    if (data.length != 0)
      buildGoods(data["Goods"]["UserSelection"]["WhereBuy"]);
  }

  static void LogPrint(Object object) async {
    int defaultPrintLength = 1020;
    if (object == null || object
        .toString()
        .length <= defaultPrintLength) {
      print(object);
    } else {
      String log = object.toString();
      int start = 0;
      int endIndex = defaultPrintLength;
      int logLength = log.length;
      int tmpLogLength = log.length;
      while (endIndex < logLength) {
        print(log.substring(start, endIndex));
        endIndex += defaultPrintLength;
        start += defaultPrintLength;
        tmpLogLength -= defaultPrintLength;
      }
      if (tmpLogLength > 0) {
        print(log.substring(start, logLength));
      }
    }
  }

}

class MedicamentCardRecipe extends StatefulWidget{
  final Function onClose;
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
  final String qrCode;

  const MedicamentCardRecipe({Key key, this.name, this.pharmName, this.town, this.street, this.phone, this.time, this.price,
    this.cashback, this.goodsID, this.recipeId, this.aptekaID, this.onClose, this.qrCode, this.manufactured}) : super(key: key);

  _MedicamentCardRecipeState createState() => _MedicamentCardRecipeState();
}

class _MedicamentCardRecipeState extends State<MedicamentCardRecipe>{
  bool handled = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(5),
        width: 330,
        height: 460,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 190,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(child: Text(widget.name, style: TextStyle(fontSize: 16), maxLines: 2), width: 230,),
                      widget.manufactured != "" ?
                      SizedBox(
                        width: 220,
                          child: Text(
                              "Производитель: " + widget.manufactured,
                              maxLines: 2,
                          )
                      ) : SizedBox(),
                      SizedBox(child: Text(widget.pharmName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2,), width: 230,),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 5, 0),
                            child: Text("${widget.price} ₽", style: TextStyle(fontSize: 16),textAlign: TextAlign.center,),
                          ),
                          //Text('Кэшбэк до ${widget.cashback} ₽', style: TextStyle(fontSize: 10),),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: _showAlertDialog,
                      )
                    ],
                  )
                ]
              ),
            ),
            QrImage(
              data: widget.qrCode,
              size: 190,
              backgroundColor: Colors.white,
            )
          ],
        ),
      ),
    );
  }

  _showAlertDialog(){
    final dialog = AlertDialog(
      content: Text("Вы действительно хотите удалить препарат?"),
      actions: <Widget>[
        FlatButton(
          child: Text("Нет"),
          onPressed: () => Navigator.pop(context),
        ),
        FlatButton(
          child: Text("Да"),
          onPressed: () async {
            Navigator.pop(context);
            widget.onClose();
          },
        )
      ],
    );
    showDialog(context: context, child: dialog);
  }

  void handlePharmacy() async {
    await ServerRecipe.handlePharmacies(widget.recipeId, widget.goodsID, double.parse(widget.price), widget.aptekaID, widget.manufactured);
    handled = !handled;
    setState(() {});
  }
}

