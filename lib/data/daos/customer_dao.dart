import 'package:visits_app/data/models/customer.dart';
import 'package:visits_app/utils/sql/base_dao.dart';

class CustomerDao extends BaseDAO<Customer> {
  @override
  String get tableName => "customer";

  @override
  Customer fromMap(Map<String, dynamic> map) {
    return Customer.fromMap(map);
  }
}
