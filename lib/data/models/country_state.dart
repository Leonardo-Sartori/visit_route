import 'package:visits_app/utils/sql/entity.dart';

class CountryState extends Entity {
  int? id;
  String? name;
  String? code;

  CountryState({this.id, this.name, this.code});

  CountryState.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    code = map['code'];
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['code'] = this.code;
    return data;
  }

  @override
  String toString() {
    return name!;
  }
}
