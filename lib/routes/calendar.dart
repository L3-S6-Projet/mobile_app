import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scolendar/components/app_drawer.dart';
import 'package:mobile_scolendar/components/calendar/calendar.dart';
import 'package:mobile_scolendar/components/calendar/extras.dart';
import 'package:mobile_scolendar/components/calendar/selected_date.dart';
import 'package:mobile_scolendar/components/calendar/view.dart';

class CalendarRoute extends StatefulWidget {
  static const ROUTE_NAME = '/calendar';

  @override
  _CalendarRouteState createState() => _CalendarRouteState();
}

class _CalendarRouteState extends State<CalendarRoute> {
  CalendarView view = CalendarView.MONTH;
  PageController pageController = Calendar.buildPageController();
  int todayReset = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scolendar'),
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
      drawer: AppDrawer(),
      body: Calendar(
        view: this.view,
        pageController: pageController,
        todayReset: todayReset,
      ),
    );
  }
}
