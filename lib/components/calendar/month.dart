import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mobile_scolendar/components/calendar/occupancies_wrapper.dart';
import 'package:mobile_scolendar/components/calendar/selected_date.dart';
import 'package:mobile_scolendar/routes/calendar_event.dart';
import 'package:openapi/api.dart';
import 'package:mobile_scolendar/utils.dart';

class MonthView extends StatelessWidget {
  final OccupanciesWrapper occupancies;
  final List<SelectedDate> days;
  final SelectedDate selectedDate;

  MonthView({@required this.selectedDate, @required this.occupancies})
      : days = selectedDate.days();

  Widget _cell(SelectedDate date) {
    final widgets = <Widget>[Text('${date.date.day}')];

    if (occupancies != null) {
      final dayOccupancies = occupancies.forDay(date);

      widgets.addAll(dayOccupancies
          .sublist(0, min(2, dayOccupancies.length))
          .map((x) => SmallEvent(
                occupancy: x,
              )));
    }

    // TODO: figure out how to use a clipper
    return Expanded(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: widgets,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rowCount = 5;
    final columnCount = 7;

    final rows = <Widget>[];

    for (var c = 0; c < columnCount; c++) {
      final column = <Widget>[];

      for (var r = 0; r < rowCount; r++) {
        column.add(this._cell(days[c + r * columnCount]));
      }

      rows.add(Expanded(
        child: Column(
          children: column,
        ),
      ));
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: rows,
      ),
    );
  }
}

class SmallEvent extends StatelessWidget {
  final OccupanciesOccupancies occupancy;

  const SmallEvent({Key key, @required this.occupancy}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).dividerColor;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          CalendarEventRoute.ROUTE_NAME,
          arguments: CalendarEventRouteArguments(occupancy),
        );
      },
      child: Container(
          padding: const EdgeInsets.all(4.0),
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.grey[700],
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(color: borderColor)),
          child: Text(occupancy.subjectName.capitalize(),
              style: TextStyle(fontSize: 12.0),
              overflow: TextOverflow.ellipsis)),
    );
  }
}
