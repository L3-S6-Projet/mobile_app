import 'package:flutter/material.dart';
import 'package:mobile_scolendar/components/app_drawer.dart';

class HomeRoute extends StatefulWidget {
  static const ROUTE_NAME = "Home";

  @override
  _HomeRouteState createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scolendar'),
      ),
      drawer: AppDrawer(),
      body: Center(child: Text('home!')),
    );
  }
}
