


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_core/firebase_core.dart';
import 'Screens/HomeScreen.dart';
import 'Screens/LoginScreen.dart';
import 'Screens/OTPScreen.dart';
import 'Screens/edit_profile_screen.dart';
import 'screens/SplashScreen.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  await Firebase.initializeApp(
    options:  const FirebaseOptions(
      apiKey: "AIzaSyAvwMNOnyvvi1J8OwW3fDefkTyoAogSb7k",
      appId:  "1:623097487556:android:8e3bb421d6c697e191a991",
      messagingSenderId: "623097487556",
      projectId: "alldine-bcd03",
      storageBucket: "alldine-bcd03.appspot.com",
    ),
  );


  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProfileProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final firebaseauth=FirebaseAuth.instance;
  var user='';
  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,
      home:
      //SplashScreen(),
       //HomeScreen(),
     firebaseauth.currentUser==null ? SplashScreen(): const HomeScreen(),
    //  MobileLogin(),
      routes: {
        '/login': (context) => const MobileLogin(),
        '/otp': (context) =>  OtpLogin(verificationId: '',),
      },
    );
  }
}
