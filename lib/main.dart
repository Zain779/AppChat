import 'package:appchat/Screens/splash_screen.dart';
import 'package:appchat/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

late Size mq;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  _initilizeFirebase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AppChat',
        theme: ThemeData(
            appBarTheme: AppBarTheme(
                color: Colors.white,
                iconTheme: IconThemeData(color: Colors.black),
                centerTitle: true,
                titleTextStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 19,
                    fontWeight: FontWeight.normal))),
        home: SplashScreen());
  }
}

_initilizeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
