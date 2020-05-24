import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:mobile_scolendar/api_exception.dart';
import 'package:mobile_scolendar/auth.dart';
import 'package:mobile_scolendar/components/autocomplete_field.dart';
import 'package:mobile_scolendar/routes/calendar_details.dart';
import 'package:mobile_scolendar/routes/subjects/subject_edit.dart';
import 'package:mobile_scolendar/routes/teachers/teacher_edit.dart';
import 'package:openapi/api.dart';
import 'package:mobile_scolendar/utils.dart';

class SubjectRoute extends StatefulWidget {
  static const ROUTE_NAME = "/subject";

  final SubjectRouteParameters args;

  const SubjectRoute({Key key, @required this.args}) : super(key: key);

  @override
  _SubjectRouteState createState() => _SubjectRouteState();
}

class _SubjectRouteState extends State<SubjectRoute>
    with SingleTickerProviderStateMixin {
  Future<SubjectResponse> responseFuture;
  int _tabIndex = 0;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    responseFuture = loadSubject();

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _tabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<SubjectResponse> loadSubject() async {
    var apiInstance = SubjectsApi();
    return await apiInstance.subjectsIdGet(widget.args.teacherId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: responseFuture,
      builder: (context, snapshot) {
        String title = widget.args.teacherName;

        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) {
          SubjectResponse res = snapshot.data;
          title = res.subject.name;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(title.capitalize(), style: TextStyle()),
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
                        mode: CalendarDetailsMode.SUBJECT,
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
                        context, SubjectEditRoute.ROUTE_NAME,
                        arguments: SubjectEditParameters(
                            widget.args.teacherId, snapshot.data));

                    // TODO : reload the list from parent too

                    if (result != null && result)
                      setState(() {
                        responseFuture = loadSubject();
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
                          content: Text('Cette action n\'est pas réversible.'),
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
                        Uri.parse('${defaultApiClient.basePath}/subjects'));
                    request.body = "[${widget.args.teacherId}]";
                    request.headers["Authorization"] =
                        "Bearer ${authResponse.token}";
                    request.headers["Content-Type"] = "application/json";

                    try {
                      final Response response = await Response.fromStream(
                          await defaultApiClient.client.send(request));

                      defaultApiClient.deserialize(
                          response.body, 'SimpleSuccessResponse');

                      Navigator.pop(context, SubjectRouteResult.DELETED);
                    } catch (e) {
                      print(
                          "Exception when calling TeacherApi->teachersDelete: $e\n");

                      final message = getErrorMessageFromException(e);

                      Scaffold.of(context)
                          .showSnackBar(SnackBar(content: Text(message)));
                    }
                  },
                ),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  text: 'INFO',
                ),
                Tab(
                  text: 'ENSEIGNANTS',
                ),
                Tab(
                  text: 'GROUPES',
                ),
              ],
            ),
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
                return TabBarView(
                  children: [
                    _buildInfosTabs(context, snapshot.data),
                    _buildTeachersTab(context, snapshot.data),
                    _buildGroupsTab(context, snapshot.data),
                  ],
                  controller: _tabController,
                );
              }
            },
          ),
          floatingActionButton: _buildFAB(context),
        );
      },
    );
  }

  Widget _buildFAB(BuildContext context) {
    if (_tabIndex == 0) return null;

    if (_tabIndex == 1) {
      return FloatingActionButton(
        onPressed: () async {
          final result = await showSearch(
              context: context,
              delegate: AutoCompleteSearchDelegate(
                loadItems: (String query, int page) async {
                  var apiInstance = TeacherApi();

                  final response =
                      await apiInstance.teachersGet(query: query, page: page);
                  return response.teachers;
                },
                itemBuilder: (context, item, callback) {
                  return ListTile(
                    title: Text('${item.firstName} ${item.lastName}'),
                    onTap: callback,
                  );
                },
              ));

          if (result == null) return;

          var apiInstance = SubjectsApi();

          try {
            await apiInstance
                .subjectsIdTeachersPost(widget.args.teacherId, [result.id]);

            setState(() {
              responseFuture = loadSubject();
            });
          } catch (e) {
            print(
                "Exception when calling SubjectsApi->subjectsIdGroupsPost: $e\n");
            // TODO: handle error
          }
        },
        child: Icon(Icons.add, color: Colors.white),
      );
    }

    return FloatingActionButton(
      onPressed: () async {
        try {
          var apiInstance = SubjectsApi();

          final response =
              await apiInstance.subjectsIdGroupsPost(widget.args.teacherId);
          print(response);

          setState(() {
            responseFuture = loadSubject();
          });
        } catch (e) {
          print("Exception when calling TeacherApi->teachersDelete: $e\n");

          final message = getErrorMessageFromException(e);

          Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
        }
      },
      child: Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _buildInfosTabs(BuildContext context, SubjectResponse response) {
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
              title: Text('${response.subject.name.capitalize()}'),
              onLongPress: () {
                Clipboard.setData(ClipboardData(
                    text: '${response.subject.name.capitalize()}'));
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text('Texte copié.')));
              },
              subtitle: const Text('Nom'),
            ),
            ListTile(
              leading: Padding(padding: EdgeInsets.all(16.0)),
              title: Text('${response.subject.className}'),
              subtitle: const Text('Classe'),
              onLongPress: () {
                Clipboard.setData(
                    ClipboardData(text: '${response.subject.className}'));
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
                  'Le coût du service est de ${response.subject.totalHours} heures.'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeachersTab(BuildContext context, SubjectResponse response) {
    return ListView.builder(
      itemCount: response.subject.teachers.length,
      itemBuilder: (BuildContext context, int index) {
        SubjectResponseSubjectTeachers teacher =
            response.subject.teachers[index];
        return ListTile(
          title: Text('${teacher.firstName} ${teacher.lastName}'),
          subtitle: (teacher.inCharge) ? const Text('Responsable') : null,
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              final answer = await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Êtes-vous sur ?'),
                    content: Text('Cette action n\'est pas réversible.'),
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

              var request = Request(
                  'DELETE',
                  Uri.parse(
                      '${defaultApiClient.basePath}/subjects/${widget.args.teacherId}/teachers'));
              request.body = "[${teacher.id}]";
              request.headers["Authorization"] = "Bearer ${authResponse.token}";
              request.headers["Content-Type"] = "application/json";

              try {
                final Response response = await Response.fromStream(
                    await defaultApiClient.client.send(request));

                if (response.statusCode >= 400) {
                  throw ApiException(
                      response.statusCode, _decodeBodyBytes(response));
                } else if (response.body != null) {
                  print(defaultApiClient.deserialize(
                      _decodeBodyBytes(response), 'SimpleSuccessResponse'));
                }

                setState(() {
                  responseFuture = loadSubject();
                });
              } catch (e) {
                print(
                    "Exception when calling TeacherApi->teachersDelete: $e\n");

                final message = getErrorMessageFromException(e);

                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text(message)));
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildGroupsTab(BuildContext context, SubjectResponse response) {
    return ListView.builder(
      itemCount: response.subject.groups.length,
      itemBuilder: (BuildContext context, int index) {
        SubjectResponseSubjectGroups group = response.subject.groups[index];
        return ListTile(
          title: Text(group.name),
          subtitle: Text('${group.count} élèves'),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              final answer = await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Êtes-vous sur ?'),
                    content: Text('Cette action n\'est pas réversible.'),
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

              try {
                var apiInstance = SubjectsApi();

                final response = await apiInstance
                    .subjectsIdGroupsDelete(widget.args.teacherId);
                print(response);

                setState(() {
                  responseFuture = loadSubject();
                });
              } catch (e) {
                print(
                    "Exception when calling TeacherApi->teachersDelete: $e\n");

                final message = getErrorMessageFromException(e);

                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text(message)));
              }
            },
          ),
        );
      },
    );
  }
}

String _decodeBodyBytes(Response response) {
  var contentType = response.headers['content-type'];
  if (contentType != null && contentType.contains("application/json")) {
    return utf8.decode(response.bodyBytes);
  } else {
    return response.body;
  }
}

class SubjectRouteParameters {
  final int teacherId;
  final String teacherName;

  SubjectRouteParameters(this.teacherId, this.teacherName);
}

enum SubjectRouteResult {
  DELETED,
}
