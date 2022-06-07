import 'package:enum_to_string/enum_to_string.dart';
import 'package:visits_app/data/enums/visit_tag.dart';
import 'package:visits_app/data/models/city.dart';
import 'package:visits_app/data/models/country_state.dart';
import 'package:visits_app/utils/sql/entity.dart';

class Customer extends Entity {
  int? id;
  String? name;
  String? cpfCnpj;
  String? logradouro;
  int? number;
  String? cep;
  City? city;
  CountryState? countryState;
  String? phone;
  VisitTags? tag;
  
  Customer({
    this.id,
    this.name,
    this.cpfCnpj,
    this.logradouro,
    this.number,
    this.cep,
    this.phone,
    this.city,
    this.countryState,
    this.tag,
  });

  Customer.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    logradouro = map['logradouro'];
    number = map['number'];
    cep = map['cep'];
    city = City(id: map['city_id']);
    countryState = CountryState(id: map['country_state_id']);
    phone = map['phone'];
    tag = EnumToString.fromString(VisitTags.values, map['tag']);
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['logradouro'] = this.logradouro;
    data['number'] = this.number;
    data['cep'] = this.cep;
    data['city_id'] = this.city!.id;
    data['country_state_id'] = this.countryState!.id;
    data['phone'] = this.phone;
    data["tag"] = EnumToString.convertToString(this.tag != null ? this.tag : VisitTags.visitMade);
    
    return data;
  }

  @override
  String toString() {
    return name!;
  }
}
