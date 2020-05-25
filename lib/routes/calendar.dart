import 'package:flutter/material.dart';
import 'package:mobile_scolendar/auth.dart';
import 'package:mobile_scolendar/components/app_drawer.dart';
import 'package:mobile_scolendar/components/calendar/calendar.dart';
import 'package:mobile_scolendar/components/calendar/extras.dart';
import 'package:mobile_scolendar/components/calendar/view.dart';
import 'package:mobile_scolendar/routes/calendar_event_create.dart';
import 'package:openapi/api.dart';

class CalendarRoute extends StatefulWidget {
  static const ROUTE_NAME = '/calendar';

  @override
  _CalendarRouteState createState() => _CalendarRouteState();
}

class _CalendarRouteState extends State<CalendarRoute> {
  CalendarView view = CalendarView.MONTH;
  PageController pageController = Calendar.buildPageController();
  int todayReset = 0;

  Future<SuccessfulLoginResponse> loginResponseFuture;

  Future<SuccessfulLoginResponse> loadLoginResponse() async {
    final auth = await Auth.instance();
    return await auth.getResponse();
  }

  @override
  void initState() {
    super.initState();
    loginResponseFuture = loadLoginResponse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scolendar'),
        actions: appBarActions(
          context: context,
          callback: (newView) {
            setState(() {
              this.view = newView;
            });
          },
          onToday: () {
            setState(() {
              todayReset++;
            });
          },
        ),
      ),
      drawer: AppDrawer(),
      floatingActionButton: FutureBuilder(
          future: loginResponseFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done ||
                snapshot.hasError ||
                snapshot.data.user.kind != Role.tEA_) return Container();
            return FloatingActionButton(
              onPressed: () {
                // TODO: refresh on created + updated
                Navigator.pushNamed(
                    context, CalendarEventCreateRoute.ROUTE_NAME);
              },
              child: Icon(Icons.add, color: Colors.white),
            );
          }),
      body: Calendar(
        view: this.view,
        pageController: pageController,
        todayReset: todayReset,
        loadOccupancies: ({start, end, occupanciesPerDay}) async {
          final auth = await Auth.instance();
          final user = await auth.getResponse();

          if (user.user.kind == Role.aDM_) {
            final apiInstance = OccupanciesApi();

            return await apiInstance.occupanciesGet(
                start: start, end: end, occupanciesPerDay: occupanciesPerDay);
          } else if (user.user.kind == Role.tEA_) {
            final apiInstance = RoleProfessorApi();

            return await apiInstance.teachersIdOccupanciesGet(
              user.user.id,
              start: start,
              end: end,
              occupanciesPerDay: occupanciesPerDay,
            );
          } else {
            final apiInstance = RoleStudentApi();

            return await apiInstance.studentsIdOccupanciesGet(
              user.user.id,
              start: start,
              end: end,
              occupanciesPerDay: occupanciesPerDay,
            );
          }
        },
      ),
    );
  }
}
