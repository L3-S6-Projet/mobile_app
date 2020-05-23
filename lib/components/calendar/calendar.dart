import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scolendar/auth.dart';
import 'package:mobile_scolendar/components/calendar/occupancies_wrapper.dart';
import 'package:mobile_scolendar/components/calendar/selected_date.dart';
import 'package:mobile_scolendar/components/calendar/view.dart';
import 'package:mobile_scolendar/components/calendar/week.dart';
import 'package:openapi/api.dart';

import 'month.dart';

// TODO
const OFFSET = 1000;

class Calendar extends StatefulWidget {
  final CalendarView view;
  final PageController pageController;
  final int todayReset;
  final Future<Occupancies> Function(
      {int start, int end, int occupanciesPerDay}) loadOccupancies;

  static buildPageController() {
    return PageController(initialPage: OFFSET);
  }

  Calendar({
    @required this.view,
    @required this.pageController,
    @required this.todayReset,
    @required this.loadOccupancies,
  });

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  Future<dynamic> loadOccupanciesFuture;
  SelectedDate selectedDate = SelectedDate.today();
  int lastPage = OFFSET;
  int lastTodayReset = 0;

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // WARNING: this is probably really bad code
    if (widget.todayReset > lastTodayReset) {
      setState(() {
        lastTodayReset = widget.todayReset;
        selectedDate = SelectedDate.today();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadOccupanciesFuture = this.loadOccupancies();
  }

  loadOccupancies() async {
    return OccupanciesWrapper(await widget.loadOccupancies());
  }

  Widget buildView(
      BuildContext context, int position, OccupanciesWrapper occupancies) {
    int offset = position - lastPage;
    var tabDate;

    if (widget.view == CalendarView.MONTH) {
      tabDate = selectedDate.addMonths(offset);
    } else if (widget.view == CalendarView.WEEK) {
      tabDate = selectedDate.addDays(7 * offset);
    } else {
      tabDate = selectedDate.addDays(offset);
    }

    switch (this.widget.view) {
      case CalendarView.MONTH:
        return MonthView(
          occupancies: occupancies,
          selectedDate: tabDate,
        );
        break;
      case CalendarView.WEEK:
        return HourlyView(
          occupancies: occupancies,
          selectedDate: tabDate,
          days: 7,
        );
        break;
      case CalendarView.DAY:
        return HourlyView(
          occupancies: occupancies,
          selectedDate: tabDate,
          days: 1,
        );
        break;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadOccupanciesFuture,
      builder: (context, snapshot) {
        // TODO: if snapshot hasError

        return Column(
          children: [
            Container(
              child: ViewSelector(
                selectedDate: selectedDate,
                pageController: widget.pageController,
                calendarView: widget.view,
              ),
              decoration: BoxDecoration(
                  border: Border(
                bottom: (widget.view == CalendarView.MONTH)
                    ? BorderSide(
                        width: 1, color: Theme.of(context).dividerColor)
                    : BorderSide.none,
              )),
            ),
            Expanded(
                child: PageView.builder(
              controller: widget.pageController,
              itemBuilder: (ctx, index) => buildView(ctx, index, snapshot.data),
              onPageChanged: (page) {
                setState(() {
                  int direction = (lastPage - page) > 0 ? -1 : 1;
                  if (widget.view == CalendarView.MONTH)
                    selectedDate = selectedDate.addMonths(direction);
                  else if (widget.view == CalendarView.WEEK)
                    selectedDate = selectedDate.addDays(7 * direction);
                  else
                    selectedDate = selectedDate.addDays(direction);
                  lastPage = page;
                });
              },
            ))
          ],
        );
      },
    );
  }
}

class ViewSelector extends StatelessWidget {
  final SelectedDate selectedDate;
  final DateFormat monthFmt = DateFormat('MMMM');
  final DateFormat dayFmt = DateFormat('E dd');
  final PageController pageController;
  final CalendarView calendarView;

  ViewSelector({
    @required this.selectedDate,
    @required this.pageController,
    @required this.calendarView,
  });

  static getWeekNumber() {}

  Widget _buildMiddle(BuildContext context) {
    Widget top;
    Widget bottom;

    switch (this.calendarView) {
      case CalendarView.MONTH:
        top = Text(
          monthFmt.format(selectedDate.date),
          style: TextStyle(fontSize: 24),
        );
        bottom = Text(selectedDate.year.toString(),
            style: TextStyle(
                fontSize: 18.0,
                color: Theme.of(context).textTheme.subtitle2.color));
        break;
      case CalendarView.WEEK:
        final weekNumber = this.selectedDate.weekNumber();
        top = Text(
          'Semaine n°$weekNumber',
          style: TextStyle(fontSize: 24),
        );
        bottom = Text(
            monthFmt.format(selectedDate.date) +
                ' ' +
                selectedDate.year.toString(),
            style: TextStyle(
                fontSize: 18.0,
                color: Theme.of(context).textTheme.subtitle2.color));
        break;
      case CalendarView.DAY:
        top = Text(
          dayFmt.format(selectedDate.date),
          style: TextStyle(fontSize: 24),
        );
        bottom = Text(
            monthFmt.format(selectedDate.date) +
                ' ' +
                selectedDate.year.toString(),
            style: TextStyle(
                fontSize: 18.0,
                color: Theme.of(context).textTheme.subtitle2.color));
        break;
    }

    return Column(children: [top, bottom]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                pageController.previousPage(
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeInOut);
              },
              icon: const Icon(Icons.chevron_left)),
          Spacer(),
          _buildMiddle(context),
          Spacer(),
          IconButton(
              onPressed: () {
                pageController.nextPage(
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeInOut);
              },
              icon: const Icon(Icons.chevron_right)),
        ],
      ),
    );
  }
}
