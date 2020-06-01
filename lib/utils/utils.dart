import 'package:connectivity/connectivity.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils{
  static String createQuery(Map<String, String> query){
    String result = "";
    String check = "";
    for (var v in query.values){
      check += v;
    }
    if (check == "") return "";
    for (var s in query.keys){
      if (query[s] != "" && query[s] != null)
        result += "&$s=${query[s]}";
    }
    result = "?" + result.substring(1);
    return result;
  }

  static Future<bool> checkInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else
      return false;
  }

  static String convertDate(String date){
    if (date.length < 10) return "";
    return date[8] + date[9] + "." + date[5] + date[6] + "." +  date[0] + date[1] + date[2] + date[3] ;
  }

  static void launchUrl(String url) async {
    if (await canLaunch(url))
      await launch(url);
  }
}