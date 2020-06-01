import 'package:localstorage/localstorage.dart';

class LocalStorageWrapper{
  static LocalStorage newsLocalStorage = LocalStorage("news");
  static LocalStorage messagesLocalStorage = LocalStorage("messages");
  static LocalStorage recipeLocalStorage = LocalStorage("recipe");

  static Future<List<dynamic>> getNews() async {
    await newsLocalStorage.ready;
    return newsLocalStorage.getItem("news");
  }

  static Future setNews(List<dynamic> data) async {
    await newsLocalStorage.ready;
    newsLocalStorage.setItem("news", data);
  }

  static Future setProfileNews(List<dynamic> data) async {
    await newsLocalStorage.ready;
    newsLocalStorage.setItem("news_p", data);
  }

  static Future<List<dynamic>> getProfileNews() async {
    await newsLocalStorage.ready;
    return newsLocalStorage.getItem("news_p");
  }

  static Future<List<dynamic>> getNewsPages() async {
    await newsLocalStorage.ready;
    return newsLocalStorage.getItem("pages");
  }

  static Future setPages(List<dynamic> data) async {
    await newsLocalStorage.ready;
    newsLocalStorage.setItem("pages", data);
  }

  static Future setMessages(List<dynamic> data) async {
    await messagesLocalStorage.ready;
    messagesLocalStorage.setItem("messages_list", data);
  }

  static Future<List<dynamic>> getMessages() async {
    await messagesLocalStorage.ready;
    return messagesLocalStorage.getItem("messages_list");
  }

  static Future setRecipeBody(recipeID, Map<String, dynamic> data) async {
    await recipeLocalStorage.ready;
    recipeLocalStorage.setItem(recipeID, data);
  }

  static Future<Map<String, dynamic>> getRecipeBody(String recipeID) async {
    await recipeLocalStorage.ready;
    return recipeLocalStorage.getItem(recipeID);
  }
}