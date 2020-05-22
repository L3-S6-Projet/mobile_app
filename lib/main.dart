import 'package:flutter/material.dart';
import 'package:mobile_scolendar/auth.dart';
import 'package:mobile_scolendar/routes/calendar.dart';
import 'package:mobile_scolendar/routes/class.dart';
import 'package:mobile_scolendar/routes/classroom.dart';
import 'package:mobile_scolendar/routes/home.dart';
import 'package:mobile_scolendar/routes/login.dart';
import 'package:mobile_scolendar/routes/settings.dart';
import 'package:mobile_scolendar/routes/students.dart';
import 'package:mobile_scolendar/routes/subject.dart';
import 'package:mobile_scolendar/routes/teachers.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<dynamic> loggedInFuture;

  MyApp()
      : loggedInFuture = (() async {
          WidgetsFlutterBinding.ensureInitialized();
          var auth = await Auth.instance();
          return await auth.isLoggedIn();
        })();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loggedInFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();

        final loggedIn = snapshot.data;

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
            HomeRoute.ROUTE_NAME: (ctx) => HomeRoute(),
            CalendarRoute.ROUTE_NAME: (ctx) => CalendarRoute(),
            ClassesRoute.ROUTE_NAME: (ctx) => ClassesRoute(),
            ClassroomsRoute.ROUTE_NAME: (ctx) => ClassroomsRoute(),
            SettingsRoute.ROUTE_NAME: (ctx) => SettingsRoute(),
            StudentsRoute.ROUTE_NAME: (ctx) => StudentsRoute(),
            SubjectsRoute.ROUTE_NAME: (ctx) => SubjectsRoute(),
            TeachersRoute.ROUTE_NAME: (ctx) => TeachersRoute(),
          },
          initialRoute:
              loggedIn ? CalendarRoute.ROUTE_NAME : LoginRoute.ROUTE_NAME,
        );
      },
    );
  }
}
