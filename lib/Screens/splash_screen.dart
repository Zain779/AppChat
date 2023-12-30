import 'dart:developer';

import 'package:appchat/Resources/color.dart';
import 'package:appchat/Screens/Auth/login.dart';
import 'package:appchat/Screens/home_screen.dart';
import 'package:appchat/api/api.dart';
import 'package:appchat/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 1500), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: AppColors.whiteColor,
        statusBarColor: AppColors.whiteColor,
      ));
      if (APIs.auth.currentUser != null) {
        log('User: ${APIs.auth.currentUser}');
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Welcome to AppChat'),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
              top: mq.height * .15,
              right: mq.width * .15,
              width: mq.width * .7,
              duration: Duration(seconds: 1),
              child: Image.asset('assets/smartphone.png')),
          Positioned(
            bottom: mq.height * .15,
            left: mq.width * .05,
            width: mq.width * .9,
            height: mq.height * .06,
            child: Center(
                child: Text(
              'AppChat',
              style: TextStyle(color: AppColors.primaryTextTextColor),
            )),
          )
        ],
      ),
    );
  }
}
