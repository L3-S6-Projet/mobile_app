import 'package:mobile_scolendar/routes/calendar.dart';
import 'package:mobile_scolendar/routes/home.dart';
import 'package:mobile_scolendar/routes/login.dart';
import 'package:openapi/api.dart';

String initialRouteName(SuccessfulLoginResponse loginResponse) {
  final kind = loginResponse?.user?.kind;

  if (loginResponse == null) {
    return LoginRoute.ROUTE_NAME;
  } else if (kind == Role.sTU_ || kind == Role.tEA_) {
    return HomeRoute.ROUTE_NAME;
  }

  return CalendarRoute.ROUTE_NAME;
}
