import 'package:flutter/material.dart';
import 'package:mobile_scolendar/components/calendar/calendar.dart';
import 'package:mobile_scolendar/components/calendar/view.dart';

List<Widget> appBarActions(BuildContext context,
    Function(CalendarView) callback, PageController pageController) {
  return [
    Tooltip(
      message: "Aujourd'hui",
      child: IconButton(
        icon: Icon(Icons.today),
        onPressed: () {
          /*pageController.animateToPage(OFFSET,
              duration: Duration(milliseconds: 400), curve: Curves.easeInOut);*/

          // TODO: this does not work properly
          pageController.jumpToPage(OFFSET);
        },
      ),
    ),
    Tooltip(
      message: "Changer la vue",
      child: IconButton(
        icon: Icon(Icons.apps),
        onPressed: () {
          selectView(context, callback);
        },
      ),
    )
  ];
}

void selectView(BuildContext context, Function(CalendarView) callback) async {
  final newView = await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(title: const Text('Choix de la vue'), children: [
          SimpleDialogOption(
            child: const Text('Jour'),
            onPressed: () {
              Navigator.pop(context, CalendarView.DAY);
            },
          ),
          SimpleDialogOption(
            child: const Text('Semaine'),
            onPressed: () {
              Navigator.pop(context, CalendarView.WEEK);
            },
          ),
          SimpleDialogOption(
            child: const Text('Mois'),
            onPressed: () {
              Navigator.pop(context, CalendarView.MONTH);
            },
          )
        ]);
      });

  if (newView != null) callback(newView);
}
