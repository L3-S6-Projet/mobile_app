import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:mobile_scolendar/api_exception.dart';
import 'package:mobile_scolendar/auth.dart';
import 'package:mobile_scolendar/routes/calendar_details.dart';
import 'package:mobile_scolendar/routes/classes/class_edit.dart';
import 'package:openapi/api.dart';

class ClassRoute extends StatefulWidget {
  static const ROUTE_NAME = "/class";

  final ClassRouteParameters args;

  const ClassRoute({Key key, @required this.args}) : super(key: key);

  @override
  _ClassRouteState createState() => _ClassRouteState();
}

class _ClassRouteState extends State<ClassRoute> {
  Future<ClassResponse> responseFuture;

  @override
  void initState() {
    super.initState();
    responseFuture = loadStudent();
  }

  Future<ClassResponse> loadStudent() async {
    var apiInstance = ClassesApi();
    return await apiInstance.classesIdGet(widget.args.classId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: responseFuture,
      builder: (context, snapshot) {
        String title = widget.args.className;

        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) {
          ClassResponse res = snapshot.data;
          title = res.class_.name;
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
                          title: widget.args.className,
                          mode: CalendarDetailsMode.CLASS,
                          id: widget.args.classId,
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
                          context, ClassEditRoute.ROUTE_NAME,
                          arguments: ClassEditParameters(
                              widget.args.classId, snapshot.data));

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
                          Uri.parse('${defaultApiClient.basePath}/classes'));
                      request.body = "[${widget.args.classId}]";
                      request.headers["Authorization"] =
                          "Bearer ${authResponse.token}";
                      request.headers["Content-Type"] = "application/json";

                      try {
                        final Response response = await Response.fromStream(
                            await defaultApiClient.client.send(request));

                        defaultApiClient.deserialize(
                            response.body, 'SimpleSuccessResponse');

                        Navigator.pop(context, ClassRouteResult.DELETED);
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

  Widget _buildView(BuildContext context, ClassResponse response) {
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
              title: Text('${response.class_.name}'),
              onLongPress: () {
                Clipboard.setData(
                    ClipboardData(text: '${response.class_.name}'));
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text('Texte copié.')));
              },
              subtitle: const Text('Nom'),
            ),
            ListTile(
              leading: Padding(padding: EdgeInsets.all(16.0)),
              title: Text('${response.class_.level.value}'),
              subtitle: const Text('Niveau'),
              onLongPress: () {
                Clipboard.setData(
                    ClipboardData(text: '${response.class_.level.value}'));
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text('Texte copié.')));
              },
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Service', style: TextStyle(fontSize: 18.0)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                  'Le coût du service est de ${response.totalService} heures.'),
            ),
          ],
        ),
      ),
    );
  }
}

class ClassRouteParameters {
  final int classId;
  final String className;

  ClassRouteParameters(this.classId, this.className);
}

enum ClassRouteResult {
  DELETED,
}
