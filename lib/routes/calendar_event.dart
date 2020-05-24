import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openapi/api.dart';

class CalendarEventRoute extends StatelessWidget {
  static const ROUTE_NAME = "/calendar/event";

  final DateFormat dateFmt = DateFormat('EEE, MMM dd');
  final DateFormat timeFmt = DateFormat('HH:mm');

  final CalendarEventRouteArguments args;

  CalendarEventRoute({Key key, @required this.args}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final startDate = DateTime.fromMillisecondsSinceEpoch(
        args.occupancy.start * 1000,
        isUtc: false);

    final endDate = DateTime.fromMillisecondsSinceEpoch(
        args.occupancy.end * 1000,
        isUtc: false);

    return Scaffold(
      appBar: AppBar(title: Text('Détails')),
      body: Container(
        height: double.maxFinite,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              ListTile(
                title: Text(args.occupancy.name ?? ""),
                subtitle: Text('Nom'),
              ),
              ListTile(
                title: Text(args.occupancy.subjectName ?? ""),
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
                title: Text(args.occupancy.groupName ?? "Toute la classe"),
                subtitle: Text('Groupe'),
              ),
              ListTile(
                title: Text(args.occupancy.className ?? ""),
                subtitle: Text('Classe'),
              ),
              ListTile(
                title: Text(args.occupancy.teacherName ?? ""),
                subtitle: Text('Enseignant'),
              ),
              ListTile(
                title: Text(args.occupancy.classroomName ?? ""),
                subtitle: Text('Salle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CalendarEventRouteArguments {
  final OccupanciesOccupancies occupancy;

  CalendarEventRouteArguments(this.occupancy);
}
