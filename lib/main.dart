import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pharmacy_app/home_widget.dart';
import 'package:pharmacy_app/login_widget.dart';
import 'package:pharmacy_app/pincode/pincode_widget.dart';
import 'package:pharmacy_app/recipes/recipe_widget.dart';
import 'package:pharmacy_app/tablets/tablets_inside.dart';
import 'package:pharmacy_app/utils/route_generator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pharmacy_app/utils/shared_preferences_wrapper.dart';
import 'package:rxdart/subjects.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject = BehaviorSubject<String>();

final BehaviorSubject<Map<String, dynamic>> onResumeStream = BehaviorSubject<Map<String, dynamic>>();

final BehaviorSubject<Map<String, dynamic>> onMessageStream = BehaviorSubject<Map<String, dynamic>>();


NotificationAppLaunchDetails notificationAppLaunchDetails;

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  notificationAppLaunchDetails =
  await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  var initializationSettingsAndroid = AndroidInitializationSettings('icon');
  // Note: permissions aren't requested here just to demonstrate that can be done later using the `requestPermissions()` method
  // of the `IOSFlutterLocalNotificationsPlugin` class
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {
        didReceiveLocalNotificationSubject.add(ReceivedNotification(
            id: id, title: title, body: body, payload: payload));
      });

  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
    alert: true,
    badge: true,
    sound: true,
  );
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
        if (payload != null) {
          debugPrint('notification payload: ' + payload);
        }
        selectNotificationSubject.add(payload);
      });

  runApp(MyMaterialApp());
}
final navigatorGlobalKey = GlobalKey<NavigatorState>();
class MyMaterialApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorGlobalKey,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', 'US'), // English
          const Locale('ru'), // Rus
        ],
        title: "mainPage",
        theme: ThemeData.light(),
        onGenerateRoute: RouteGenerator.generateRoute,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        //home: InitWidget()
    );
  }
}

class InitWidget extends StatefulWidget{
  InitWidgetState createState() => InitWidgetState();
}

class InitWidgetState extends State<InitWidget>{
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final MethodChannel platform =
  MethodChannel('crossingthestreams.io/resourceResolver');
  bool logged;

  @override
  void initState() {
    print("------------init widget--------------");
    super.initState();
    _configureFirebase();
    _init();
  }

  Future _init() async {
    await SharedPreferencesWrap.firstOpen();
    String pinCode = await SharedPreferencesWrap.getPincode();
    bool logged = await SharedPreferencesWrap.getLoginInfo();
    if (logged){
      if (pinCode == null)
        Navigator.of(context).pushNamedAndRemoveUntil('/HomeLogged', (route) => false);
      else {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => PinCodeLogin(rightCode: pinCode)), (route) => false);
      }
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil('/LoginWidget', (route) => false);
    }
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      String payload = receivedNotification.payload;
      Map<String, dynamic> data = jsonDecode(payload);
      data["TabletId"] = data["KursID"].toString() + DateTime.now().month.toString() + DateTime.now().day.toString() + data["Time"];
      await Future.delayed(Duration(milliseconds: 500));
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TabletsInside(data: data,)),
      );
    });
  }

  void _configureFirebase(){
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        onMessageStream.add(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        onResumeStream.add(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume");
        onResumeStream.add(message);
      },
    );
    _firebaseMessaging.getToken().then((token) async {SharedPreferencesWrap.setGooglePush(token); print(token);});
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen();
  }

  @override
  void dispose() {
    selectNotificationSubject.close();
    super.dispose();
  }

}



