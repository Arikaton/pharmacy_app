import 'package:flutter/material.dart';
import 'package:pharmacy_app/main.dart';
import 'package:pharmacy_app/news_widget.dart';
import 'package:pharmacy_app/pincode/pincode_widget.dart';
import 'package:pharmacy_app/profile_widget.dart';
import 'package:pharmacy_app/home_widget.dart';
import 'package:pharmacy_app/login_widget.dart';
import 'package:pharmacy_app/recipes/recipe_widget.dart';
import 'package:pharmacy_app/messages_widget.dart';
import 'package:pharmacy_app/relatives/relatives_add_new.dart';
import 'package:pharmacy_app/relatives/relatives_edit.dart';
import 'package:pharmacy_app/relatives/relatives_inside.dart';
import 'package:pharmacy_app/relatives/relatives_widget.dart';
import 'package:pharmacy_app/tablets/tablets_choose_recipe.dart';
import 'package:pharmacy_app/tablets/tablets_date_start.dart';
import 'package:pharmacy_app/tablets/tablets_inside.dart';
import 'package:pharmacy_app/tablets/tablets_statement.dart';
import 'package:pharmacy_app/warning_ESIA.dart';
import 'package:pharmacy_app/webview_widget.dart';
import '../recipes/buy_goods_widget.dart';
import '../recipes/choose_recipe_widget.dart';

class RouteGenerator{
  static Route<dynamic> generateRoute(RouteSettings settings){
    final args = settings.arguments;

    switch (settings.name){
      case '/':
        return MaterialPageRoute(builder: (_) => InitWidget());
      case '/LoginWidget':
        return MaterialPageRoute(builder: (_) => LoginWidget());
      case '/HomeLogged':
        return MaterialPageRoute(builder: (_) => HomeLogged(firstTab: args,));
      case '/News':
        return MaterialPageRoute(builder: (_) => NewsWidget(args));
      case '/Messages/Chat':
        return MaterialPageRoute(builder: (_) => MessagesWidget(messageId: args,));
      case '/RecipeWidget':
        return MaterialPageRoute(builder: (_) => RecipeWidget(recipeId: args,));
      case '/ChooseRecipe':
        return MaterialPageRoute(builder: (_) => ChooseRecipe(args));
      case '/BuyGoods':
        return MaterialPageRoute(builder: (_) => BuyGoods(args));
      case '/MyProfile':
        return MaterialPageRoute(builder: (_) => MyProfile(greetMessage: args,));
      case '/Messages':
        return MaterialPageRoute(builder: (_) => MessagesListWidget());
      case '/Messages/New':
        return MaterialPageRoute(builder: (_) => NewMessage());
      case '/EditProfile':
        return MaterialPageRoute(builder: (_) {
          return Scaffold(
            appBar: AppBar(title: Text('Мой профиль')),
            body: ProfileEdit(data: args),
          );
        });
      case 'LoginCheckNumber':
        return MaterialPageRoute(builder: (_) => LoginCheckNumberWidget());
      case '/Snils':
        return MaterialPageRoute(builder: (_) => SnilsCameraWidget());
      case "/Webview":
        return MaterialPageRoute(builder: (_) => WebViewWidget(url: args,));
//      case '/Tablets/NotRecipe':
//        return MaterialPageRoute(builder: (_) => TabletsNotRecipe());
      case 'Tablets_ChooseRecipe':
        return MaterialPageRoute(builder: (_) => TabletsChoseRecipe());
      case 'Tablets/DateStart':
        return MaterialPageRoute(builder: (_) => TabletsDate(data: args,));
      case '/Tablets/Statement':
        return MaterialPageRoute(builder: (_) => TabletsStatement(data: args));
      case '/Tablets/Inside':
        return MaterialPageRoute(builder: (_) => TabletsInside(data: args));
      case '/Relatives':
        return MaterialPageRoute(builder: (_) => RelativesWidget());
      case '/Relatives/New':
        return MaterialPageRoute(builder: (_) => RelativesAddNew(userID: args,));
      case '/Relatives/Confirm':
        return MaterialPageRoute(builder: (_) => RelativesConfirmToken(token: args));
      case '/Relatives/Edit':
        return MaterialPageRoute(builder: (_) => RelativesEdit(data: args,));
      case '/Relatives/Inside':
        return MaterialPageRoute(builder: (_) => RelativesInside(userId: args,));
      case '/PincodeAddNew':
        return MaterialPageRoute(builder: (_) => PincodeWidget());
      case '/ESIAWarning':
        return MaterialPageRoute(builder: (_) => ESIAWarning());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_){
      return Scaffold(
        appBar: AppBar(
          title: Text("Error"),
        ),
        body: Center(
          child: Text("ERROR"),
        ),
      );
    });
  }
}