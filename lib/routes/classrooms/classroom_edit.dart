import 'package:flutter/material.dart';
import 'package:mobile_scolendar/api_exception.dart';
import 'package:openapi/api.dart';

class ClassroomEditRoute extends StatefulWidget {
  static const ROUTE_NAME = "/classroom/update";

  final ClassroomEditParameters args;

  const ClassroomEditRoute({Key key, @required this.args}) : super(key: key);

  @override
  _ClassroomEditRouteState createState() => _ClassroomEditRouteState();
}

// TODO : class id update, which is NOT returned by the API

class _ClassroomEditRouteState extends State<ClassroomEditRoute> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  bool enabled = true;
  String message;

  @override
  void initState() {
    super.initState();
    final classroom = widget.args.classroomResponse.classroom;
    nameController.text = classroom.name;
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String simpleThreeCharsValidator(String value) {
    if (value.length < 3) {
      return 'Au moins 3 caractères.';
    }

    return null;
  }

  onSubmit() async {
    if (!formKey.currentState.validate()) {
      return;
    }

    setState(() {
      enabled = false;
    });

    var apiInstance = ClassroomApi();

    var classroomUpdateRequest = ClassroomUpdateRequest();

    classroomUpdateRequest.name = nameController.text;

    try {
      await apiInstance.classroomsIdPut(widget.args.id, classroomUpdateRequest);
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

class ClassroomEditParameters {
  final ClassroomGetResponse classroomResponse;
  final int id;

  ClassroomEditParameters(this.id, this.classroomResponse);
}
