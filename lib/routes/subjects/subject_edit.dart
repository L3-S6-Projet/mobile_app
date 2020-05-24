import 'package:flutter/material.dart';
import 'package:mobile_scolendar/api_exception.dart';
import 'package:mobile_scolendar/components/autocomplete_field.dart';
import 'package:openapi/api.dart';

class SubjectEditRoute extends StatefulWidget {
  static const ROUTE_NAME = "/subject/update";

  final SubjectEditParameters args;

  const SubjectEditRoute({Key key, @required this.args}) : super(key: key);

  @override
  _SubjectEditRouteState createState() => _SubjectEditRouteState();
}

// TODO: ability to edit class (API does not allow it)

class _SubjectEditRouteState extends State<SubjectEditRoute> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  bool enabled = true;
  String message;

  SubjectResponseSubjectTeachers selectedTeacher;
  ClassWithId selectedClass;

  @override
  void initState() {
    super.initState();
    final subject = widget.args.subjectResponse.subject;
    nameController.text = subject.name;
  }

  @override
  Widget build(BuildContext context) {
    var initialTeacher;

    for (var teacher in widget.args.subjectResponse.subject.teachers) {
      if (teacher.inCharge) initialTeacher = teacher;
    }

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
                    validator: simpleThreeCharsValidator,
                  ),
                  AutoCompleteField(
                    enabled: enabled,
                    title: 'Enseignant responsable *',
                    loadItems: (query, page) async {
                      // TODO: this probably isn't the best way : no filtering, does paging work?
                      return widget.args.subjectResponse.subject.teachers;
                    },
                    itemBuilder: (context, teacher, onTap) {
                      return ListTile(
                        title: Text('${teacher.firstName} ${teacher.lastName}'),
                        onTap: onTap,
                      );
                    },
                    initialLabel:
                        '${initialTeacher.firstName} ${initialTeacher.lastName}',
                    allowEmpty: true,
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

    var subjectUpdateRequest = SubjectUpdateRequest();

    subjectUpdateRequest.name = nameController.text;

    if (selectedTeacher != null)
      subjectUpdateRequest.teacherInChargeId = selectedTeacher.id;

    try {
      await apiInstance.subjectsIdPut(widget.args.id, subjectUpdateRequest);
      Navigator.pop(context, true);
    } catch (e) {
      print("Exception when calling TeacherApi->teachersPost: $e\n");
      print(e);

      setState(() {
        enabled = true;
        message = getErrorMessageFromException(e);
      });
    }
  }
}

class SubjectEditParameters {
  final SubjectResponse subjectResponse;
  final int id;

  SubjectEditParameters(this.id, this.subjectResponse);
}
