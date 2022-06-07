import 'package:flutter/material.dart';
import 'package:visits_app/pages/customer/customer_form_page.dart';
import 'package:visits_app/utils/nav.dart';

class DrawerList extends StatefulWidget {
  @override
  _DrawerListState createState() => _DrawerListState();
}

class _DrawerListState extends State<DrawerList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Drawer(
            child: ListView(
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.person_add),
          title: const Text("Novo Cliente"),
          onTap: () {
            push(context, const CustomerFormPage());
          },
        ),
      ],
    )));
  }
}
