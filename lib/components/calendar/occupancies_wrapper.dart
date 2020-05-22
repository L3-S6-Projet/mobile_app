import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scolendar/components/calendar/selected_date.dart';
import 'package:openapi/api.dart';

/// Simple wrapper around the occupancies response, wchich provides fast
/// access to a day, using a map.
class OccupanciesWrapper {
  final Occupancies occupancies;
  final Map<SimpleDate, List<OccupanciesOccupancies>> days;
  final DateFormat keyFmt = DateFormat('dd-MM-y');
  static const empty = <OccupanciesOccupancies>[];

  OccupanciesWrapper(this.occupancies) : days = _initializeDays(occupancies);

  static Map<SimpleDate, List<OccupanciesOccupancies>> _initializeDays(
      Occupancies occupancies) {
    var map = <SimpleDate, List<OccupanciesOccupancies>>{};

    for (var value in occupancies.days) {
      final parts = value.date.split('-');
      final key = SimpleDate(
        dayNumber: int.parse(parts[0]),
        monthNumber: int.parse(parts[1]),
        yearNumber: int.parse(parts[2]),
      );
      map[key] = value.occupancies;
    }

    return map;
  }

  List<OccupanciesOccupancies> forDay(SelectedDate date) {
    var key = SimpleDate(
      yearNumber: date.year,
      monthNumber: date.month,
      dayNumber: date.day,
    );
    return days[key] ?? empty;
  }
}

class SimpleDate extends Equatable {
  final int yearNumber, monthNumber, dayNumber;

  const SimpleDate(
      {@required this.yearNumber,
      @required this.monthNumber,
      @required this.dayNumber});

  @override
  List<Object> get props => [yearNumber, monthNumber, dayNumber];
}
