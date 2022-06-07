import 'package:flutter/material.dart';
import 'package:visits_app/pages/drawer/drawer_list.dart';
import 'package:visits_app/pages/visits_routes/visits/visits_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerList(),
      appBar: AppBar(
        title: const Text("Visitas"),
      ),
      body: const VisitsPage()
    );
  }
}