import 'package:flutter/material.dart';
import 'package:mobile_scolendar/routes/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF3F51B5),
        primaryColorLight: const Color(0xFFC5CAE9),
        primaryColorDark: const Color(0xFF303F9F),
        errorColor: const Color(0xFFFF0C3E),
        accentColor: const Color(0xFFFF9800),
        dividerColor: const Color(0xFFBDBDBD),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        LoginRoute.ROUTE_NAME: (ctx) => LoginRoute(),
      },
      initialRoute: LoginRoute.ROUTE_NAME,
    );
  }
}
