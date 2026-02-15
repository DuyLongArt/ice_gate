import 'package:drift/drift.dart';
import 'package:signals/signals.dart';
import 'package:ice_shield/data_layer/DataSources/local_database/Database.dart';
import 'dart:async';

class SocialBlock {
  final relationships = listSignal<RelationshipData>([]);
  final people = listSignal<PersonData>([]);

  StreamSubscription? _relSub;
  StreamSubscription? _peopleSub;
  late SocialDAO _dao;
  late int _personId;

  void init(SocialDAO dao, int personId) {
    _dao = dao;
    _personId = personId;

    _relSub?.cancel();
    _relSub = _dao.watchRelationships(personId).listen((data) {
      relationships.value = data;
    });

    _peopleSub?.cancel();
    _peopleSub = _dao.watchAllPeople().listen((data) {
      people.value = data;
    });
  }

  Future<void> addRelationship({
    required int relatedPersonID,
    required RelationshipType type,
    String? label,
  }) async {
    await _dao.createRelationship(
      RelationshipsTableCompanion.insert(
        personID: _personId,
        relatedPersonID: relatedPersonID,
        relationType: Value(type),
        label: Value(label),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> addPerson({
    required String firstName,
    String? lastName,
    String? gender,
    String? phoneNumber,
  }) async {
    return await _dao.createPerson(
      PersonsTableCompanion.insert(
        firstName: firstName,
        lastName: Value(lastName),
        gender: Value(gender),
        phoneNumber: Value(phoneNumber),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  void dispose() {
    _relSub?.cancel();
    _peopleSub?.cancel();
  }
}
