import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:visits_app/data/models/customer.dart';
import 'package:visits_app/data/models/visit.dart';
import 'package:visits_app/pages/visits_routes/calendar/calendar_page.dart';
import 'package:visits_app/utils/nav.dart';

class VisitsListView extends StatefulWidget {
  List<Visit> visits = [];

  VisitsListView({Key? key, required this.visits}) : super(key: key);

  @override
  _VisitsListViewState createState() => _VisitsListViewState();
}

class _VisitsListViewState extends State<VisitsListView> {
  List<Customer> customers = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Visitas"),
      // ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [Expanded(child: _buildList())],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          push(context, CalendarPage(
            viewOnly: false,
            callbackVisits: (value) {
              if (value != null) {
                setState(() {
                  widget.visits.add(value);
                });
              }
              return value;
            },
          ));
        },
      ),
    );
  }

  Widget _buildList() {
    return widget.visits.isNotEmpty
        ? ListView.builder(
            itemCount: widget.visits.length,
            itemBuilder: (BuildContext context, int index) {
              return _visitCard(context, index);
            },
          )
        : Column(
            children: const [
              Center(child: Text("Nenhuma Visita.")),
            ],
          );
  }

  Widget _visitCard(BuildContext context, int i) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            key: Key(i.toString()),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: Row(
                    children: [
                      const Text("Data de ínicio: "),
                      Text(
                        DateFormat("dd/MM/yyyy").format(widget.visits[i].initDate!),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: Row(
                    children: [
                      const Text("Data de término: "),
                      Text(
                        DateFormat("dd/MM/yyyy")
                            .format(widget.visits[i].endDate!),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ButtonBarTheme(
            data: const ButtonBarThemeData(
                buttonTextTheme: ButtonTextTheme.accent),
            child: ButtonBar(
              children: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.transparent,
                    minimumSize: const Size(110, 25),
                    maximumSize: const Size(160, 30),
                    side: const BorderSide(color: Colors.blue, width: 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    customers = widget.visits[i].customers!;
                    push(context, CalendarPage(viewOnly: true, visit: widget.visits[i], customers: customers,));
                  },
                  child: const Text(
                    "Ver no Calendário",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
