import 'package:flutter/material.dart';
import 'package:mobile_scolendar/components/app_drawer.dart';

class CalendarRoute extends StatelessWidget {
  static const ROUTE_NAME = '/calendar';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scolendar'),
      ),
      drawer: AppDrawer(),
      body: Center(child: Text('calendar!')),
    );
  }
}
