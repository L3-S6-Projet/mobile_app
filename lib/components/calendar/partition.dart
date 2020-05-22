import 'dart:math';

import 'package:openapi/api.dart';

class Partition {
  final Map<int, int> parts = {};
  final Map<int, int> widths = {};

  Partition(List<OccupanciesOccupancies> occupancies) {
    _initialize(occupancies);
  }

  _initialize(List<OccupanciesOccupancies> occupancies) {
    final overlapping = buildOverlappingFunction(occupancies);
    final ids = occupancies.map((e) => e.id).toList();
    _partition(ids, overlapping);
  }

  _partition(List<int> ids, bool Function(int, int) overlapping) {
    final groups = _createGroups(ids, overlapping);

    for (var group in groups) {
      final groupPartition = partitionGroup(group, overlapping);
      parts.addAll(groupPartition[0]);
      widths.addAll(groupPartition[1]);
    }
  }

  List<List<int>> _createGroups(
      List<int> ids, bool Function(int, int) overlapping) {
    final groups = <List<int>>[];

    for (var id in ids) groups.add([id]);

    void fusionGroups(indexA, indexB) {
      final a = groups[indexA];
      final b = groups.removeAt(indexB);
      a.addAll(b);
    }

    bool shouldFusion(groupA, groupB) {
      for (var elA in groupA) {
        for (var elB in groupB) {
          if (overlapping(elA, elB)) return true;
        }
      }

      return false;
    }

    var shouldContinue = true;

    while (shouldContinue) {
      shouldContinue = false;

      for (var i = 0; i < groups.length; i++) {
        final groupA = groups[i];

        for (var j = 0; j < groups.length; j++) {
          final groupB = groups[j];
          if (i == j) continue;

          if (shouldFusion(groupA, groupB)) {
            fusionGroups(i, j);
            shouldContinue = true;
            break;
          }
        }

        if (shouldContinue) break;
      }
    }

    return groups;
  }

  partitionGroup(List<int> ids, bool Function(int, int) overlapping) {
    final groupParts = <int, int>{};

    for (var id in ids) groupParts[id] = 1;

    var numberOfColumns = 1;

    bool step() {
      for (var first in ids) {
        for (var second in ids) {
          final eventsOverlap = overlapping(first, second);
          final eventsAreInSameColumn = groupParts[first] == groupParts[second];

          if (eventsOverlap && eventsAreInSameColumn) {
            groupParts[second] += 1;
            numberOfColumns = max(numberOfColumns, groupParts[second]);
            return true;
          }
        }
      }

      return false;
    }

    do {} while (step());

    final groupWidths = <int, int>{};

    for (var i = 0; i < ids.length; i++) {
      groupWidths[ids[i]] = numberOfColumns;
    }

    return [groupParts, groupWidths];
  }
}

bool Function(int, int) buildOverlappingFunction(
    List<OccupanciesOccupancies> occupancies) {
  String buildKey(indexA, indexB) {
    final key = [indexA, indexB];
    key.sort();
    return key.toString();
  }

  bool overlaps(OccupanciesOccupancies eventA, OccupanciesOccupancies eventB) {
    return (eventA.start < eventB.end) && (eventA.end > eventB.start);
  }

  final overlapping = Set();

  for (var eventA in occupancies) {
    for (var eventB in occupancies) {
      if (eventA.id != eventB.id && overlaps(eventA, eventB))
        overlapping.add(buildKey(eventA.id, eventB.id));
    }
  }

  return (int firstID, int secondID) =>
      overlapping.contains(buildKey(firstID, secondID));
}
