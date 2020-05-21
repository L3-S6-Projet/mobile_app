import 'package:flutter/material.dart';
import 'package:mobile_scolendar/components/app_drawer.dart';

class SubjectsRoute extends StatelessWidget {
  static const ROUTE_NAME = '/subjects';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scolendar'),
      ),
      drawer: AppDrawer(),
      body: Center(child: Text('subjects!')),
    );
  }
}
