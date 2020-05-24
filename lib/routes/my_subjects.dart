import 'package:flutter/material.dart';
import 'package:mobile_scolendar/api_exception.dart';
import 'package:mobile_scolendar/auth.dart';
import 'package:mobile_scolendar/components/app_drawer.dart';
import 'package:openapi/api.dart';
import 'package:mobile_scolendar/utils.dart';

class MySubjectsRoute extends StatelessWidget {
  static const ROUTE_NAME = '/me/subjects';

  final Future<dynamic> subjectsFuture;

  MySubjectsRoute() : subjectsFuture = loadSubjects();

  static Future<dynamic> loadSubjects() async {
    final auth = await Auth.instance();
    final userResponse = await auth.getResponse();

    if (userResponse.user.kind == Role.sTU_) {
      final apiInstance = RoleStudentApi();
      return await apiInstance.studentsIdSubjectsGet(userResponse.user.id);
    }

    final apiInstance = RoleProfessorApi();
    return await apiInstance.teachersIdSubjectsGet(userResponse.user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scolendar'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: subjectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final message = getErrorMessageFromException(snapshot.error);

            return Center(
              child: Text(
                message,
                style: TextStyle(color: Theme.of(context).errorColor),
              ),
            );
          }

          final response = snapshot.data;

          return Container(
              height: double.maxFinite,
              child: ListView.builder(
                itemCount: response.subjects.length,
                itemBuilder: (context, index) {
                  final subject = response.subjects[index];

                  return ListTile(
                    title: Text((subject.name as String).capitalize()),
                    subtitle: Text(subject.className),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) =>
                              MySubjectDetailsRoute(subject: subject),
                        ),
                      );
                    },
                  );
                },
              ));
        },
      ),
    );
  }
}

class MySubjectDetailsRoute extends StatelessWidget {
  final dynamic subject;

  const MySubjectDetailsRoute({
    Key key,
    @required this.subject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text((subject.name as String).capitalize()),
          bottom: TabBar(
            tabs: [
              Tab(child: Text('Informations')),
              Tab(child: Text('Enseignants')),
              Tab(child: Text('Groupes')),
            ],
          ),
        ),
        body: TabBarView(children: [_infosTab(), _teachersTab(), _groupsTab()]),
      ),
    );
  }

  Widget _infosTab() {
    return Container(
      height: double.maxFinite,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(children: [
          ListTile(
            title: Text((subject.name as String).capitalize()),
            subtitle: Text('Nom'),
          ),
          ListTile(
            title: Text(subject.className),
            subtitle: Text('Classe'),
          ),
        ]),
      ),
    );
  }

  Widget _teachersTab() {
    return Container(
      height: double.maxFinite,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: subject.teachers.length,
        itemBuilder: (context, index) {
          final teacher = subject.teachers[index];

          return ListTile(
            title: Text(
              '${teacher.firstName} ${teacher.lastName}',
            ),
            subtitle: Text(
                '${teacher.email ?? "Pas d'email"}\n${teacher.phoneNumber ?? "Pas de numéro de téléphone"}'),
            trailing: teacher.inCharge ? Text("Responsable") : null,
            isThreeLine: true,
          );
        },
      ),
    );
  }

  Widget _groupsTab() {
    return Container(
      height: double.maxFinite,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: subject.groups.length,
        itemBuilder: (context, index) {
          final group = subject.groups[index];

          return ListTile(
            title: Text(group.name),
            subtitle: Text('${group.count} élèves'),
            trailing: (group is StudentSubjectsGroups) && group.isStudentGroup
                ? Text("Mon groupe")
                : null,
          );
        },
      ),
    );
  }
}
