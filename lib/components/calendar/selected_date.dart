import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scolendar/components/calendar/occupancies_wrapper.dart';
import 'package:openapi/api.dart';

/// Extended date object, which contains the algorithms required
/// for the calendar.
class SelectedDate {
  final DateTime date;

  SelectedDate(
      {@required dayNumber, @required monthNumber, @required yearNumber})
      : date = DateTime(yearNumber, monthNumber, dayNumber);

  SelectedDate._fromDate(this.date);

  static SelectedDate today() {
    var now = new DateTime.now();
    return SelectedDate._fromDate(now);
  }

  int get year => date.year;
  int get month => date.month;
  int get day => date.day;
  int get hour => date.hour;
  int get minute => date.minute;
  int get second => date.second;
  int get millisecond => date.millisecond;
  int get microsecond => date.microsecond;

  SelectedDate previousMonth() {
    return addMonths(-1);
  }

  SelectedDate nextMonth() {
    return addMonths(1);
  }

  SelectedDate previousWeek() {
    var newDate = new DateTime(date.year, date.month, date.day - 7);
    return SelectedDate._fromDate(newDate);
  }

  SelectedDate nextWeek() {
    var newDate = new DateTime(date.year, date.month, date.day + 7);
    return SelectedDate._fromDate(newDate);
  }

  SelectedDate previousDay() {
    var newDate = new DateTime(date.year, date.month, date.day - 1);
    return SelectedDate._fromDate(newDate);
  }

  SelectedDate nextDay() {
    var newDate = new DateTime(date.year, date.month, date.day + 1);
    return SelectedDate._fromDate(newDate);
  }

  SelectedDate addMonths(int months) {
    var newDate = new DateTime(date.year, date.month + months, date.day);
    return SelectedDate._fromDate(newDate);
  }

  SelectedDate addDays(int days) {
    var newDate = new DateTime(date.year, date.month, date.day + days);
    return SelectedDate._fromDate(newDate);
  }

  SelectedDate add(int months, int days) {
    var newDate = new DateTime(date.year, date.month + months, date.day + days);
    return SelectedDate._fromDate(newDate);
  }

  List<SelectedDate> days() {
    final n = lastDayOfMonth(date).day;

    final days = <SelectedDate>[];

    final previousMonthN = lastDayOfMonth(previousMonth().date).day;
    final previousMonthToAdd = DateTime(
          this.year,
          this.month,
          1,
        ).weekday -
        1;

    final lastMonth = previousMonth();
    final nextMonth = this.nextMonth();

    for (var i = previousMonthN - previousMonthToAdd + 1;
        i <= previousMonthN;
        i++) {
      days.add(SelectedDate(
        yearNumber: lastMonth.date.year,
        monthNumber: lastMonth.date.month,
        dayNumber: i,
      ));
    }

    for (var i = 1; i <= n; i++)
      days.add(SelectedDate(
        yearNumber: this.year,
        monthNumber: this.month,
        dayNumber: i,
      ));

    var i = 1;

    while (days.length < 7 * 5) {
      days.add(SelectedDate(
        yearNumber: nextMonth.date.year,
        monthNumber: nextMonth.date.month,
        dayNumber: i,
      ));

      i += 1;
    }

    return days.sublist(0, 7 * 5);
  }

  List<SelectedDate> week() {
    var date = clone().date;

    final weekDay = DateTime(
          this.year,
          this.month,
          this.day,
        ).weekday -
        1;

    date = DateTime(date.year, date.month, date.day - weekDay);

    final days = <SelectedDate>[];

    for (var i = 0; i < 7; i++) {
      days.add(SelectedDate(
        yearNumber: date.year,
        monthNumber: date.month,
        dayNumber: date.day,
      ));

      date = date.add(Duration(days: 1));
    }

    return days;
  }

  SelectedDate clone() {
    DateTime clonedDate = DateTime(
      this.date.year,
      this.date.month,
      this.date.day,
      this.date.hour,
      this.date.minute,
      this.date.second,
      this.date.millisecond,
      this.date.microsecond,
    );

    return SelectedDate._fromDate(clonedDate);
  }

  @override
  String toString() {
    return this.date.toString();
  }

  int weekNumber() {
    int daysToAdd = DateTime.thursday - date.weekday;
    DateTime thursdayDate = daysToAdd > 0
        ? date.add(Duration(days: daysToAdd))
        : date.subtract(Duration(days: daysToAdd.abs()));
    int dayOfYearThursday = dayOfYear(thursdayDate);
    return 1 + ((dayOfYearThursday - 1) / 7).floor();
  }

  static int dayOfYear(DateTime date) {
    return date.difference(DateTime(date.year, 1, 1)).inDays;
  }
}

/// The last day of a given month
/// From the date_utils package.
DateTime lastDayOfMonth(DateTime month) {
  var beginningNextMonth = (month.month < 12)
      ? new DateTime(month.year, month.month + 1, 1)
      : new DateTime(month.year + 1, 1, 1);
  return beginningNextMonth.subtract(new Duration(days: 1));
}
