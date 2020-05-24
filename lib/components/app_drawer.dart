import 'package:flutter/material.dart';
import 'package:mobile_scolendar/auth.dart';
import 'package:mobile_scolendar/routes/calendar.dart';
import 'package:mobile_scolendar/routes/classes/classes.dart';
import 'package:mobile_scolendar/routes/classrooms/classrooms.dart';
import 'package:mobile_scolendar/routes/home.dart';
import 'package:mobile_scolendar/routes/login.dart';
import 'package:mobile_scolendar/routes/settings.dart';
import 'package:mobile_scolendar/routes/students/students.dart';
import 'package:mobile_scolendar/routes/subjects/subjects.dart';
import 'package:mobile_scolendar/routes/teachers/teachers.dart';
import 'package:openapi/api.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
        child: FutureBuilder(future: (() async {
      var auth = await Auth.instance();
      return await auth.getResponse();
    })(), builder: (context, snapshot) {
      var routes = {};
      if (snapshot.hasData) {
        if (snapshot.data.user.kind == Role.aDM_)
          routes = {
            CalendarRoute.ROUTE_NAME: [
              Icon(Icons.calendar_today),
              'Emploi du temps'
            ],
            TeachersRoute.ROUTE_NAME: [
              Icon(Icons.account_circle),
              'Enseignants'
            ],
            StudentsRoute.ROUTE_NAME: [Icon(Icons.person), 'Étudiants'],
            ClassroomsRoute.ROUTE_NAME: [Icon(Icons.location_on), 'Salles'],
            ClassesRoute.ROUTE_NAME: [Icon(Icons.list), 'Classes'],
            SubjectsRoute.ROUTE_NAME: [
              Icon(Icons.library_books),
              'Unités d\'enseignement'
            ],
            SettingsRoute.ROUTE_NAME: [Icon(Icons.settings), 'Paramètres'],
          };
        else
          routes = {
            HomeRoute.ROUTE_NAME: [Icon(Icons.today), 'Accueil'],
            CalendarRoute.ROUTE_NAME: [
              Icon(Icons.calendar_today),
              'Emploi du temps'
            ],
          };
      }
      return ListView(padding: EdgeInsets.zero, children: [
        DrawerHeader(
          child: Builder(
            builder: (context) {
              if (!snapshot.hasData) return Container();

              final response = snapshot.data;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${response.user.firstName} ${response.user.lastName}',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  SizedBox(height: 8.0),
                  Text(roleName(response.user.kind),
                      style: theme.textTheme.subtitle1.apply(
                        color: theme.secondaryHeaderColor,
                      )),
                ],
              );
            },
          ),
          decoration: BoxDecoration(color: theme.primaryColor),
        ),
        ...routes.entries
            .map((entry) => ListTile(
                leading: entry.value[0],
                title: Text(entry.value[1]),
                onTap: () {
                  Navigator.pushReplacementNamed(context, entry.key);
                }))
            .toList(),
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Déconnexion'),
          onTap: () async {
            await (await Auth.instance()).logout();
            Navigator.pushReplacementNamed(context, LoginRoute.ROUTE_NAME);
          },
        )
      ]);
    }));
  }

  String roleName(Role role) {
    if (role == Role.aDM_)
      return "Administrateur";
    else if (role == Role.tEA_)
      return "Enseignant";
    else
      return "Étudiant";
  }
}
