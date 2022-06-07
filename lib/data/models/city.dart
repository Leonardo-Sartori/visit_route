
import 'package:visits_app/data/models/country_state.dart';
import 'package:visits_app/utils/sql/entity.dart';

class City extends Entity {
  int? id;
  String? name;
  CountryState? countryState;

  City({this.id, this.name, this.countryState});

  City.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    countryState = CountryState(id: map['id']);
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['country_state'] = this.countryState;
    return data;
  }

  @override
  String toString() {
    return name!;
  }
}
