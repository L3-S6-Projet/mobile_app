import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:mobile_scolendar/api_exception.dart';
import 'package:mobile_scolendar/auth.dart';
import 'package:mobile_scolendar/routes/calendar_details.dart';
import 'package:mobile_scolendar/routes/students/student_edit.dart';
import 'package:openapi/api.dart';
import 'package:mobile_scolendar/utils.dart';

class StudentRoute extends StatefulWidget {
  static const ROUTE_NAME = "/student";

  final StudentRouteParameters args;

  const StudentRoute({Key key, @required this.args}) : super(key: key);

  @override
  _StudentRouteState createState() => _StudentRouteState();
}

class _StudentRouteState extends State<StudentRoute> {
  Future<StudentResponse> responseFuture;

  @override
  void initState() {
    super.initState();
    responseFuture = loadStudent();
  }

  Future<StudentResponse> loadStudent() async {
    var apiInstance = StudentsApi();
    return await apiInstance.studentsIdGet(widget.args.studentId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: responseFuture,
      builder: (context, snapshot) {
        String title = widget.args.studentName;

        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) {
          StudentResponse res = snapshot.data;
          title = '${res.student.firstName} ${res.student.lastName}';
        }

        return Scaffold(
            appBar: AppBar(
              title: Text(title, style: TextStyle()),
              actions: [
                Tooltip(
                  message: 'Voir son calendrier',
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        CalendarDetailsRoute.ROUTE_NAME,
                        arguments: CalendarDetailsParameters(
                          title: widget.args.studentName,
                          mode: CalendarDetailsMode.STUDENT,
                          id: widget.args.studentId,
                        ),
                      );
                    },
                    icon: Icon(Icons.calendar_today),
                  ),
                ),
                Tooltip(
                  message: 'Éditer',
                  child: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () async {
                      if (snapshot.connectionState != ConnectionState.done ||
                          snapshot.hasError) return;

                      final result = await Navigator.pushNamed(
                          context, StudentEditRoute.ROUTE_NAME,
                          arguments: StudentEditParameters(
                              widget.args.studentId, snapshot.data));

                      // TODO : reload the list from parent too

                      if (result != null && result)
                        setState(() {
                          responseFuture = loadStudent();
                        });
                    },
                  ),
                ),
                Tooltip(
                  message: 'Supprimer',
                  child: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      final answer = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Êtes-vous sur ?'),
                            content:
                                Text('Cette action n\'est pas réversible.'),
                            actions: [
                              FlatButton(
                                child: const Text('Annuler'),
                                onPressed: () => Navigator.pop(context, false),
                              ),
                              FlatButton(
                                child: const Text('Supprimer'),
                                textColor: Colors.red,
                                onPressed: () => Navigator.pop(context, true),
                              ),
                            ],
                          );
                        },
                      );

                      if (answer == null || !answer) return;

                      final auth = await Auth.instance();
                      final authResponse = await auth.getResponse();

                      var request = Request('DELETE',
                          Uri.parse('${defaultApiClient.basePath}/students'));
                      request.body = "[${widget.args.studentId}]";
                      request.headers["Authorization"] =
                          "Bearer ${authResponse.token}";
                      request.headers["Content-Type"] = "application/json";

                      try {
                        final Response response = await Response.fromStream(
                            await defaultApiClient.client.send(request));

                        defaultApiClient.deserialize(
                            response.body, 'SimpleSuccessResponse');

                        Navigator.pop(context, StudentRouteResult.DELETED);
                      } catch (e) {
                        print(
                            "Exception when calling StudentApi->studentsDelete: $e\n");

                        final message = getErrorMessageFromException(e);

                        Scaffold.of(context)
                            .showSnackBar(SnackBar(content: Text(message)));
                      }
                    },
                  ),
                ),
              ],
            ),
            body: Builder(
              builder: (context) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  var msg = getErrorMessageFromException(snapshot.error);

                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        msg,
                        style: TextStyle(color: Theme.of(context).errorColor),
                      ),
                    ),
                  );
                } else {
                  return _buildView(context, snapshot.data);
                }
              },
            ));
      },
    );
  }

  Widget _buildView(BuildContext context, StudentResponse response) {
    return Container(
      height: double.infinity,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Informations', style: TextStyle(fontSize: 18.0)),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text(
                  '${response.student.firstName} ${response.student.lastName}'),
              onLongPress: () {
                Clipboard.setData(ClipboardData(
                    text:
                        '${response.student.firstName} ${response.student.lastName}'));
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text('Texte copié.')));
              },
              subtitle: const Text('Nom'),
            ),
            ListTile(
              leading: Padding(padding: EdgeInsets.all(16.0)),
              title: Text('${response.student.username}'),
              subtitle: const Text('Nom d\'utilisateur'),
              onLongPress: () {
                Clipboard.setData(
                    ClipboardData(text: '${response.student.username}'));
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text('Texte copié.')));
              },
            ),
            ListTile(
              leading: Padding(padding: EdgeInsets.all(16.0)),
              title: Text('L3 Informatique'), // TODO : not static
              subtitle: const Text('Classe'),
              onLongPress: () {
                Clipboard.setData(ClipboardData(
                    text: 'L3 Informatique')); // TODO : not static
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text('Texte copié.')));
              },
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Enseignements', style: TextStyle(fontSize: 18.0)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(studiesParagraph(response)),
            ),
          ],
        ),
      ),
    );
  }

  String studiesParagraph(StudentResponse response) {
    final paragraphs = [];

    paragraphs.add('L\'étudiant participe aux UE suivantes :');

    final subjects = response.student.subjects.map((subject) =>
        '  • ${subject.name.capitalize()}, ${subject.group.toLowerCase()}');

    paragraphs.addAll(subjects);

    paragraphs.add(
        'Le nombre total d\'heures d\'enseignement prévues cette année est ${response.student.totalHours} heures.');

    return paragraphs.join("\n\n");
  }
}

class StudentRouteParameters {
  final int studentId;
  final String studentName;

  StudentRouteParameters(this.studentId, this.studentName);
}

enum StudentRouteResult {
  DELETED,
}
