import 'package:visits_app/data/models/customer.dart';
import 'package:visits_app/data/models/visit.dart';
import 'package:visits_app/utils/sql/entity.dart';

class VisitCustomer extends Entity {
  int? id;
  Visit? visit;
  Customer? customer;

  VisitCustomer({this.id, this.visit, this.customer});

  VisitCustomer.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    visit = Visit(id: map['visit_id']);
    customer = Customer(id: map['customer_id']);
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['visit_id'] = this.visit!.id;
    data['customer_id'] = this.customer!.id;
    return data;
  }

  @override
  String toString() {
    return '';
  }
}
