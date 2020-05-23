import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:mobile_scolendar/api_exception.dart';
import 'package:mobile_scolendar/auth.dart';
import 'package:mobile_scolendar/routes/calendar_details.dart';
import 'package:mobile_scolendar/routes/teachers/teacher_edit.dart';
import 'package:openapi/api.dart';

class TeacherRoute extends StatefulWidget {
  static const ROUTE_NAME = "/teacher";

  final TeacherRouteParameters args;

  const TeacherRoute({Key key, @required this.args}) : super(key: key);

  @override
  _TeacherRouteState createState() => _TeacherRouteState();
}

class _TeacherRouteState extends State<TeacherRoute> {
  Future<TeacherResponse> responseFuture;

  @override
  void initState() {
    super.initState();
    responseFuture = loadTeacher();
  }

  Future<TeacherResponse> loadTeacher() async {
    var apiInstance = TeacherApi();
    return await apiInstance.teachersIdGet(widget.args.teacherId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: responseFuture,
      builder: (context, snapshot) {
        String title = widget.args.teacherName;

        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) {
          TeacherResponse res = snapshot.data;
          title = '${res.teacher.firstName} ${res.teacher.lastName}';
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
                          title: widget.args.teacherName,
                          mode: CalendarDetailsMode.TEACHER,
                          id: widget.args.teacherId,
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
                          context, TeacherEditRoute.ROUTE_NAME,
                          arguments: TeacherEditParameters(
                              widget.args.teacherId, snapshot.data));

                      // TODO : reload the list from parent too

                      if (result != null && result)
                        setState(() {
                          responseFuture = loadTeacher();
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
                          Uri.parse('${defaultApiClient.basePath}/teachers'));
                      request.body = "[${widget.args.teacherId}]";
                      request.headers["Authorization"] =
                          "Bearer ${authResponse.token}";
                      request.headers["Content-Type"] = "application/json";

                      try {
                        final Response response = await Response.fromStream(
                            await defaultApiClient.client.send(request));

                        defaultApiClient.deserialize(
                            response.body, 'SimpleSuccessResponse');

                        Navigator.pop(context, TeacherRouteResult.DELETED);
                      } catch (e) {
                        print(
                            "Exception when calling TeacherApi->teachersDelete: $e\n");

                        final message = getErrorMessageFromException(e);

                        Scaffold.of(context)
                            .showSnackBar(SnackBar(content: Text(message)));
                      }

                      /*try {
                        await apiInstance.teachersDelete(iDRequest);
                        Navigator.pop(context, TeacherRouteResult.DELETED);
                      } catch (e) {
                        print(
                            "Exception when calling TeacherApi->teachersDelete: $e\n");

                        final message = getErrorMessageFromException(e);

                        Scaffold.of(context)
                            .showSnackBar(SnackBar(content: Text(message)));
                      }*/
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

  Widget _buildView(BuildContext context, TeacherResponse response) {
    return SingleChildScrollView(
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
                '${response.teacher.firstName} ${response.teacher.lastName}'),
            onLongPress: () {
              Clipboard.setData(ClipboardData(
                  text:
                      '${response.teacher.firstName} ${response.teacher.lastName}'));
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text('Texte copié.')));
            },
            subtitle: const Text('Nom'),
          ),
          ListTile(
            leading: Padding(padding: EdgeInsets.all(16.0)),
            title: Text('${response.teacher.username}'),
            subtitle: const Text('Nom d\'utilisateur'),
            onLongPress: () {
              Clipboard.setData(
                  ClipboardData(text: '${response.teacher.username}'));
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text('Texte copié.')));
            },
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text('${response.teacher.email ?? "Non spécifié"}'),
            subtitle: const Text('Email'),
            onLongPress: () {
              Clipboard.setData(ClipboardData(
                  text: '${response.teacher.email ?? "Non spécifié"}'));
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text('Texte copié.')));
            },
          ),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text(
                '${formatPhoneNumber(response.teacher.phoneNumber ?? "Non spécifié")}'),
            subtitle: const Text('Numéro de téléphone'),
            onLongPress: () {
              Clipboard.setData(ClipboardData(
                  text:
                      '${formatPhoneNumber(response.teacher.phoneNumber ?? "Non spécifié")}'));
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text('Texte copié.')));
            },
          ),
          ListTile(
            leading: Padding(padding: EdgeInsets.all(16.0)),
            title: Text('${rankAsString(response.teacher.rank)}'),
            subtitle: const Text('Grade'),
            onLongPress: () {
              Clipboard.setData(ClipboardData(
                  text: '${rankAsString(response.teacher.rank)}'));
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
            child: Text(serviceParagraph(response)),
          ),
        ],
      ),
    );
  }

  String serviceParagraph(TeacherResponse response) {
    final paragraphs = [];

    for (var service in response.teacher.services) {
      var text = "Pour l'année " + service.class_ + ", l'enseignant(e) ";

      var cm = service.cm ?? -1;
      var project = service.project ?? -1;
      var td = service.td ?? -1;
      var tp = service.tp ?? -1;
      var administration = service.administration ?? -1;
      var external_ = service.external_ ?? -1;

      final total = (cm + project + td + tp + administration + external_);

      if (total <= 0) {
        text += "n'a pas proposé de cours.";
      } else {
        text += "à proposé ";

        final parts = [];

        if (cm > 0) parts.add(cm.toString() + ' heures de CM');

        if (project > 0) parts.add(project.toString() + ' heures de projet');

        if (td > 0) parts.add(td.toString() + ' heures de TD');

        if (tp > 0) parts.add(tp.toString() + ' heures de TP');

        if (administration > 0)
          parts.add(administration.toString() + ' heures d\'administration');

        if (external_ > 0) parts.add(external_.toString() + ' heures externes');

        if (parts.length == 1) {
          text += parts[0];
        } else if (parts.length > 1) {
          var left = parts.sublist(0, parts.length - 1);
          var right = parts[parts.length - 1];
          text += left.join(', ') + ' et ' + right;
        }

        text += '.';
      }

      paragraphs.add(text);
    }

    paragraphs.add('La valeur totale de son service est de ' +
        response.teacher.totalService.toString() +
        ' heures.');

    return paragraphs.join("\n\n");
  }

  static String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length != 10 || !phoneNumber.startsWith('0'))
      return phoneNumber;

    List<String> formatted = [];

    for (var i = 0; i < 10; i += 2) {
      formatted.add(phoneNumber.substring(i, i + 2));
    }

    return formatted.join(" ");
  }

  static String rankAsString(Rank rank) {
    switch (rank.value) {
      case "MACO":
        return "Maître de conférences";
      case "PROF":
        return "Professeur";
      case "PRAG":
        return "PRAG";
      case "ATER":
        return "ATER";
      case "PAST":
        return "PAST";
      case "MONI":
        return "Moniteur";
      default:
        throw ('unknown rank');
    }
  }
}

class TeacherRouteParameters {
  final int teacherId;
  final String teacherName;

  TeacherRouteParameters(this.teacherId, this.teacherName);
}

enum TeacherRouteResult {
  DELETED,
}
