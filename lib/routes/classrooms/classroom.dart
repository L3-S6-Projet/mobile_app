import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:mobile_scolendar/api_exception.dart';
import 'package:mobile_scolendar/auth.dart';
import 'package:mobile_scolendar/routes/calendar_details.dart';
import 'package:mobile_scolendar/routes/classrooms/classroom_edit.dart';
import 'package:openapi/api.dart';

class ClassroomRoute extends StatefulWidget {
  static const ROUTE_NAME = "/classroom";

  final ClassroomRouteParameters args;

  const ClassroomRoute({Key key, @required this.args}) : super(key: key);

  @override
  _ClassroomRouteState createState() => _ClassroomRouteState();
}

class _ClassroomRouteState extends State<ClassroomRoute> {
  Future<ClassroomGetResponse> responseFuture;

  @override
  void initState() {
    super.initState();
    responseFuture = loadStudent();
  }

  Future<ClassroomGetResponse> loadStudent() async {
    var apiInstance = ClassroomApi();
    return await apiInstance.classroomsIdGet(widget.args.studentId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: responseFuture,
      builder: (context, snapshot) {
        String title = widget.args.studentName;

        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) {
          ClassroomGetResponse res = snapshot.data;
          title = res.classroom.name;
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
                          mode: CalendarDetailsMode.CLASSROOM,
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
                          context, ClassroomEditRoute.ROUTE_NAME,
                          arguments: ClassroomEditParameters(
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
                          Uri.parse('${defaultApiClient.basePath}/classrooms'));
                      request.body = "[${widget.args.studentId}]";
                      request.headers["Authorization"] =
                          "Bearer ${authResponse.token}";
                      request.headers["Content-Type"] = "application/json";

                      try {
                        final Response response = await Response.fromStream(
                            await defaultApiClient.client.send(request));

                        defaultApiClient.deserialize(
                            response.body, 'SimpleSuccessResponse');

                        Navigator.pop(context, ClassroomRouteResult.DELETED);
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

  Widget _buildView(BuildContext context, ClassroomGetResponse response) {
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
              title: Text('${response.classroom.name}'),
              onLongPress: () {
                Clipboard.setData(
                    ClipboardData(text: '${response.classroom.name}'));
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text('Texte copié.')));
              },
              subtitle: const Text('Nom'),
            ),
            ListTile(
              leading: Padding(padding: EdgeInsets.all(16.0)),
              title: Text('${response.classroom.capacity}'),
              subtitle: const Text('Capacité'),
              onLongPress: () {
                Clipboard.setData(
                    ClipboardData(text: '${response.classroom.capacity}'));
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text('Texte copié.')));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ClassroomRouteParameters {
  final int studentId;
  final String studentName;

  ClassroomRouteParameters(this.studentId, this.studentName);
}

enum ClassroomRouteResult {
  DELETED,
}
