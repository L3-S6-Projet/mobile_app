import 'package:flutter/material.dart';
import 'package:mobile_scolendar/components/calendar/occupancies_wrapper.dart';
import 'package:mobile_scolendar/components/calendar/partition.dart';
import 'package:mobile_scolendar/components/calendar/selected_date.dart';
import 'package:openapi/api.dart';
import 'package:mobile_scolendar/utils.dart';

const LEFT_WIDTH = 48;
const TOP_PADDING = 0;
const START_HOUR = 8;
const END_HOUR = 19;

class HourlyView extends StatelessWidget {
  final SelectedDate selectedDate;
  final List<SelectedDate> week;
  final OccupanciesWrapper occupancies;
  final int days;

  HourlyView(
      {@required this.selectedDate,
      @required this.occupancies,
      @required this.days})
      : week = (days > 1) ? selectedDate.week() : [selectedDate];

  @override
  Widget build(BuildContext context) {
    final cellHeight = MediaQuery.of(context).size.height / 10;

    final events = <WeekViewEvent>[];

    for (var day in week) {
      final occupancies = this.occupancies?.forDay(day) ?? [];
      final partition = Partition(occupancies);

      for (var occupancy in occupancies) {
        final start = DateTime.fromMillisecondsSinceEpoch(
            occupancy.start * 1000,
            isUtc: false);

        final end = DateTime.fromMillisecondsSinceEpoch(occupancy.end * 1000,
            isUtc: false);

        // TODO
        final startHour = start.hour + start.minute / 60 + 1;
        final endHour = end.hour + end.minute / 60 + 1;

        events.add(WeekViewEvent(
          day: (days > 1) ? start.weekday - 1 : 0,
          hour: startHour,
          length: endHour - startHour,
          occupancy: occupancy,
          column: partition.parts[occupancy.id],
          width: partition.widths[occupancy.id],
          days: this.days,
        ));
      }
    }

    // padding: const EdgeInsets.only(top: 8.0),

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      width: 1, color: Theme.of(context).dividerColor))),
          child: Row(
            children: [
              SizedBox(width: LEFT_WIDTH.toDouble()),
              if (this.days > 1)
                for (var day in week)
                  Expanded(
                    child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                          left: BorderSide(
                            width: (week.indexOf(day) == 0) ? 0 : 1,
                            color: Theme.of(context).dividerColor,
                          ),
                        )),
                        padding: const EdgeInsets.all(4.0),
                        child: Center(child: Text('${day.day}'))),
                  )
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    WeekViewBackground(
                      cellHeight: cellHeight,
                      days: days,
                    ),
                    ...events,
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class WeekViewBackground extends StatelessWidget {
  final double cellHeight;
  final int days;

  WeekViewBackground({@required this.cellHeight, @required this.days});

  Widget _leftColumn(BuildContext context) {
    final cellHeight = MediaQuery.of(context).size.height / 10;
    final fontSize = 12.0;

    return Container(
      child: Column(children: [
        SizedBox(height: TOP_PADDING.toDouble()),
        SizedBox(
            width: LEFT_WIDTH.toDouble(), height: cellHeight - fontSize / 2.0),
        for (var i = 0; i < (END_HOUR - START_HOUR); i++)
          Container(
            height: this.cellHeight,
            padding: const EdgeInsets.only(left: 2.0),
            width: LEFT_WIDTH.toDouble(),
            child: Row(
              children: [
                Spacer(),
                Text('${START_HOUR + i}'.padLeft(2, '0') + ':00',
                    style: TextStyle(fontSize: fontSize)),
                SizedBox(width: 4.0),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3.0),
                  child: SizedBox(
                      width: 4,
                      height: 1,
                      child: Container(color: Theme.of(context).dividerColor)),
                ),
              ],
            ),
            alignment: Alignment.topRight,
          )
      ]),
    );
  }

  Widget _column(BuildContext context) {
    // BorderSide(width: 1, color: Theme.of(context).dividerColor)

    //final border = Border.all(color: theme.dividerColor);
    final border = Border(
      left: BorderSide(width: 1, color: Theme.of(context).dividerColor),
      bottom: BorderSide(width: 1, color: Theme.of(context).dividerColor),
    );

    return Expanded(
      child: Container(
        child: Column(
          children: [
            SizedBox(height: TOP_PADDING.toDouble()),
            for (var i = 0; i < (END_HOUR - START_HOUR) + 1; i++)
              Container(
                  height: this.cellHeight,
                  width: double.maxFinite,
                  decoration: BoxDecoration(border: border))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _leftColumn(context),
        for (var i = 0; i < this.days; i++) _column(context),
      ],
    );
  }
}

class WeekViewEvent extends StatelessWidget {
  final day;
  final hour;
  final length;
  final column;
  final width;
  final OccupanciesOccupancies occupancy;
  final days;

  WeekViewEvent(
      {@required this.day,
      @required this.hour,
      @required this.length,
      @required this.occupancy,
      @required this.column,
      @required this.width,
      @required this.days});

  @override
  Widget build(BuildContext context) {
    final cellHeight = MediaQuery.of(context).size.height / 10;
    final cellWidth =
        (MediaQuery.of(context).size.width - LEFT_WIDTH) / this.days;

    return Positioned(
      top: cellHeight * (hour - START_HOUR) + TOP_PADDING,
      left: LEFT_WIDTH +
          day * cellWidth +
          ((cellWidth / this.width) * (this.column - 1)) +
          1,
      height: length * cellHeight,
      width: (cellWidth / this.width) - 2,
      child: Container(
          decoration: BoxDecoration(
            //color: Theme.of(context).primaryColorLight,
            color: Colors.white,
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(5.0),
          ),
          padding: const EdgeInsets.all(4.0),
          child: Text(occupancy.subjectName.capitalize(),
              style: TextStyle(fontSize: 12.0))),
    );
  }
}
