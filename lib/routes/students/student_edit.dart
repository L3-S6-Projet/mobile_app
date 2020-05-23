import 'package:flutter/material.dart';
import 'package:mobile_scolendar/api_exception.dart';
import 'package:openapi/api.dart';

class StudentEditRoute extends StatefulWidget {
  static const ROUTE_NAME = "/student/update";

  final StudentEditParameters args;

  const StudentEditRoute({Key key, @required this.args}) : super(key: key);

  @override
  _StudentEditRouteState createState() => _StudentEditRouteState();
}

// TODO : class id update, which is NOT returned by the API

class _StudentEditRouteState extends State<StudentEditRoute> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final passwordController = TextEditingController();
  bool enabled = true;
  String message;

  @override
  void initState() {
    super.initState();
    final student = widget.args.studentResponse.student;
    firstNameController.text = student.firstName;
    lastNameController.text = student.lastName;
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
                  TextFormField(
                    enabled: enabled,
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Nouveau mot de passe',
                    ),
                    obscureText: true,
                  )
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

    var apiInstance = StudentsApi();

    var studentUpdateRequest = StudentUpdateRequest();

    studentUpdateRequest.firstName = firstNameController.text;
    studentUpdateRequest.lastName = lastNameController.text;
    if (passwordController.text.length > 0)
      studentUpdateRequest.password = passwordController.text;

    try {
      await apiInstance.studentsIdPut(widget.args.id, studentUpdateRequest);
      Navigator.pop(context, true);
    } catch (e) {
      print("Exception when calling StudentApi->studentsPost: $e\n");
      print(e);

      setState(() {
        enabled = true;
        message = getErrorMessageFromException(e);
      });
    }
  }
}

class StudentEditParameters {
  final StudentResponse studentResponse;
  final int id;

  StudentEditParameters(this.id, this.studentResponse);
}
