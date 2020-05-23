import 'package:flutter/material.dart';
import 'package:mobile_scolendar/api_exception.dart';
import 'package:openapi/api.dart';

class TeacherCreateRoute extends StatefulWidget {
  static const ROUTE_NAME = "/teacher/create";

  @override
  _TeacherCreateRouteState createState() => _TeacherCreateRouteState();
}

class _TeacherCreateRouteState extends State<TeacherCreateRoute> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  bool enabled = true;
  String message;

  Rank rank = Rank.pROF_;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvel enseignant')),
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
                TextFormField(
                  enabled: enabled,
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                TextFormField(
                  enabled: enabled,
                  controller: phoneNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Phone number',
                  ),
                ),
                SizedBox(height: 8.0),
                DropdownButton(
                  hint: const Text('Grade'),
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                        child: const Text('Maître de conférences'),
                        value: Rank.mACO_),
                    DropdownMenuItem(
                        child: const Text('Professeur'), value: Rank.pROF_),
                    DropdownMenuItem(
                        child: const Text('PRAG'), value: Rank.pRAG_),
                    DropdownMenuItem(
                        child: const Text('ATER'), value: Rank.aTER_),
                    DropdownMenuItem(
                        child: const Text('PAST'), value: Rank.pAST_),
                    DropdownMenuItem(
                        child: const Text('Moniteur'), value: Rank.mONI_),
                  ],
                  value: rank,
                  onChanged: enabled
                      ? (newValue) {
                          setState(() {
                            rank = newValue;
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

    var apiInstance = TeacherApi();

    var teacherCreationRequest = TeacherCreationRequest();

    teacherCreationRequest.firstName = firstNameController.text;
    teacherCreationRequest.lastName = lastNameController.text;
    if (emailController.text.length > 0)
      teacherCreationRequest.email = emailController.text;
    if (phoneNumberController.text.length > 0)
      teacherCreationRequest.phoneNumber = phoneNumberController.text;
    teacherCreationRequest.rank = rank;

    try {
      var result = await apiInstance.teachersPost(teacherCreationRequest);
      Navigator.pop(context, result);
    } catch (e) {
      print("Exception when calling TeacherApi->teachersPost: $e\n");

      setState(() {
        enabled = true;
        message = getErrorMessageFromException(e);
      });
    }
  }
}
