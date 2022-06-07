import 'dart:collection';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:visits_app/data/daos/customer_dao.dart';
import 'package:visits_app/data/daos/visit_customer_dao.dart';
import 'package:visits_app/data/daos/visit_dao.dart';
import 'package:visits_app/data/enums/visit_tag.dart';
import 'package:visits_app/data/models/customer.dart';
import 'package:visits_app/data/models/visit.dart';
import 'package:visits_app/data/models/visit_customer.dart';
import 'package:visits_app/pages/customer/customer_form_page.dart';
import 'package:visits_app/pages/visits_routes/calendar/calendar_header.dart';
import 'package:visits_app/utils/calendar.dart';
import 'package:visits_app/utils/easy_loading.dart';
import 'package:visits_app/utils/nav.dart';

typedef VisitsValue = Visit Function(Visit);

class CalendarPage extends StatefulWidget {
  final VisitsValue? callbackVisits;
  bool viewOnly = false;
  Visit? visit;
  List<Customer>? customers = [];

  CalendarPage(
      {Key? key,
      required this.viewOnly,
      this.callbackVisits,
      this.visit,
      this.customers})
      : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final PageController _pageController;
  // late final ValueNotifier<List<Visit>> _selectedEvents;
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  List<Visit?> visits = [];
  List<Customer> customers = [];
  List<Customer> filteredCustomers = [];
  final CustomerDao customerDao = CustomerDao();
  final VisitDao visitDao = VisitDao();
  final VisitCustomerDao visitCustomerDao = VisitCustomerDao();
  Customer? selectedCustomer = Customer();
  Visit? visit = Visit();

  bool get canClearSelection =>
      _selectedDays.isNotEmpty || _rangeStart != null || _rangeEnd != null;

  @override
  void initState() {
    super.initState();
    _getCustomers();
    if (widget.viewOnly) {
      _viewMode();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _focusedDay.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rota de visitas"),
        actions: [
          Visibility(
              visible: !widget.viewOnly,
              child: IconButton(
                  onPressed: _onClickSave, icon: const Icon(Icons.check)))
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return _buildTableCalendar();
  }

  Widget _buildTableCalendar() {
    return Column(
      children: [
        ValueListenableBuilder<DateTime>(
          valueListenable: _focusedDay,
          builder: (context, value, _) {
            return CalendarHeader(
              focusedDay: value,
              clearButtonVisible: canClearSelection,
              onTodayButtonTap: () {
                setState(() => _focusedDay.value = DateTime.now());
              },
              onClearButtonTap: () {
                if (!widget.viewOnly) {
                  setState(() {
                    _rangeStart = null;
                    _rangeEnd = null;
                    _selectedDays.clear();
                  });
                }
              },
              onLeftArrowTap: () {
                if (!widget.viewOnly) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
                }
              },
              onRightArrowTap: () {
                if (!widget.viewOnly) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
                }
              },
            );
          },
        ),
        TableCalendar<Visit>(
          locale: 'pt_BR',
          startingDayOfWeek: StartingDayOfWeek.sunday,
          firstDay: kFirstDay,
          lastDay: kLastDay,
          focusedDay: _focusedDay.value,
          headerVisible: false,
          selectedDayPredicate: (day) => _selectedDays.contains(day),
          rangeStartDay: _rangeStart,
          rangeEndDay: _rangeEnd,
          calendarFormat: _calendarFormat,
          rangeSelectionMode: _rangeSelectionMode,
          formatAnimationCurve: Curves.bounceIn,
          daysOfWeekStyle: DaysOfWeekStyle(
            weekendStyle: const TextStyle().copyWith(color: Colors.blue),
            weekdayStyle: const TextStyle().copyWith(color: Colors.black),
          ),
          onRangeSelected: _onRangeSelected,
          onCalendarCreated: (controller) => _pageController = controller,
          onPageChanged: (focusedDay) => _focusedDay.value = focusedDay,
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() => _calendarFormat = format);
            }
          },
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: const TextStyle().copyWith(color: Colors.blue),
            selectedDecoration: BoxDecoration(
                color: Colors.deepOrange[400], shape: BoxShape.circle),
            todayDecoration: BoxDecoration(
                color: Colors.deepOrange[200], shape: BoxShape.circle),
          ),
        ),
        const SizedBox(height: 8.0),
        Visibility(
          visible: !widget.viewOnly,
          child: TextButton(
            style: TextButton.styleFrom(
              primary: Colors.white,
              backgroundColor: Colors.transparent,
              minimumSize: const Size(150, 25),
              maximumSize: const Size(150, 30),
              side: const BorderSide(color: Colors.blue, width: 1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              showAlertDialog();
            },
            child: const Text(
              "Adicionar Cliente",
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ),
        Visibility(
          visible: widget.viewOnly,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text("Clientes inclusos na rota: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
              ),
            ],
          ),
        ),
        Expanded(child: _buildCustomers(filteredCustomers))
      ],
    );
  }

  void _viewMode() {
    setState(() {
      _rangeStart = widget.visit!.initDate!;
      _rangeEnd = widget.visit!.endDate!;

      filteredCustomers = widget.customers!;
    });
  }

  Future<void> _onClickSave() async {
    showLoading("Salvando ...");

    if (_rangeStart == null || _rangeEnd == null) {
      return showError("Informe a data de ínicio e a data de término!");
    }

    if (filteredCustomers.isEmpty) {
      return showError("Informe ao menos um cliente!");
    }

    visit = Visit(
      initDate: _rangeStart,
      endDate: _rangeEnd,
    );

    visit!.id = await visitDao.save(visit!);

    VisitCustomer visitCustomer = VisitCustomer();

    for (var customer in filteredCustomers) {
      visitCustomer.visit = visit;
      visitCustomer.customer = customer;
      customer.tag = VisitTags.visitMade;

      visitCustomer.id = await visitCustomerDao.save(visitCustomer);
      await customerDao.update(customer.id, values: customer.toMap());
    }

    visit!.customers = filteredCustomers;
    dismiss();
    showSuccess("Salvo com sucesso.");
    widget.callbackVisits!(visit!);
    pop(context);
  }

  Future<void> _getCustomers() async {
    List<Customer> cms = [];
    cms = await customerDao.findAll();
    setState(() {
      customers = cms;
    });
  }

  void _addCustomer() {
    if (selectedCustomer!.id != null) {
      setState(() {
        int index =
            filteredCustomers.indexWhere((fc) => fc.id == selectedCustomer!.id);
        if (index == -1) {
          filteredCustomers.add(selectedCustomer!);
          pop(context);
          selectedCustomer = Customer();
        } else {
          showError("Cliente já adicionado !");
        }
      });
    } else {
      showError("Nenhum cliente selecionado!");
    }
  }

  void _newCustomer() {
    push(context, CustomerFormPage(
      callbackCustomers: (value) {
        if (value != null) {
          setState(() {
            customers.add(value);
          });
        }

        return value;
      },
    ));
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (!widget.viewOnly) {
      setState(() {
        final newIdx = newIndex > oldIndex ? newIndex - 1 : newIndex;
        final item = filteredCustomers.removeAt(oldIndex);
        filteredCustomers.insert(newIdx, item);
      });
    } else {
      showError("Não é possível reordenar no modo de visualização!");
    }
  }

  Widget _buildCustomers(List<Customer> customers) {
    // Color? colorCard = Colors.blue[100];

    return ReorderableListView(children: [
      for (final fc in filteredCustomers)
        ListTile(
          key: Key(fc.name!),
          title: Text(fc.name.toString(),
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color.fromRGBO(96, 96, 96, 1))),
          subtitle: Row(
            children: [
              ChoiceChip(
                label: Text(fc.tag!.state), 
                labelStyle: const TextStyle(fontSize: 13, color: Colors.black), 
                selected: false, 
                backgroundColor: Colors.blue[100],
                onSelected: (bool value){},
              ),
            ],
          ),
          leading: const Icon(Icons.menu),
          trailing: Visibility(
            visible: widget.viewOnly,
            child: IconButton(onPressed: (){
            _showErrorBottomSheet(context, fc);
            }, icon: const Icon(Icons.edit)),
          ),
        ),
    ], onReorder: _onReorder);
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    if (!widget.viewOnly) {
      setState(() {
        _focusedDay.value = focusedDay;
        _rangeStart = start;
        _rangeEnd = end;
        _selectedDays.clear();
        _rangeSelectionMode = RangeSelectionMode.toggledOn;
      });
    }
  }

  Future _refreshTagCustomer(VisitTags tag, Customer customer) async {
    customer.tag = tag;
    await customerDao.update(customer.id, values: customer.toMap());
    setState(() {
      int index = filteredCustomers.indexWhere((fc) => fc.id == customer.id);
      if(index > -1){ 
        filteredCustomers[index] = customer;
      }
      showSuccess("Tag atualizada !");
      pop(context);
    });
  }

  void _showErrorBottomSheet(BuildContext context, Customer customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.80,
        minChildSize: 0.80,
        maxChildSize: 0.80,
        builder: (context, scrollController) {
          return Container(
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("Defina uma tag:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,))
                    ],
                  ),
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: Text(VisitTags.visitMade.state),
                        labelStyle: const TextStyle(fontSize: 13, color: Colors.black), 
                        selected: false, 
                        backgroundColor: Colors.blue[100],
                        onSelected: (bool value){
                          if(value){
                            _refreshTagCustomer(VisitTags.visitMade, customer);
                          }
                        },
                      ),
                      ChoiceChip(
                        label: Text(VisitTags.absentCustomer.state),
                        labelStyle: const TextStyle(fontSize: 13, color: Colors.black), 
                        selected: false, 
                        backgroundColor: Colors.blue[100],
                        onSelected: (bool value){
                          if(value){
                            _refreshTagCustomer(VisitTags.absentCustomer, customer);
                          }
                        },
                      ),
                      ChoiceChip(
                        label: Text(VisitTags.visitCanceledByCustomer.state),
                        labelStyle: const TextStyle(fontSize: 13, color: Colors.black), 
                        selected: false, 
                        backgroundColor: Colors.blue[100],
                        onSelected: (bool value){
                          if(value){
                            _refreshTagCustomer(VisitTags.visitCanceledByCustomer, customer);
                          }
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Future showAlertDialog() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Container(
              // height: 50,
              // width: 50,
              color: Colors.transparent,
              child: Center(
                child: Container(
                  color: Colors.white,
                  height: 250,
                  width: 250,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              pop(context);
                            },
                            icon: const Icon(Icons.clear),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: DropdownSearch<dynamic>(
                          mode: Mode.DIALOG,
                          items: customers,
                          label: "Cliente",
                          hint: "selecione o cliente",
                          showClearButton: true,
                          onChanged: (value) async {
                            if (value != null) {
                              setState(() {
                                selectedCustomer = value!;
                              });
                            }
                          },
                          showSearchBox: true,
                          selectedItem: selectedCustomer!.name ?? "",
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              primary: Colors.white,
                              backgroundColor: Colors.blue,
                              minimumSize: const Size(110, 25),
                            ),
                            onPressed: _addCustomer,
                            child: const Text("Adicionar"),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              primary: Colors.white,
                              backgroundColor: Colors.blue,
                              minimumSize: const Size(110, 25),
                            ),
                            onPressed: _newCustomer,
                            child: const Text("Criar Novo"),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ));
        });
  }
}
