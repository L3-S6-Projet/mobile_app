import 'package:flutter/material.dart';
import 'package:mobile_scolendar/api_exception.dart';
import 'package:mobile_scolendar/components/autocomplete_field.dart';
import 'package:openapi/api.dart';

class ClassroomCreateRoute extends StatefulWidget {
  static const ROUTE_NAME = "/classroom/create";

  @override
  _ClassroomCreateRouteState createState() => _ClassroomCreateRouteState();
}

class _ClassroomCreateRouteState extends State<ClassroomCreateRoute> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final capacityController = TextEditingController(text: '0');
  bool enabled = true;
  String message;

  Rank rank = Rank.pROF_;

  ClassWithId selectedClass;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle salle')),
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
                TextFormField(
                  enabled: enabled,
                  controller: capacityController,
                  decoration: InputDecoration(
                    labelText: 'Capacité *',
                  ),
                  validator: (String value) {
                    if (value.isEmpty) return 'Doit être rempli.';
                    return null;
                  },
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: false,
                    signed: false,
                  ),
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

    var apiInstance = ClassroomApi();

    var classroomCreationRequest = ClassroomCreationRequest();

    classroomCreationRequest.name = nameController.text;
    classroomCreationRequest.capacity = int.parse(capacityController.text);

    try {
      var result = await apiInstance.classroomsPost(classroomCreationRequest);
      Navigator.pop(context, result);
    } catch (e) {
      print("Exception when calling ClassroomsApi->classroomsPost: $e\n");

      setState(() {
        enabled = true;
        message = getErrorMessageFromException(e);
      });
    }
  }
}
