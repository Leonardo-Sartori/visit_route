import 'package:visits_app/data/models/visit_customer.dart';
import 'package:visits_app/utils/sql/base_dao.dart';

class VisitCustomerDao extends BaseDAO<VisitCustomer> {
  @override
  String get tableName => "visit_customer";

  @override
  VisitCustomer fromMap(Map<String, dynamic> map) {
    return VisitCustomer.fromMap(map);
  }
}
