import 'package:flutter/material.dart';
import 'package:mobile_scolendar/api_exception.dart';
import 'package:openapi/api.dart';

class ClassCreateRoute extends StatefulWidget {
  static const ROUTE_NAME = "/class/create";

  @override
  _ClassCreateRouteState createState() => _ClassCreateRouteState();
}

class _ClassCreateRouteState extends State<ClassCreateRoute> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  bool enabled = true;
  String message;

  Level level = Level.l1_;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle classe')),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save, color: Colors.white),
        onPressed: onSubmit,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message != null)
                  Text(message,
                      style: TextStyle(color: Theme.of(context).errorColor)),
                TextFormField(
                  enabled: enabled,
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom *',
                  ),
                  validator: (String value) {
                    if (value.length < 3) {
                      return 'Au moins 3 caractères.';
                    }

                    return null;
                  },
                ),
                SizedBox(height: 8.0),
                DropdownButton(
                  hint: const Text('Niveau'),
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(child: const Text('L1'), value: Level.l1_),
                    DropdownMenuItem(child: const Text('L2'), value: Level.l2_),
                    DropdownMenuItem(child: const Text('L3'), value: Level.l3_),
                    DropdownMenuItem(child: const Text('M1'), value: Level.m1_),
                    DropdownMenuItem(child: const Text('M2'), value: Level.m2_),
                  ],
                  value: level,
                  onChanged: enabled
                      ? (newValue) {
                          setState(() {
                            level = newValue;
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  onSubmit() async {
    if (!formKey.currentState.validate()) {
      return;
    }

    setState(() {
      enabled = false;
    });

    var apiInstance = ClassesApi();

    var classObject = ClassObject();

    classObject.name = nameController.text;
    classObject.level = level;

    try {
      var result = await apiInstance.classesPost(classObject);
      Navigator.pop(context, result);
    } catch (e) {
      print("Exception when calling ClassesApi->classesPost: $e\n");

      setState(() {
        enabled = true;
        message = getErrorMessageFromException(e);
      });
    }
  }
}
