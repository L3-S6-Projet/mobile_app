import 'package:flutter/material.dart';
import 'package:mobile_scolendar/api_exception.dart';
import 'package:mobile_scolendar/components/autocomplete_field.dart';
import 'package:openapi/api.dart';

class StudentCreateRoute extends StatefulWidget {
  static const ROUTE_NAME = "/student/create";

  @override
  _StudentCreateRouteState createState() => _StudentCreateRouteState();
}

class _StudentCreateRouteState extends State<StudentCreateRoute> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  bool enabled = true;
  String message;

  Rank rank = Rank.pROF_;

  ClassWithId selectedClass;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvel étudiant')),
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
                  controller: firstNameController,
                  decoration: InputDecoration(
                    labelText: 'Prénom *',
                  ),
                  validator: simpleThreeCharsValidator,
                ),
                TextFormField(
                  enabled: enabled,
                  controller: lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Nom *',
                  ),
                  validator: simpleThreeCharsValidator,
                ),
                AutoCompleteField(
                  enabled: enabled,
                  title: 'Classe *',
                  loadItems: (query, page) async {
                    final apiInstance = ClassesApi();
                    final response =
                        await apiInstance.classesGet(query: query, page: page);
                    return response.classes;
                  },
                  itemBuilder: (context, classWithId, onTap) {
                    return ListTile(
                      title: Text(classWithId.name),
                      onTap: onTap,
                    );
                  },
                  initialItem: null,
                  onChange: (newClass) {
                    setState(() {
                      selectedClass = newClass;
                    });
                  },
                  getLabel: (classWithId) => classWithId?.name ?? "",
                  validationMessage: 'Une classe doit être sélectionnée',
                ),
              ],
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

    var apiInstance = StudentsApi();

    var studentCreationRequest = StudentCreationRequest();

    studentCreationRequest.firstName = firstNameController.text;
    studentCreationRequest.lastName = lastNameController.text;
    studentCreationRequest.classId = selectedClass.id;

    try {
      var result = await apiInstance.studentsPost(studentCreationRequest);
      Navigator.pop(context, result);
    } catch (e) {
      print("Exception when calling StudentsApi->studentsPost: $e\n");

      setState(() {
        enabled = true;
        message = getErrorMessageFromException(e);
      });
    }
  }
}
