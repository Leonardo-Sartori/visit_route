import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/services.dart';
import 'package:visits_app/data/daos/customer_dao.dart';
import 'package:visits_app/data/enums/visit_tag.dart';
import 'package:visits_app/data/models/city.dart';
import 'package:visits_app/data/models/country_state.dart';
import 'package:visits_app/data/models/customer.dart';
import 'package:visits_app/utils/easy_loading.dart';
import 'package:visits_app/utils/nav.dart';
import 'package:visits_app/widgets/app_textfield.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

typedef CustomersValue = Customer Function(Customer);

class CustomerFormPage extends StatefulWidget {
  final CustomersValue? callbackCustomers;

  const CustomerFormPage({Key? key, this.callbackCustomers}) : super(key: key);

  @override
  _CustomerFormPageState createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Customer _customer = Customer();
  String? allCities;
  List<City> cities = [];
  List<CountryState> countryStates = [];

  final customerDao = CustomerDao();

  final TextEditingController _tName = TextEditingController();
  final TextEditingController _tCpfCnpj = TextEditingController();
  final TextEditingController _tLogradouro = TextEditingController();
  final TextEditingController _tNumber = TextEditingController();
  final TextEditingController _tCep = TextEditingController();
  final TextEditingController _tPhone = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getDataCountryState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Novo Cliente"),
        actions: [
          IconButton(onPressed: _onClickSave, icon: const Icon(Icons.check))
        ],
      ),
      body: Form(
          key: _formKey,
          child: Container(padding: const EdgeInsets.all(16), child: _body())),
    );
  }

  Future<void> _onClickSave() async {
    bool formOk = _formKey.currentState!.validate();

    if (!formOk) {
      return;
    }

    showLoading("Salvando ...");

    Customer customer = Customer(
      name: _tName.text,
      cpfCnpj: _tCpfCnpj.text,
      logradouro: _tLogradouro.text,
      number: int.parse(_tNumber.text),
      cep: _tCep.text,
      phone: _tPhone.text,
      city: _customer.city,
      countryState: _customer.countryState,
      tag: VisitTags.visitMade,
    );

    int customerId = await customerDao.save(customer);
    customer.id = customerId;
    dismiss();
    showSuccess("Salvo com sucesso.");
    widget.callbackCustomers!(customer);
    pop(context);
  }

  Future<void> _getDataCountryState() async {
    String dataCountryStates = await DefaultAssetBundle.of(context)
        .loadString("assets/sql/country_states.json");
    List<dynamic> states = jsonDecode(dataCountryStates);
    for (var cs in states) {
      CountryState countryState = CountryState();
      countryState.id = cs["id"];
      countryState.code = cs["code"];
      countryState.name = cs["name"];
      countryStates.add(countryState);
      countryStates.sort((a, b) => a.name!.compareTo(b.name!));
    }
  }

  Future<void> _getCityData() async {
    final ByteData data = await rootBundle.load("assets/sql/cities.json");
    allCities = utf8.decode(data.buffer.asUint8List());

    if (_customer.countryState!.id != null) {
      List<dynamic> cts = jsonDecode(allCities!);
      for (var c in cts) {
        City city = City(countryState: CountryState());
        if (c["state_id"] == _customer.countryState!.id) {
          city.id = c["id"];
          city.name = c["name"];
          city.countryState!.id = c["state_id"];
          cities.add(city);
          cities.sort((a, b) => a.name!.compareTo(b.name!));
        }
      }
    }

    setState(() {});
    dismiss();
  }

  Widget _body() {
    return SingleChildScrollView(
      child: Column(
        children: [
          AppTextfield(
            "Nome *",
            TextCapitalization.characters,
            controller: _tName,
            inputType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório';
              }
              if (value.length < 3) {
                return 'O nome deve ter ao menos 3 letras! *';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          AppTextfield(
            "CNPJ/CPF",
            TextCapitalization.sentences,
            required: false,
            controller: _tCpfCnpj,
            maxLines: 1,
            inputType: TextInputType.phone,
            validator: (value) {
              final number = int.tryParse(value!);
              if (value.isNotEmpty) {
                if (number == null) {
                  return 'Apenas números são aceitos! *';
                } else {
                  _tCpfCnpj.text = value;
                }
              }
            },
            maskFormatter: [
              MaskTextInputFormatter(mask: "##############", filter: {"#": RegExp(r'[0-9]')}),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          AppTextfield(
            "Logradouro *",
            TextCapitalization.characters,
            controller: _tLogradouro,
            inputType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório';
              }
              if (value.length < 3) {
                return 'O nome deve ter ao menos 3 letras! *';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          AppTextfield(
            "Número *",
            TextCapitalization.characters,
            controller: _tNumber,
            inputType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          AppTextfield(
            "CEP",
            TextCapitalization.sentences,
            required: false,
            controller: _tCep,
            maxLines: 1,
            inputType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório *';
              }

              return null;
            },
            maskFormatter: [MaskTextInputFormatter(mask: "#####-###")],
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: DropdownSearch<dynamic>(
                // enabled: !widget.viewOnly!,
                mode: Mode.DIALOG,
                items: countryStates,
                label: "Estado *",
                hint: "selecione o estado",
                showClearButton: true,
                validator: (value) {
                  if (value == null) {
                    return 'Insira o estado *';
                  }
                  return null;
                },
                onChanged: (value) {
                  _customer.countryState = value;
                  _getCityData();
                },
                showSearchBox: true,
                selectedItem: _customer.countryState != null
                    ? _customer.countryState!.name
                    : null),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: DropdownSearch<dynamic>(
                // enabled: !widget.viewOnly!,
                mode: Mode.DIALOG,
                items: cities,
                label: "Cidade *",
                hint: "selecione a cidade",
                showClearButton: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Insira a cidade *';
                  }
                  return null;
                },
                onChanged: (value) async {
                  if (value != null) {
                    setState(() {
                      _customer.city = value;
                    });
                  }
                },
                showSearchBox: true,
                selectedItem:
                    _customer.city != null ? _customer.city!.name : null),
          ),
          const SizedBox(height: 10),
          AppTextfield(
            "Telefone *",
            TextCapitalization.sentences,
            required: true,
            controller: _tPhone,
            maxLines: 1,
            inputType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório *';
              }

              return null;
            },
            maskFormatter: [MaskTextInputFormatter(mask: "(##)#####-####")],
          ),
        ],
      ),
    );
  }
}
