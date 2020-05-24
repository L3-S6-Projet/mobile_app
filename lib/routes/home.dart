import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scolendar/auth.dart';
import 'package:mobile_scolendar/components/app_drawer.dart';
import 'package:openapi/api.dart';
import 'package:mobile_scolendar/utils.dart';

class HomeRoute extends StatefulWidget {
  static const ROUTE_NAME = "Home";

  @override
  _HomeRouteState createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  Future<ProfileRecentModifications> recentModificationsFuture;
  Future<OccupanciesOccupancies> nextOccupancyFuture;

  final DateFormat modificationFmt = DateFormat('dd/MM HH:mm');
  final DateFormat hourFmt = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    recentModificationsFuture = loadRecentModifications();
    nextOccupancyFuture = nextOccupancy();
  }

  Future<ProfileRecentModifications> loadRecentModifications() async {
    final auth = await Auth.instance();
    final user = await auth.getResponse();
    var apiInstance;
    if (user.user.kind == Role.sTU_)
      apiInstance = RoleStudentApi();
    else
      apiInstance = RoleProfessorApi();
    return apiInstance.profileLastOccupanciesModificationsGet();
  }

  Future<OccupanciesOccupancies> nextOccupancy() async {
    final auth = await Auth.instance();
    final user = await auth.getResponse();
    var results;
    final start = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final end = start + Duration(days: 7).inSeconds;

    if (user.user.kind == Role.sTU_) {
      final apiInstance = StudentsApi();
      results = await apiInstance.studentsIdOccupanciesGet(user.user.id,
          start: start, end: end, occupanciesPerDay: 1);
    } else {
      final apiInstance = TeacherApi();
      results = await apiInstance.teachersIdOccupanciesGet(user.user.id,
          start: start, end: end, occupanciesPerDay: 1);
    }

    if (results == null || results.days.length <= 0) return null;

    final allOccupancies = <OccupanciesOccupancies>[];

    for (var day in results.days) {
      allOccupancies.addAll(day.occupancies);
    }

    return allOccupancies.fold(null, (best, el) {
      if (best == null || (el.start < (best as OccupanciesOccupancies).start))
        return el;

      return best;
    });

    /*return results.days.fold(null, (best, elements) {
      final elementsFold = elements.occupancies.fold(null, (best, element) {
        if (best == null || element.start < best.start) return element;
        return best;
      });

      if (best == null ||
          (elementsFold != null &&
              elementsFold.start < (best as OccupanciesOccupancies).start))
        return elementsFold;

      return best;
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scolendar')),
      drawer: AppDrawer(),
      body: _buildHome(),
    );
  }

  Widget _buildHome() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder(
            future: nextOccupancyFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(child: CircularProgressIndicator());
              }

              // TODO
              if (snapshot.hasError) {
                print(snapshot.error);
                return Center(
                  child: Text('Erreur'),
                );
              }

              String paragraph;
              OccupanciesOccupancies nextOccupancy = snapshot.data;

              if (nextOccupancy == null) {
                paragraph = "Aucune occupation dans les 7 prochains jours.";
              } else {
                final start = DateTime.fromMillisecondsSinceEpoch(
                    nextOccupancy.start * 1000,
                    isUtc: false);
                final end = DateTime.fromMillisecondsSinceEpoch(
                    nextOccupancy.end * 1000,
                    isUtc: false);
                final diff = start.difference(DateTime.now());
                var diffText;
                if (diff.inHours < 1) {
                  diffText = '${diff.inMinutes} minutes';
                } else if (diff.inDays < 1) {
                  diffText =
                      '${diff.inHours} heures et ${diff.inMinutes - (diff.inHours * 60)} minutes';
                } else {
                  diffText = '${diff.inDays} jours';
                }
                final startFmt = hourFmt.format(start);
                final endFmt = hourFmt.format(end);

                // TODO: rich text with bold
                // TODO: remove "avec $teacher" if the logged user is a teacher
                paragraph =
                    "Votre prochain cours est dans $diffText en ${nextOccupancy.classroomName} de $startFmt à $endFmt.\n\nC’est un cours de ${nextOccupancy.subjectName} : ${nextOccupancy.name} avec ${nextOccupancy.teacherName}.";
              }

              return Container(
                width: double.maxFinite,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    // TODO
                    child: Text(paragraph),
                  ),
                ),
              );
            },
          ),
          _buildLastModificationsCard(context),
          Container(
            width: double.maxFinite,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Progrès',
                        style: Theme.of(context).textTheme.subtitle2),
                    SizedBox(height: 8.0),
                    // TODO : real values
                    Text('Vous avez atteint 50% de votre année.'),
                    LinearProgressIndicator(
                      value: .5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).accentColor),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastModificationsCard(BuildContext context) {
    return Container(
      width: double.maxFinite,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dernières modifications',
                  style: Theme.of(context).textTheme.subtitle2),
              SizedBox(height: 8.0),
              FutureBuilder(
                  future: recentModificationsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Center(child: CircularProgressIndicator());
                    }

                    // TODO
                    if (snapshot.hasError) {
                      print(snapshot.error);
                      return Center(
                        child: Text('Erreur'),
                      );
                    }

                    final modifications =
                        (snapshot.data as ProfileRecentModifications)
                            .modifications;

                    if (modifications == null || modifications.length == 0) {
                      return Center(
                          child: Text('Aucune modification récente.'));
                    }

                    return Column(
                      children: modifications.map((modification) {
                        String subtitle = "";

                        if (modification.modificationType == "CREATE") {
                          final creationDate =
                              DateTime.fromMillisecondsSinceEpoch(
                                  modification.occupancy.occupancyStart * 1000,
                                  isUtc: false);

                          subtitle =
                              "Nouveau cours le ${modificationFmt.format(creationDate)}.";
                        } else if (modification.modificationType == "EDIT") {
                          final date = DateTime.fromMillisecondsSinceEpoch(
                              modification.occupancy.occupancyStart * 1000,
                              isUtc: false);

                          subtitle =
                              "Le cours du ${modificationFmt.format(date)} à été modifié.";
                        } else {
                          final deletedDate =
                              DateTime.fromMillisecondsSinceEpoch(
                                  modification
                                          .occupancy.previousOccupancyStart *
                                      1000,
                                  isUtc: false);

                          subtitle =
                              "Le cours du ${modificationFmt.format(deletedDate)} à été supprimé";
                        }

                        final modificationDate =
                            DateTime.fromMillisecondsSinceEpoch(
                                modification.modificationTimestamp * 1000,
                                isUtc: false);

                        return ListTile(
                          title: Text(
                              '${modification.occupancy.subjectName.capitalize()}'),
                          subtitle: Text(subtitle),
                          trailing:
                              Text(modificationFmt.format(modificationDate)),
                        );
                      }).toList(),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
