import 'package:flutter/material.dart';
import 'package:mobile_scolendar/api_exception.dart';
import 'package:mobile_scolendar/components/autocomplete_field.dart';
import 'package:openapi/api.dart';

class SubjectCreateRoute extends StatefulWidget {
  static const ROUTE_NAME = "/subject/create";

  @override
  _SubjectCreateRouteState createState() => _SubjectCreateRouteState();
}

class _SubjectCreateRouteState extends State<SubjectCreateRoute> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  bool enabled = true;
  String message;

  ClassWithId selectedClass;
  TeacherListResponseTeachers selectedTeacher;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle unité d\'enseignement')),
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
                  initialLabel: null,
                  onChange: (newClass) {
                    setState(() {
                      selectedClass = newClass;
                    });
                  },
                  getLabel: (classWithId) => classWithId?.name ?? "",
                  validationMessage: 'Une classe doit être sélectionnée',
                ),
                AutoCompleteField(
                  enabled: enabled,
                  title: 'Enseignant responsable *',
                  loadItems: (query, page) async {
                    final apiInstance = TeacherApi();
                    final response =
                        await apiInstance.teachersGet(query: query, page: page);
                    return response.teachers;
                  },
                  itemBuilder: (context, teacher, onTap) {
                    return ListTile(
                      title: Text('${teacher.firstName} ${teacher.lastName}'),
                      onTap: onTap,
                    );
                  },
                  initialLabel: null,
                  onChange: (newTeacher) {
                    setState(() {
                      selectedTeacher = newTeacher;
                    });
                  },
                  getLabel: (teacher) {
                    if (teacher == null) return "";
                    return '${teacher.firstName} ${teacher.lastName}';
                  },
                  validationMessage:
                      'Un enseignant responsable doit être sélectionnée',
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

    var apiInstance = SubjectsApi();

    var subject = Subject();

    subject.name = nameController.text;
    subject.classId = selectedClass.id;
    subject.teacherInChargeId = selectedTeacher.id;

    try {
      var result = await apiInstance.subjectsPost(subject);
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
