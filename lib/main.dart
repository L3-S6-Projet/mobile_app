import 'package:flutter/material.dart';
import 'package:mobile_scolendar/auth.dart';
import 'package:mobile_scolendar/routes/calendar.dart';
import 'package:mobile_scolendar/routes/calendar_details.dart';
import 'package:mobile_scolendar/routes/class.dart';
import 'package:mobile_scolendar/routes/classroom.dart';
import 'package:mobile_scolendar/routes/home.dart';
import 'package:mobile_scolendar/routes/login.dart';
import 'package:mobile_scolendar/routes/settings.dart';
import 'package:mobile_scolendar/routes/students.dart';
import 'package:mobile_scolendar/routes/subject.dart';
import 'package:mobile_scolendar/routes/teachers/teacher.dart';
import 'package:mobile_scolendar/routes/teachers/teacher_create.dart';
import 'package:mobile_scolendar/routes/teachers/teacher_edit.dart';
import 'package:mobile_scolendar/routes/teachers/teachers.dart';
import 'package:openapi/api.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<dynamic> loggedInFuture;

  MyApp()
      : loggedInFuture = (() async {
          WidgetsFlutterBinding.ensureInitialized();
          var auth = await Auth.instance();
          final loggedIn = await auth.isLoggedIn();

          if (loggedIn) {
            final token =
                defaultApiClient.getAuthentication<ApiKeyAuth>('token');
            token.apiKey = (await auth.getResponse()).token;
            token.apiKeyPrefix = 'Bearer';
          }

          return loggedIn;
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
            brightness: Brightness.light, // TODO: add setting in app
            primaryColor: const Color(0xFF3F51B5),
            primaryColorLight: const Color(0xFFC5CAE9),
            primaryColorDark: const Color(0xFF303F9F),
            errorColor: const Color(0xFFFF0C3E),
            accentColor: const Color(0xFFFF9800),
            dividerColor: const Color(0xFFBDBDBD),
            cursorColor: const Color(0xFF3F51B5),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          onGenerateRoute: (RouteSettings routeSettings) {
            WidgetBuilder routeBuilder;

            switch (routeSettings.name) {
              case TeacherRoute.ROUTE_NAME:
                routeBuilder =
                    (ctx) => TeacherRoute(args: routeSettings.arguments);
                break;
              case CalendarDetailsRoute.ROUTE_NAME:
                routeBuilder = (ctx) =>
                    CalendarDetailsRoute(args: routeSettings.arguments);
                break;
              case TeacherEditRoute.ROUTE_NAME:
                routeBuilder =
                    (ctx) => TeacherEditRoute(args: routeSettings.arguments);
                break;
              default:
                return null;
            }

            return MaterialPageRoute(builder: (ctx) => routeBuilder(ctx));
          },
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
            TeacherCreateRoute.ROUTE_NAME: (ctx) => TeacherCreateRoute(),
          },
          // TODO: change based on user kind
          initialRoute:
              loggedIn ? TeachersRoute.ROUTE_NAME : LoginRoute.ROUTE_NAME,
        );
      },
    );
  }
}
