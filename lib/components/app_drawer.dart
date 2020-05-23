import 'package:flutter/material.dart';
import 'package:mobile_scolendar/auth.dart';
import 'package:mobile_scolendar/routes/calendar.dart';
import 'package:mobile_scolendar/routes/classes/classes.dart';
import 'package:mobile_scolendar/routes/classrooms/classrooms.dart';
import 'package:mobile_scolendar/routes/login.dart';
import 'package:mobile_scolendar/routes/settings.dart';
import 'package:mobile_scolendar/routes/students/students.dart';
import 'package:mobile_scolendar/routes/subject.dart';
import 'package:mobile_scolendar/routes/teachers/teachers.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
      DrawerHeader(
        child: FutureBuilder(
          future: (() async {
            var auth = await Auth.instance();
            return await auth.getResponse();
          })(),
          builder: (context, snapshot) {
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
                Text('Administrateur',
                    style: theme.textTheme.subtitle1.apply(
                      color: theme.secondaryHeaderColor,
                    )),
              ],
            );
          },
        ),
        decoration: BoxDecoration(color: theme.primaryColor),
      ),
      ListTile(
        leading: Icon(Icons.calendar_today),
        title: Text('Emploi du temps'),
        onTap: () {
          Navigator.pushReplacementNamed(context, CalendarRoute.ROUTE_NAME);
        },
      ),
      ListTile(
        leading: Icon(Icons.account_circle),
        title: Text('Enseignants'),
        onTap: () {
          Navigator.pushReplacementNamed(context, TeachersRoute.ROUTE_NAME);
        },
      ),
      ListTile(
        leading: Icon(Icons.person),
        title: Text('Étudiants'),
        onTap: () {
          Navigator.pushReplacementNamed(context, StudentsRoute.ROUTE_NAME);
        },
      ),
      ListTile(
        leading: Icon(Icons.location_on),
        title: Text('Salles'),
        onTap: () {
          Navigator.pushReplacementNamed(context, ClassroomsRoute.ROUTE_NAME);
        },
      ),
      ListTile(
        leading: Icon(Icons.list),
        title: Text('Classes'),
        onTap: () {
          Navigator.pushReplacementNamed(context, ClassesRoute.ROUTE_NAME);
        },
      ),
      ListTile(
        leading: Icon(Icons.library_books),
        title: Text('Unités d\'enseignement'),
        onTap: () {
          Navigator.pushReplacementNamed(context, SubjectsRoute.ROUTE_NAME);
        },
      ),
      ListTile(
        leading: Icon(Icons.settings),
        title: Text('Paramètres'),
        onTap: () {
          Navigator.pushReplacementNamed(context, SettingsRoute.ROUTE_NAME);
        },
      ),
      ListTile(
        leading: Icon(Icons.exit_to_app),
        title: Text('Déconnexion'),
        onTap: () async {
          await (await Auth.instance()).logout();
          Navigator.pushReplacementNamed(context, LoginRoute.ROUTE_NAME);
        },
      ),
    ]));
  }
}
