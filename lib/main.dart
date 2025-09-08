import 'package:ecollect/loginPage.dart';
import 'package:ecollect/navContainer.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ecollect/pages/homePage.dart';
import 'package:ecollect/navContainer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: Intro());
  }
}

class Intro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f5f7),
      body: Center(
        child: Lottie.asset(
          'assets/introFinal.json',
          repeat: false,
          onLoaded: (composition) {
            Future.delayed(composition.duration, () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      LoginPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        const begin = Offset(
                          0.0,
                          1.0,
                        ); //PARA MAGSIMULA SA BABA TRANSITION
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;

                        var tween = Tween(
                          begin: begin,
                          end: end,
                        ).chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);

                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                  transitionDuration: Duration(milliseconds: 350),
                ),
              );
            });
          },
        ),
      ),
    );
  }
}
