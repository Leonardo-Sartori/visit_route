import 'package:visits_app/data/models/customer.dart';
import 'package:visits_app/utils/sql/entity.dart';

class Visit extends Entity {
  int? id;
  DateTime? initDate;
  DateTime? endDate;
  List<Customer>? customers = [];

  Visit({
    this.id,
    this.initDate,
    this.endDate,
    this.customers,
  });

  Visit.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    initDate = DateTime.parse(map['init_date']);
    endDate = DateTime.parse(map['end_date']);
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['init_date'] = this.initDate.toString();
    data['end_date'] = this.endDate.toString();
    return data;
  }

  @override
  String toString() {
    return '';
  }
}
