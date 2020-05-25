import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scolendar/api_exception.dart';
import 'package:mobile_scolendar/components/autocomplete_field.dart';
import 'package:openapi/api.dart';

class CalendarEventCreateRoute extends StatefulWidget {
  static const ROUTE_NAME = "/event/create";

  @override
  _CalendarEventCreateRouteState createState() =>
      _CalendarEventCreateRouteState();
}

class _CalendarEventCreateRouteState extends State<CalendarEventCreateRoute> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool enabled = true;
  Classroom selectedClassroom;
  TeacherListResponseTeachers selectedTeacher;
  OccupancyType occupancyType = OccupancyType.cM_;
  DateTime dateTime = DateTime.now().add(Duration(days: 1));
  DateTime firstDate = DateTime.now();
  final TextEditingController durationHourController = TextEditingController();
  final TextEditingController durationMinuteController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();

  DateFormat dateFmt = DateFormat(DateFormat.YEAR_MONTH_WEEKDAY_DAY);
  DateFormat timeFmt = DateFormat(DateFormat.HOUR24_MINUTE);
  SubjectListResponseSubjects selectedSubject;
  String errorMessage;

  @override
  Widget build(BuildContext context) {
    //OccupanciesCreationRequest
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle occupation')),
      body: Container(
        height: double.maxFinite,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  AutoCompleteField(
                    enabled: enabled,
                    title: 'Salle *',
                    loadItems: (query, page) async {
                      final apiInstance = ClassroomApi();
                      final response = await apiInstance.classroomsGet(
                          query: query, page: page);
                      return response.classrooms;
                    },
                    itemBuilder: (context, classroom, onTap) {
                      return ListTile(
                        title: Text(classroom.name),
                        subtitle: Text('${classroom.capacity} élèves'),
                        onTap: onTap,
                      );
                    },
                    initialLabel: null,
                    onChange: (newClassroom) {
                      setState(() {
                        selectedClassroom = newClassroom;
                      });
                    },
                    getLabel: (classroom) => classroom?.name ?? "",
                    validationMessage: 'Une salle doit être sélectionnée',
                  ),
                  AutoCompleteField(
                    enabled: enabled,
                    title: 'Sujet *',
                    loadItems: (query, page) async {
                      final apiInstance = SubjectsApi();
                      final response = await apiInstance.subjectsGet(
                          query: query, page: page);
                      return response.subjects;
                    },
                    itemBuilder: (context, subject, onTap) {
                      return ListTile(
                        title: Text(subject.name),
                        onTap: onTap,
                      );
                    },
                    initialLabel: null,
                    onChange: (newSubject) {
                      setState(() {
                        selectedSubject = newSubject;
                      });
                    },
                    getLabel: (classroom) => classroom?.name ?? "",
                    validationMessage: 'Un sujet doit être sélectionné',
                  ),
                  // TODO : limit teacher to the one in the selected subject
                  AutoCompleteField(
                    enabled: enabled,
                    title: 'Enseignant *',
                    loadItems: (query, page) async {
                      final apiInstance = TeacherApi();
                      final response = await apiInstance.teachersGet(
                          query: query, page: page);
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
                      if (teacher == null) return null;
                      return '${teacher.firstName} ${teacher.lastName}';
                    },
                    validationMessage: 'Un enseignant doit être sélectionnée',
                  ),
                  SizedBox(height: 8.0),
                  DropdownButton(
                    hint: const Text('Grade'),
                    isExpanded: true,
                    items: [
                      DropdownMenuItem(
                          child: const Text('CM'), value: OccupancyType.cM_),
                      DropdownMenuItem(
                          child: const Text('TD'), value: OccupancyType.tD_),
                      DropdownMenuItem(
                          child: const Text('TP'), value: OccupancyType.tP_),
                      DropdownMenuItem(
                          child: const Text('Projet'),
                          value: OccupancyType.pROJ_),
                      DropdownMenuItem(
                          child: const Text('Administration'),
                          value: OccupancyType.aDM_),
                      DropdownMenuItem(
                          child: const Text('Externe'),
                          value: OccupancyType.eXT_),
                    ],
                    value: occupancyType,
                    onChanged: enabled
                        ? (newValue) {
                            setState(() {
                              occupancyType = newValue;
                            });
                          }
                        : null,
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dateFmt.format(dateTime)),
                          Text(timeFmt.format(dateTime)),
                        ],
                      ),
                      Spacer(),
                      RaisedButton(
                        child: Text('Select date'),
                        onPressed: () async {
                          final res = await showDatePicker(
                            context: context,
                            initialDate: dateTime,
                            firstDate: firstDate,
                            lastDate: firstDate.add(Duration(days: 365 * 100)),
                          );

                          if (res != null)
                            setState(() {
                              dateTime = res;
                            });
                        },
                      ),
                    ],
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    enabled: enabled,
                    controller: durationHourController,
                    decoration: InputDecoration(labelText: 'Durée (h)'),
                    validator: (value) {
                      if (value.length > 0) return null;
                      return "Veuillez rentrer une durée (heures).";
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    enabled: enabled,
                    controller: durationMinuteController,
                    decoration: InputDecoration(labelText: 'Durée (m)'),
                    validator: (value) {
                      if (value.length > 0) return null;
                      return "Veuillez rentrer une durée (minutes).";
                    },
                  ),
                  TextFormField(
                    enabled: enabled,
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Nom'),
                    validator: (value) {
                      if (value.length >= 3) return null;
                      return "Veuillez rentrer un nom de plus de 3 caractères.";
                    },
                  ),
                  SizedBox(height: 8.0),
                  if (errorMessage != null)
                    Text(
                      errorMessage,
                      style: TextStyle(color: Theme.of(context).errorColor),
                    ),
                  SizedBox(height: 8.0),
                  Container(
                    width: double.maxFinite,
                    child: RaisedButton(
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      onPressed: _onSubmit,
                      child: const Text('Créer'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmit() async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    setState(() {
      enabled = false;
    });

    var apiInstance = RoleProfessorApi();
    var occupanciesCreationRequest = OccupanciesCreationRequest();

    // int classroomId = null;
    occupanciesCreationRequest.classroomId = selectedClassroom.id;

    // int start = null;
    occupanciesCreationRequest.start = dateTime.millisecondsSinceEpoch ~/ 1000;

    // int end = null;
    int hours = int.parse(durationHourController.text);
    int minutes = int.parse(durationHourController.text);
    occupanciesCreationRequest.end =
        occupanciesCreationRequest.start + 60 * minutes + 3600 * hours;

    // String name = null;
    occupanciesCreationRequest.name = nameController.text;

    // OccupancyType occupancyType = null;
    occupanciesCreationRequest.occupancyType = occupancyType;

    //enum occupancyTypeEnum {  CM,  TD,  TP,  PROJ,  ADM,  EXT,  };{

    // int teacherId = null;
    occupanciesCreationRequest.teacherId = selectedTeacher.id;

    print(occupanciesCreationRequest);

    try {
      await apiInstance.subjectsIdOccupanciesPost(
          selectedSubject.id, occupanciesCreationRequest);
    } catch (e) {
      print("Exception when calling AuthApi->login: $e\n");

      setState(() {
        enabled = true;
        errorMessage = getErrorMessageFromException(e);
      });

      return;
    }
  }
}
