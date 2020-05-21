import 'package:flutter/material.dart';
import 'package:mobile_scolendar/components/app_drawer.dart';

class ClassroomsRoute extends StatelessWidget {
  static const ROUTE_NAME = '/classrooms';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scolendar'),
      ),
      drawer: AppDrawer(),
      body: Center(child: Text('Classroom')),
    );
  }
}
