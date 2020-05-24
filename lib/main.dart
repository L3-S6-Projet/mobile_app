import 'package:flutter/material.dart';
import 'package:mobile_scolendar/auth.dart';
import 'package:mobile_scolendar/initial_route.dart';
import 'package:mobile_scolendar/routes/calendar.dart';
import 'package:mobile_scolendar/routes/calendar_details.dart';
import 'package:mobile_scolendar/routes/classes/class.dart';
import 'package:mobile_scolendar/routes/classes/class_create.dart';
import 'package:mobile_scolendar/routes/classes/class_edit.dart';
import 'package:mobile_scolendar/routes/classes/classes.dart';
import 'package:mobile_scolendar/routes/classrooms/classroom.dart';
import 'package:mobile_scolendar/routes/classrooms/classroom_create.dart';
import 'package:mobile_scolendar/routes/classrooms/classroom_edit.dart';
import 'package:mobile_scolendar/routes/classrooms/classrooms.dart';
import 'package:mobile_scolendar/routes/home.dart';
import 'package:mobile_scolendar/routes/login.dart';
import 'package:mobile_scolendar/routes/settings.dart';
import 'package:mobile_scolendar/routes/students/student.dart';
import 'package:mobile_scolendar/routes/students/student_create.dart';
import 'package:mobile_scolendar/routes/students/student_edit.dart';
import 'package:mobile_scolendar/routes/students/students.dart';
import 'package:mobile_scolendar/routes/subjects/subject.dart';
import 'package:mobile_scolendar/routes/subjects/subject_create.dart';
import 'package:mobile_scolendar/routes/subjects/subject_edit.dart';
import 'package:mobile_scolendar/routes/subjects/subjects.dart';
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

            return LoginStatus(true, await auth.getResponse());
          }

          return LoginStatus(false, null);
        })();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loggedInFuture,
      builder: (context, snapshot) {
        // TODO: splash screen
        if (!snapshot.hasData) return Container();

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
              case CalendarDetailsRoute.ROUTE_NAME:
                routeBuilder = (ctx) =>
                    CalendarDetailsRoute(args: routeSettings.arguments);
                break;
              case TeacherRoute.ROUTE_NAME:
                routeBuilder =
                    (ctx) => TeacherRoute(args: routeSettings.arguments);
                break;
              case TeacherEditRoute.ROUTE_NAME:
                routeBuilder =
                    (ctx) => TeacherEditRoute(args: routeSettings.arguments);
                break;
              case StudentRoute.ROUTE_NAME:
                routeBuilder =
                    (ctx) => StudentRoute(args: routeSettings.arguments);
                break;
              case StudentEditRoute.ROUTE_NAME:
                routeBuilder =
                    (ctx) => StudentEditRoute(args: routeSettings.arguments);
                break;
              case ClassroomRoute.ROUTE_NAME:
                routeBuilder =
                    (ctx) => ClassroomRoute(args: routeSettings.arguments);
                break;
              case ClassroomEditRoute.ROUTE_NAME:
                routeBuilder =
                    (ctx) => ClassroomEditRoute(args: routeSettings.arguments);
                break;
              case ClassRoute.ROUTE_NAME:
                routeBuilder =
                    (ctx) => ClassRoute(args: routeSettings.arguments);
                break;
              case ClassEditRoute.ROUTE_NAME:
                routeBuilder =
                    (ctx) => ClassEditRoute(args: routeSettings.arguments);
                break;
              case SubjectRoute.ROUTE_NAME:
                routeBuilder =
                    (ctx) => SubjectRoute(args: routeSettings.arguments);
                break;
              case SubjectEditRoute.ROUTE_NAME:
                routeBuilder =
                    (ctx) => SubjectEditRoute(args: routeSettings.arguments);
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
            ClassCreateRoute.ROUTE_NAME: (ctx) => ClassCreateRoute(),
            ClassroomsRoute.ROUTE_NAME: (ctx) => ClassroomsRoute(),
            ClassroomCreateRoute.ROUTE_NAME: (ctx) => ClassroomCreateRoute(),
            SettingsRoute.ROUTE_NAME: (ctx) => SettingsRoute(),
            StudentsRoute.ROUTE_NAME: (ctx) => StudentsRoute(),
            StudentCreateRoute.ROUTE_NAME: (ctx) => StudentCreateRoute(),
            SubjectsRoute.ROUTE_NAME: (ctx) => SubjectsRoute(),
            SubjectCreateRoute.ROUTE_NAME: (ctx) => SubjectCreateRoute(),
            TeachersRoute.ROUTE_NAME: (ctx) => TeachersRoute(),
            TeacherCreateRoute.ROUTE_NAME: (ctx) => TeacherCreateRoute(),
          },
          initialRoute: initialRouteName(snapshot.data?.response),
        );
      },
    );
  }
}

class LoginStatus {
  final bool loggedIn;
  final SuccessfulLoginResponse response;

  LoginStatus(this.loggedIn, this.response);
}
