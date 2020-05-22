enum CalendarView {
  DAY,
  WEEK,
  MONTH,
}

class CalendarViewHelper {
  static CalendarView getByValue(String value) => const {
        'day': CalendarView.DAY,
        'week': CalendarView.WEEK,
        'month': CalendarView.MONTH,
      }[value];
}

extension CalendarViewMembers on CalendarView {
  String get value => const {
        CalendarView.DAY: 'day',
        CalendarView.WEEK: 'week',
        CalendarView.MONTH: 'month',
      }[this];
}
