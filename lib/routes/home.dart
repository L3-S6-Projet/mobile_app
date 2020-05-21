import 'package:flutter/material.dart';

class HomeRoute extends StatelessWidget {
  static const ROUTE_NAME = "Home";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scolendar'),
      ),
      body: Center(
        child: Text('Home!'),
      ),
    );
  }
}
