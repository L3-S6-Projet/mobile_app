import 'package:flutter/material.dart';
import 'package:mobile_scolendar/components/calendar/calendar.dart';
import 'package:mobile_scolendar/components/calendar/extras.dart';
import 'package:mobile_scolendar/components/calendar/view.dart';
import 'package:openapi/api.dart';

class CalendarDetailsRoute extends StatefulWidget {
  static const ROUTE_NAME = "/calendar_details";

  final CalendarDetailsParameters args;

  const CalendarDetailsRoute({Key key, @required this.args}) : super(key: key);

  @override
  _CalendarDetailsRouteState createState() => _CalendarDetailsRouteState();
}

class _CalendarDetailsRouteState extends State<CalendarDetailsRoute> {
  CalendarView view = CalendarView.MONTH;
  PageController pageController = Calendar.buildPageController();
  int todayReset = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.args.title),
        actions: appBarActions(
          context: context,
          callback: (newView) {
            setState(() {
              this.view = newView;
            });
          },
          onToday: () {
            setState(() {
              todayReset++;
            });
          },
        ),
      ),
      body: Calendar(
        view: this.view,
        pageController: pageController,
        todayReset: todayReset,
        loadOccupancies: ({start, end, occupanciesPerDay}) async {
          if (widget.args.mode == CalendarDetailsMode.TEACHER) {
            final apiInstance = TeacherApi();

            return await apiInstance.teachersIdOccupanciesGet(
              widget.args.id,
              start: start,
              end: end,
              occupanciesPerDay: occupanciesPerDay,
            );
          }

          throw 'Unknown mode.';
        },
      ),
    );
  }
}

class CalendarDetailsParameters {
  final String title;
  final int id;
  final CalendarDetailsMode mode;

  CalendarDetailsParameters({
    @required this.title,
    @required this.id,
    @required this.mode,
  });
}

enum CalendarDetailsMode {
  TEACHER,
}
