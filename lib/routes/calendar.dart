import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scolendar/components/app_drawer.dart';
import 'package:mobile_scolendar/components/calendar/calendar.dart';
import 'package:mobile_scolendar/components/calendar/extras.dart';
import 'package:mobile_scolendar/components/calendar/view.dart';

class CalendarRoute extends StatefulWidget {
  static const ROUTE_NAME = '/calendar';

  @override
  _CalendarRouteState createState() => _CalendarRouteState();
}

class _CalendarRouteState extends State<CalendarRoute> {
  CalendarView view = CalendarView.MONTH;
  PageController pageController = Calendar.buildPageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scolendar'),
        actions: appBarActions(context, (newView) {
          setState(() {
            this.view = newView;
          });
        }, pageController),
      ),
      drawer: AppDrawer(),
      body: Calendar(
        view: this.view,
        pageController: pageController,
      ),
    );
  }
}
