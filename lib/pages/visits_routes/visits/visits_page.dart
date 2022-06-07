import 'package:flutter/material.dart';
import 'package:visits_app/data/daos/customer_dao.dart';
import 'package:visits_app/data/daos/visit_customer_dao.dart';
import 'package:visits_app/data/daos/visit_dao.dart';
import 'package:visits_app/data/models/visit.dart';
import 'package:visits_app/data/models/visit_customer.dart';
import 'package:visits_app/pages/visits_routes/visits/visits_listview.dart';

class VisitsPage extends StatefulWidget {
  const VisitsPage({Key? key}) : super(key: key);

  @override
  _VisitsPageState createState() => _VisitsPageState();
}

class _VisitsPageState extends State<VisitsPage> {
  bool loading = true;
  List<Visit> visits = [];
  final VisitDao _visitDao = VisitDao();
  final VisitCustomerDao _visitCustomerDao = VisitCustomerDao();
  final CustomerDao _customerDao = CustomerDao();

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: loading == true
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              child: VisitsListView(
                visits: visits,
              ),
              onRefresh: _onRefresh,
            ),
    );
  }

  Future<void> _getData() async {
    await _onRefresh();
    setState(() {
      loading = false;
      visits.sort((a, b) => b.id!.compareTo(a.id!));
    });
  }

  Future _onRefresh() async {
    visits = await _visitDao.findAll();
    List<VisitCustomer>? visitCustomers = [];
    for (var v in visits) {
      visitCustomers = await _visitCustomerDao.findByList("visit_id", v.id!);

      for (var vc in visitCustomers) {
        vc.customer = await _customerDao.findById(vc.customer!.id!);
        v.customers!.add(vc.customer!);
      }
    }
  }
}
