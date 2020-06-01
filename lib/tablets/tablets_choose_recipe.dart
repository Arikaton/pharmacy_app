import 'package:flutter/material.dart';
import 'package:pharmacy_app/recipes/recipe_card_widget.dart';
import 'package:pharmacy_app/utils/links.dart';
import 'package:pharmacy_app/utils/server_wrapper.dart';
import 'package:pharmacy_app/utils/utils.dart';

class TabletsChoseRecipe extends StatefulWidget{
  TabletsChooseRecipeState createState() => TabletsChooseRecipeState();
}

class TabletsChooseRecipeState extends State<TabletsChoseRecipe>{
  var formKey = GlobalKey<FormState>();
  String inputRecipe = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Шаг 1: Выбор рецепта"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () => Utils.launchUrl(References.tabletsPage),
          )
        ],
      ),
      body: FutureBuilder(
        future: ServerRecipe.getRecipeCards(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.done){
            List<Widget> recipeCards = snapshot.data ?? List();
            if (recipeCards.length == 0) recipeCards.add(SizedBox());
            return Container(
              margin: EdgeInsets.all(5),
              child: Column(
                children: <Widget>[
                  Padding(child: Text("Для создания курса приёма введите название лекарства"), padding: EdgeInsets.only(bottom: 10)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: formKey,
                      child: TextFormField(
                        initialValue: inputRecipe,
                        onChanged: (value) => inputRecipe = value,
                        validator: (value) {
                          if (value.isEmpty){return 'Введите название рецепта';}
                          else {
                            return null;
                          }
                        },
                        onSaved: (value) => inputRecipe = value,
                        decoration: InputDecoration(
                            border: OutlineInputBorder()
                        ),
                      ),
                    ),
                  ),
                  DividerWithTextInMiddle(
                    color: Colors.black,
                    text: "или введите свой препарат",
                    padding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  Expanded(
                    child: ListView(
                      children: recipeCards.length > 0 ? recipeCards : Text("У вас нет выписанных рецептов"),
                    ),
                  ),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          child: FlatButton(
                            child: Text("Далее"),
                            color: Colors.blue,
                            onPressed: pressNext,
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          child: FlatButton(
                            child: Text("Назад"),
                            color: Colors.blue,
                            onPressed: () => Navigator.of(context).pop(),
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

  void pressNext(){
    if (formKey.currentState.validate()){
      formKey.currentState.save();
      Navigator.of(context).pushNamed('Tablets/DateStart', arguments: {"HaveRecipe": false, "RecipeName": inputRecipe[0].toUpperCase() + inputRecipe.substring(1, inputRecipe.length)});
    }
  }

}

class DividerWithTextInMiddle extends StatelessWidget{
  final EdgeInsetsGeometry padding;
  final String text;
  final Color color;

  const DividerWithTextInMiddle({Key key, this.text, this.color, this.padding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
          children: <Widget>[
            Expanded(
                child: Divider(color: color,)
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(text),
            ),
            Expanded(
                child: Divider(color: color,)
            ),
          ]
      ),
    );
  }

}