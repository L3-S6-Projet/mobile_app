import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scolendar/auth.dart';
import 'package:openapi/api.dart';

class CalendarEventRoute extends StatefulWidget {
  static const ROUTE_NAME = "/calendar/event";

  final CalendarEventRouteArguments args;

  CalendarEventRoute({Key key, @required this.args}) : super(key: key);

  @override
  _CalendarEventRouteState createState() => _CalendarEventRouteState();
}

class _CalendarEventRouteState extends State<CalendarEventRoute> {
  Future<SuccessfulLoginResponse> loginResponseFuture;

  final DateFormat dateFmt = DateFormat('EEE, MMM dd');

  final DateFormat timeFmt = DateFormat('HH:mm');

  Future<SuccessfulLoginResponse> loadLoginResponse() async {
    final auth = await Auth.instance();
    return await auth.getResponse();
  }

  @override
  void initState() {
    super.initState();
    loginResponseFuture = loadLoginResponse();
  }

  @override
  Widget build(BuildContext context) {
    final startDate = DateTime.fromMillisecondsSinceEpoch(
        widget.args.occupancy.start * 1000,
        isUtc: false);

    final endDate = DateTime.fromMillisecondsSinceEpoch(
        widget.args.occupancy.end * 1000,
        isUtc: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails'),
        actions: [
          FutureBuilder(
            future: loginResponseFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done ||
                  snapshot.hasError ||
                  snapshot.data.user.kind != Role.tEA_) return Container();
              return IconButton(
                onPressed: () {},
                icon: Icon(Icons.edit),
              );
            },
          ),
          FutureBuilder(
            future: loginResponseFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done ||
                  snapshot.hasError ||
                  snapshot.data.user.kind != Role.tEA_) return Container();
              return IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete),
              );
            },
          )
        ],
      ),
      body: Container(
        height: double.maxFinite,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              ListTile(
                title: Text(widget.args.occupancy.name ?? ""),
                subtitle: Text('Nom'),
              ),
              ListTile(
                title: Text(widget.args.occupancy.subjectName ?? ""),
                subtitle: Text('Sujet'),
              ),
              ListTile(
                title: Text(dateFmt.format(startDate) +
                    " ⋅ " +
                    timeFmt.format(startDate) +
                    ' - ' +
                    timeFmt.format(endDate)),
                subtitle: Text('Date'),
              ),
              ListTile(
                title:
                    Text(widget.args.occupancy.groupName ?? "Toute la classe"),
                subtitle: Text('Groupe'),
              ),
              ListTile(
                title: Text(widget.args.occupancy.className ?? ""),
                subtitle: Text('Classe'),
              ),
              ListTile(
                title: Text(widget.args.occupancy.teacherName ?? ""),
                subtitle: Text('Enseignant'),
              ),
              ListTile(
                title: Text(widget.args.occupancy.classroomName ?? ""),
                subtitle: Text('Salle'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  onDelete() async {
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

    var apiInstance = OccupanciesApi();
    var id = widget.args.occupancy.id;

    try {
      var result = await apiInstance.occupanciesIdDelete(id);
      print(result);
      Navigator.of(context).pop();
    } catch (e) {
      print("Exception when calling OccupanciesApi->occupanciesIdDelete: $e\n");
      // TODO: handle case
    }
  }
}

class CalendarEventRouteArguments {
  final OccupanciesOccupancies occupancy;

  CalendarEventRouteArguments(this.occupancy);
}
