import 'package:flutter/material.dart';
import 'package:mobile_scolendar/api_exception.dart';
import 'package:openapi/api.dart';

class ClassEditRoute extends StatefulWidget {
  static const ROUTE_NAME = "/class/update";

  final ClassEditParameters args;

  const ClassEditRoute({Key key, @required this.args}) : super(key: key);

  @override
  _ClassEditRouteState createState() => _ClassEditRouteState();
}

// TODO : class id update, which is NOT returned by the API

class _ClassEditRouteState extends State<ClassEditRoute> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  bool enabled = true;
  String message;

  Level level;

  @override
  void initState() {
    super.initState();
    final classObject = widget.args.classResponse.class_;
    nameController.text = classObject.name;
    level = classObject.level;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Édition')),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save, color: Colors.white),
        onPressed: onSubmit,
      ),
      body: Container(
        height: double.infinity,
        child: SingleChildScrollView(
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
                      DropdownMenuItem(
                          child: const Text('L1'), value: Level.l1_),
                      DropdownMenuItem(
                          child: const Text('L2'), value: Level.l2_),
                      DropdownMenuItem(
                          child: const Text('L3'), value: Level.l3_),
                      DropdownMenuItem(
                          child: const Text('M1'), value: Level.m1_),
                      DropdownMenuItem(
                          child: const Text('M2'), value: Level.m2_),
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

    var classUpdateRequest = ClassUpdateRequest();

    classUpdateRequest.name = nameController.text;
    classUpdateRequest.level = level;

    try {
      await apiInstance.classesIdPut(widget.args.id, classUpdateRequest);
      Navigator.pop(context, true);
    } catch (e) {
      print("Exception when calling ClassroomApi->classroomsPost: $e\n");
      print(e);

      setState(() {
        enabled = true;
        message = getErrorMessageFromException(e);
      });
    }
  }
}

class ClassEditParameters {
  final ClassResponse classResponse;
  final int id;

  ClassEditParameters(this.id, this.classResponse);
}
