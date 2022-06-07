import 'package:visits_app/data/models/visit.dart';
import 'package:visits_app/utils/sql/base_dao.dart';

class VisitDao extends BaseDAO<Visit> {
  @override
  String get tableName => "visit";

  @override
  Visit fromMap(Map<String, dynamic> map) {
    return Visit.fromMap(map);
  }
}
