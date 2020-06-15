import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pharmacy_app/message_card_widget.dart';
import 'package:pharmacy_app/recipes/recipe_card_widget.dart';
import 'package:pharmacy_app/utils/local_storage_wrapper.dart';
import 'package:pharmacy_app/utils/shared_preferences_wrapper.dart';
import 'package:pharmacy_app/utils/utils.dart';
import '../news_card_widget.dart';

class ServerWrapper{
  //static String serverUrl = "https://es.svodnik.pro:55443/es_test/ru_RU/hs";
  static String serverUrl = "https://es.svodnik.pro:55443/es/ru_RU/hs/";

  static Future<void> refreshAccessToken() async {
    bool internet = await Utils.checkInternet();
    if (!internet) return;
    final deviceInfo = await SharedPreferencesWrap.getDeviceInfo();
    final tokens = await SharedPreferencesWrap.getTokens();
    String deviceID = deviceInfo['DeviceID'];
    String appID = deviceInfo['AppID'];
    String instanceID = deviceInfo['InstanceID'];
    String basic = deviceInfo['Authorization'];
    String refresh = tokens[0];

    Map<String, String> headers = {"DeviceID" : deviceID, 'AppID': appID, 'InstanceID': instanceID, "Authorization": basic};
    String url = "${ServerWrapper.serverUrl}/oauth/Token?RefreshToken=$refresh";
    Response response = await get(url, headers: headers);

    if (response.statusCode == 200){
      await SharedPreferencesWrap.setAccessToken(jsonDecode(response.body).toString());
      //print(jsonDecode(response.body).toString());
    } else {
      throw "Неизвестный токен. Требуется регистрация пользователя.";
    }

  }

}

class ServerRecipe{
  static Future<List<dynamic>> getRecipeTowns() async {
    var info = await SharedPreferencesWrap.getDeviceInfo();
    var url = "${ServerWrapper.serverUrl}/recipe/Towns";

    Response response = await get(url, headers: info);
    if (response.statusCode == 200){
      print(jsonDecode(response.body));
      return jsonDecode(response.body);
    } else {
      throw "Can't get recipe towns";
    }
  }

  static Future<Map<String, dynamic>> getRecipeBody(String recipeID) async {
    var deviceInfo = await SharedPreferencesWrap.getDeviceInfo();
    var url = "${ServerWrapper.serverUrl}/recipe/Recipe?RecipeID=$recipeID";
    Response response = await get(url, headers: deviceInfo);
    if (response.statusCode == 200){
      LocalStorageWrapper.setRecipeBody(recipeID, jsonDecode(response.body));
      return jsonDecode(response.body);
    } else {
      throw "Cant't get recipe body";
    }
  }

  static Future<void> readRecipe(String recipeID) async {
    var deviceInfo = await SharedPreferencesWrap.getDeviceInfo();

    var url = "${ServerWrapper.serverUrl}/recipe/Recipe?RecipeID=$recipeID";

    Response response = await patch(url, headers: deviceInfo);
    if (response.statusCode == 200){
      print("succesful read recipe");
    } else {
      throw "Cant't read recipe";
    }
  }

  static Future<void> deleteRecipe(String recipeID) async {
    var deviceInfo = await SharedPreferencesWrap.getDeviceInfo();

    var url = "${ServerWrapper.serverUrl}/recipe/Recipe?RecipeID=$recipeID";

    Response response = await delete(url, headers: deviceInfo);
    if (response.statusCode == 200){
      print("succesful delete recipe");
    } else {
      throw "Cant't delete recipe";
    }
  }

  static Future<List<dynamic>> getGoodsList(String recipeID, {String town = ""}) async {
    var deviceInfo = await SharedPreferencesWrap.getDeviceInfo();

    var url = "${ServerWrapper.serverUrl}/recipe/ChoiceGoods?RecipeID=$recipeID";
    if (town != ""){
      url += "&Town=$town";
    }

    Response response = await get(url, headers: deviceInfo);
    if (response.statusCode == 200){
      print(response.body);
      return jsonDecode(response.body);
    } else {
      print("Не могу молучить список товаров");
    }
  }

  static Future<void> handleGoods(String recipeID, String goodsID) async {
    var deviceInfo = await SharedPreferencesWrap.getDeviceInfo();

    var url = "${ServerWrapper.serverUrl}/recipe/ChoiceGoods?RecipeID=$recipeID&GoodsID=$goodsID";

    Response response = await put(url, headers: deviceInfo);
    if (response.statusCode == 200){
      print(response.body);
    } else {
      print(response.body);
    }
  }

  static Future<void> deleteGoods(String recipeId, String goodsId, String aptekaId) async {
    var info = await SharedPreferencesWrap.getDeviceInfo();

    var url = "${ServerWrapper.serverUrl}/recipe/WhereBuy?RecipeID=$recipeId";
    if (goodsId != "") url += "&Goods009ID=$goodsId";
    if (aptekaId != "") url += "&AptekaID=$aptekaId";

    Response response = await delete(url, headers: info);
    print("delete answer ${response.body}");
  }

  static Future<void> getFactoryList(String recipeID) async {
    var deviceInfo = await SharedPreferencesWrap.getDeviceInfo();

    var url = "${ServerWrapper.serverUrl}/recipe/ChoiceManufactured?RecipeID=$recipeID";

    Response response = await get(url, headers: deviceInfo);
    if (response.statusCode == 200){
      print(response.body);
    } else {
      print("Не могу молучить список изготовителей");
    }
  }

  static Future<void> handleFactoryInRecipe(String recipeID, String manufacturedID) async {
    var deviceInfo = await SharedPreferencesWrap.getDeviceInfo();

    var url = "${ServerWrapper.serverUrl}/recipe/ChoiceManufactured?RecipeID=$recipeID&ManufacturedID=$manufacturedID";

    Response response = await put(url, headers: deviceInfo);
    if (response.statusCode == 200){
      print(response.body);
    } else {
      print("Не могу молучить список товаров");
    }
  }

  static Future<List<dynamic>> getPharmacies(String recipeID) async {
    var deviceInfo = await SharedPreferencesWrap.getDeviceInfo();

    var url = "${ServerWrapper.serverUrl}/recipe/WhereBuy?RecipeID=$recipeID";

    Response response = await get(url, headers: deviceInfo);
    if (response.statusCode == 200){
      return jsonDecode(response.body);
    } else {
      print("Не могу молучить список аптек");
    }
  }

  static Future<void> handlePharmacies(String recipeID, String goodsID, double price, String aptekaID, String manufactured) async {
    var deviceInfo = await SharedPreferencesWrap.getDeviceInfo();

    var url = "${ServerWrapper.serverUrl}/recipe/WhereBuy?RecipeID=$recipeID";
    var body = List<dynamic>();
    body.add({"Goods009ID": goodsID, "Price": price, "AptekaID": aptekaID, "Manufactured009": manufactured});

    Response response = await put(url, headers: deviceInfo, body: jsonEncode(body));
    if (response.statusCode == 200){
      print("Товар успешно добавлен");
    } else {
      print("Не могу зафиксировать выбранную аптеку");
    }
  }

  static Future<List<Widget>> getRecipeCards() async {
    var deviceInfo = await SharedPreferencesWrap.getDeviceInfo();
    List<Widget> contentWidgets = new List<Widget>();

    String url = '${ServerWrapper.serverUrl}/recipe/MainPage';

    Response response = await get(url, headers: deviceInfo);

    if (response.statusCode == 200){
      List<dynamic> content = jsonDecode(response.body)['Records'];
      print(response.body);
      for (int i = 0; i < content.length; i++) {
        Map<String, dynamic> data = content[i]['Data'];
        if (content[i]["TypeData"] == "Recipe"){
          contentWidgets.add(RecipeCard(
            prioritet: data["Prioritet"] as int,
            purchased: data["Purchased"] as bool ?? false,
            recipeName: data["Number"].toString(),
            goods: data["Goods"],
            hospital: data["Hospital"],
            date: data['Date'].toString(),
            personName: data["PatientFIO"].toString(),
            id: content[i]["ID"].toString(),
            notRead: content[i]["NotRead"] as bool,
            onTap: (context) async {
              Map<String, dynamic> recipeData = {"HaveRecipe": true, "RecipeId": content[i]["ID"].toString()};
              print(recipeData);
              Navigator.of(context).pushNamed('Tablets/DateStart', arguments: recipeData);
            },
          ));
        }
      }
      return contentWidgets;
    } else {
      throw "Can't get recipe cards";
    }
  }
}

class ServerNews{
  static Future<List<dynamic>> getNewsCard({String page = "", String from = "", String onlyNew = "", String count = ""}) async {
    List<dynamic> content = List();

    var deviceInfo = await SharedPreferencesWrap.getDeviceInfo();
    var googleToken = await SharedPreferencesWrap.getGooglePush();

      if (deviceInfo["AccessToken"] == ""){
        deviceInfo.remove("AccessToken");
      }

      var geoInfo = await SharedPreferencesWrap.getCurrentCity();
      if (geoInfo != null){
        deviceInfo["GEO_Width"] = geoInfo[1];
        deviceInfo["GEO_Long"] = geoInfo[2];
      }

    String url = '${ServerWrapper.serverUrl}/recipe/MainPage' + Utils.createQuery({"Page": page, "Count": count, "From": from, "OnlyNew": onlyNew, "pushToken": googleToken});

    Response response = await get(url, headers: deviceInfo);

    if (response.statusCode == 200){
      content = jsonDecode(response.body)["Records"];
      if (page == "") LocalStorageWrapper.setNews(content);
      else LocalStorageWrapper.setProfileNews(content);
      return content;
    }
    else {
      print(response.body);
      throw "Can't get news from server";
    }
  }

  static Future<List<dynamic>> getPages() async {
    final deviceInfo = await SharedPreferencesWrap.getDeviceInfo();
    String url = '${ServerWrapper.serverUrl}/recipe/MainPage';

    Response response = await get(url, headers: deviceInfo);

    if (response.statusCode == 200){
      List<dynamic> pages = jsonDecode(response.body)["Pages"];
      LocalStorageWrapper.setPages(pages);
      return pages;
    } else {
      var pages = await LocalStorageWrapper.getNewsPages();
      return pages;
    }
  }

  static Future<Map<String, String>> getNewsBody(String newsID) async {
    var deviceInfo = await SharedPreferencesWrap.getDeviceInfo();

    var url = "${ServerWrapper.serverUrl}/recipe/News?NewsID=$newsID";

    Response response = await get(url, headers: deviceInfo);
    if (response.statusCode == 200){
      Map<String, dynamic> content = jsonDecode(response.body);
      Map<String, String> data = {"NotRead": content["NotRead"].toString(), "Header": content["Header"].toString(), "Body": content["Body"].toString(),
      "Source": content["Source"].toString(), "Date": content["Date"].toString(), "ext_link":content["ext_link"].toString()};
      return data;
    } else {
      throw "Cant't get news info";
    }
  }

  static Future<void> deleteNews(String newsID) async {
    var deviceInfo = await SharedPreferencesWrap.getDeviceInfo();

    var url = "${ServerWrapper.serverUrl}/recipe/News?NewsID=$newsID";

    Response response = await delete(url, headers: deviceInfo);
    if (response.statusCode == 200){
      print("succesful delete news");
    } else {
      throw "Cant't delete news";
    }
  }

  static Future<void> readNews(String newsID) async{
    var deviceInfo = await SharedPreferencesWrap.getDeviceInfo();

    String url = "${ServerWrapper.serverUrl}/recipe/News?NewsID=$newsID";

    Response response = await patch(url, headers: deviceInfo);
    if (response.statusCode == 200){
      print("News $newsID was read");
    } else {
      print(response.statusCode);
      throw "Error while patch read news";
    }
  }

}

class ServerLogin{
  static Future<Response> loginPhone(String phone) async {
    var deviceInfo = await SharedPreferencesWrap.getDeviceInfo();
    deviceInfo.remove("AccessToken");

    String url = '${ServerWrapper.serverUrl}/oauth/Phone/Login?Phone=8-$phone';

    Response response = await post(url, headers: deviceInfo);
    return response;
  }

  static Future<String> loginEsia() async {
    var info = await SharedPreferencesWrap.getDeviceInfo();
   // String url = "${ServerWrapper.serverUrl}/oauth/ESIA?url_to_redirect=https://xn--90arb8cyac.009.xn--p1ai/";
    String url = "${ServerWrapper.serverUrl}/oauth/ESIA?url_to_redirect=https://xn--90arb8cyac.009.xn--p1ai/gosuslugi/";

    Response response = await get(url, headers: info);
    //print('Респонсе боди');
    //print(response.body.toString());
    //print('Респонсе боди конец');

    if (response.statusCode == 200){
      return jsonDecode(response.body)['redirect_url'].toString();
    } else {
      return "";
    }
  }

  static Future<bool> postDataFromEsia(String code, String state, {String userID = ""}) async {
    var info = await SharedPreferencesWrap.getDeviceInfo();

    String url = "${ServerWrapper.serverUrl}/oauth/ESIA?code=$code&state=$state";
    if (userID != ""){
      url += "&UserID=$userID";
    }

    Response response = await post(url, headers: info);
    print('статус последнего этапа гос услуг');
    print(response.statusCode.toString());

    if (response.statusCode == 200){
      return true;
    } else {
      return false;
    }
  }
}

class ServerProfile{
  static Future<Map<String, dynamic>> getUserProfile({String userID = ""}) async {
    final deviceInfo = await SharedPreferencesWrap.getDeviceInfo();

    String url = '${ServerWrapper.serverUrl}/oauth/Profile';
    if (userID != ""){
      url += "?UserID=$userID";
    }

    Response response = await get(url, headers: deviceInfo);
    if (response.statusCode == 200){
      Map<String, dynamic> data = jsonDecode(response.body);
      await SharedPreferencesWrap.setUserID(data["UserID"].toString());
      return data;
    } else {
      throw "Error while get user info";
    }
  }

  static Future<void> changeUserData(Map<String, String> data, {String userId = ""}) async {
    var deviceInfo = await SharedPreferencesWrap.getDeviceInfo();
//    var userID = await SharedPreferencesWrap.getUserID();
//    if (userID == null){
//      return;
//    }

    String url = '${ServerWrapper.serverUrl}/oauth/Profile';
    if (userId != ""){
      url += "?UserID=$userId";
    }
    print(url);

    Response response = await patch(url, headers: deviceInfo, body: jsonEncode(data));
    print(jsonEncode(data));
    if (response.statusCode == 200){
      print("Data succesfuly changed");
    } else {
      print(response.body);
    }
  }

  static Future<void> addRelatives(String agree, {String body}) async {
    var deviceInfo = await SharedPreferencesWrap.getDeviceInfo();

    String url = '${ServerWrapper.serverUrl}/oauth/Profile';

    Response response = await put(url, headers: deviceInfo, body: body);
    if (response.statusCode == 200){
      print(response.body);
    } else {
      throw "Error while change user data";
    }
  }

  static Future<void> uploadSnils(String imagePath) async {
    var userID = await SharedPreferencesWrap.getUserID();
    if (userID == null) return;
    if (imagePath == null) return;
    String base64Image = base64Encode(File(imagePath).readAsBytesSync());
    String url = "${ServerWrapper.serverUrl}/oauth/SNILS?UserID=$userID";
    var info = await SharedPreferencesWrap.getDeviceInfo();

    Response response = await put(url, headers: info, body: base64Image);
    if (response.statusCode == 200){
      print("Успешная загрузка снилса на сервер");
    } else {
      print(response.body);
    }
  }

  static Future<void> logout() async {
    var info = await SharedPreferencesWrap.getDeviceInfo();
    var url = "${ServerWrapper.serverUrl}/oauth/Phone/Logout";

    Response response = await post(url, headers: info);
    if (response.statusCode == 200){
      print("Successful logout");
    } else {
      print("Error while post logout");
    }
  }
}

class ServerMessages{
  static Future<List<dynamic>> getMessageList() async {
    final deviceInfo = await SharedPreferencesWrap.getDeviceInfo();
    String url = "${ServerWrapper.serverUrl}/recipe/MessageList";

    Response response = await get(url, headers: deviceInfo);
    if (response.statusCode == 200){
      LocalStorageWrapper.setMessages(jsonDecode(response.body)["Records"]);
      return (jsonDecode(response.body)["Records"]);
    } else {
      throw "Error while getting message List";
    }
  }

  static Future<Map<String, dynamic>> getMessage(String messageID) async {
    final deviceInfo = await SharedPreferencesWrap.getDeviceInfo();
    String url = "${ServerWrapper.serverUrl}/recipe/Message?MessageID=$messageID";

    Response response = await get(url, headers: deviceInfo);
    if (response.statusCode == 200){
      readMessage(messageID);
      return (jsonDecode(response.body));
    } else {
      throw "Error while getting message List";
    }

  }

  static Future<void> sendMessage(Map<String, String> messageData) async {
    final deviceInfo = await SharedPreferencesWrap.getDeviceInfo();
    String url = "${ServerWrapper.serverUrl}/recipe/Message";

    Response response = await post(url, headers: deviceInfo, body: jsonEncode(messageData));
    if (response.statusCode == 200){
      print("Successful send message");
    } else {
      print(response.body);
    }
  }

  static Future<List<dynamic>> getMessageHeader() async {
    final deviceInfo = await SharedPreferencesWrap.getDeviceInfo();
    String url = "${ServerWrapper.serverUrl}/recipe/MessageHeaders";

    Response response = await get(url, headers: deviceInfo);
    if (response.statusCode == 200){
      print(response.body);
      return (jsonDecode(response.body));
    } else {
      throw "Error while getting message headers";
    }
  }

  static Future readMessage(String messageID) async {
    final deviceInfo = await SharedPreferencesWrap.getDeviceInfo();
    String url = "${ServerWrapper.serverUrl}/recipe/Message?MessageID=$messageID";

    Response response = await patch(url, headers: deviceInfo);

    if (response.statusCode == 200){
      print("Successful read message");
    } else {
      print("Message read: ${response.body}");
    }
  }
}

class ServerTablets{
  static Future<void> putTablets(Map<String, dynamic> kurs) async {
    final deviceInfo = await SharedPreferencesWrap.getDeviceInfo();
    String url = "${ServerWrapper.serverUrl}/recipe/tabl";

    Response response = await put(url, headers: deviceInfo, body: jsonEncode(kurs));
    if (response.statusCode == 200){
      print("Successful uploaded kurs");
    } else {
      print(response.body);
    }
  }

  static Future<Map<String, dynamic>> getTablets() async {
    final deviceInfo = await SharedPreferencesWrap.getDeviceInfo();
    String url = "${ServerWrapper.serverUrl}/recipe/tabl";

    Response response = await get(url, headers: deviceInfo);
    if (response.statusCode == 200){
      return jsonDecode(response.body);
    } else {
      print(response.body);
    }
  }
}

class ServerRelatives{
  static Future<Map<String, dynamic>> getRelatives({String userId=""}) async {
    final deviceInfo = await SharedPreferencesWrap.getDeviceInfo();
    String url = "${ServerWrapper.serverUrl}/oauth/Profile";
    if (userId != ""){
      url += "?UserID=$userId";
    }

    Response response = await get(url, headers: deviceInfo);
    if (response.statusCode == 200){
      return jsonDecode(response.body);
    } else {
      print(response.body);
    }
  }

  static Future<String> addRelative(bool agree, Map<String, dynamic> data) async {
    final deviceInfo = await SharedPreferencesWrap.getDeviceInfo();
    String url = "${ServerWrapper.serverUrl}/oauth/Profile?Agree=$agree";

    Response response = await put(url, headers: deviceInfo, body: jsonEncode(data));
    if (response.statusCode == 200){
      print(response.body);
      return jsonDecode(response.body);
    } else {
      print(response.body);
      return "";
    }
  }

  static Future<bool> confirmMessage(String token, String code) async {
    final deviceInfo = await SharedPreferencesWrap.getDeviceInfo();
    deviceInfo.remove("AccessToken");
    String url = "${ServerWrapper.serverUrl}/oauth/Phone/Login?ConfirmationCode=$code&ConfirmationToken=$token";

    Response response = await put(url, headers: deviceInfo);
    if (response.statusCode == 200){
      return true;
    } else {
      print(response.body);
      return false;
    }
  }
}