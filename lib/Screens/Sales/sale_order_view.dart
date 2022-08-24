import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

import '../../components/fields.dart';
import '../../components/object_bottom_nav_bar.dart';
import '../../constants.dart';
import '../../controllers.dart';
import '../../models/sale_order.dart';
import '../../shared_prefs.dart';
import '../header.dart';

final Controller c = Get.find();

final TextEditingController _partnerIdController = TextEditingController();
final TextEditingController _paymentTermIdController = TextEditingController();
final TextEditingController _dateOrderController = TextEditingController();


SaleOrderModel saleOrder = SaleOrderModel(id: 0, name: '', partnerId: 0, paymentTermId: 0, orderDate: '', amountTotal: 0);


class SaleOrderView extends StatelessWidget {
  const SaleOrderView({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size*0.5; //this gonna give us total height and with of our device
    var name = Get.parameters['name'] ?? '0';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Odoo App',
      theme: ThemeData(
        fontFamily: "Cairo",
        scaffoldBackgroundColor: kPrimaryLightColor,
        textTheme: Theme.of(context).textTheme.apply(displayColor: kTextColor),
      ),
      home: Scaffold(
        bottomNavigationBar: ObjectBottomNavBar(
          onEdit: saleOrder.editSaleOrder,
          onSave: saleOrder.saveSaleOrder, 
          onConfirm: saleOrder.confirmSaleOrder,
        ),
        body: Stack(
          children: <Widget>[
            Header(size: size),
            Body(title: "Sale Order", name: name)
          ],
        ),
      ),
    );
  }


}

class Body extends StatelessWidget {
  Body({
    Key? key,
    required this.title,
    required this.name,
  }) : super(key: key);
  final _formKey = GlobalKey<FormState>();  

  final String? title;
  String? subtitle ;
  final String? name;


  OdooSession? session ;
  OdooClient? client ;
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // TopRightMenu(),
            Text(
              title??'',
              style:TextStyle(fontSize: 25, fontWeight: FontWeight.w100, color: Colors.white),
            ),
            Text(
              name.toString(),
              style:TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            name=='new'? 
            buildForm(context, 
              {'state':'draft','name':'','partner_id':[0,''],'date_order':'','payment_term_id':[0,''],'currency_id':[0,'']}
            ) : 
            FutureBuilder(
              future: getOrder(context, name),
              builder: (context, AsyncSnapshot<dynamic>  orderSnapshot) {
                if (orderSnapshot.hasData) {
                  if (orderSnapshot.data!=null) {
                    
                    return Expanded(
                      child: ListView.builder(
                        itemCount: orderSnapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          final record = orderSnapshot.data[index] as Map<String, dynamic>;
                          saleOrder = SaleOrderModel.fromJson(record);
                          print(saleOrder.toString());
                          return buildForm(context, record);
                        }),
                    );

                  } else {
                    return CircularProgressIndicator();
                  }
                }
                else{
                  return Text("No data..");
                }
              }
            )
          ],
        ),
    ));
  }

  getOrder(context, name) async {
    final prefs = SharedPref();
    final sobj = await prefs.readObject('session');
    session = OdooSession.fromJson(sobj);
    client = OdooClient(c.baseUrl.toString(), session);
    try {
      return await client?.callKw({
        'model': 'sale.order',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          // 'context': {'bin_size': true},
          'domain': [
            ['name', '=', name]
          ],
          // 'fields': ['id', 'name', '__last_update', 'amount_total'],
        },
      });
    } catch (e) { 
      client?.close();
      showDialog(context: context, builder: (context) {
        return SimpleDialog(
            children: <Widget>[
                  Center(child: Text(e.toString()))
            ]);
      });
    }
  }
 
  getOrderLies(context, ids) async {
    final prefs = SharedPref();
    final sobj = await prefs.readObject('session');
    session = OdooSession.fromJson(sobj);
    client = OdooClient(c.baseUrl.toString(), session);
    try {
      return await client?.callKw({
        'model': 'sale.order.line',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['id', 'in', ids]
          ],
        },
      });
    } catch (e) { 
      client?.close();
      showDialog(context: context, builder: (context) {
        return SimpleDialog(
            children: <Widget>[
                  Center(child: Text(e.toString()))
            ]);
      });
    }
  }

  buildForm(context, record){

    var lines = record['order_line'];
    var stateColor = Colors.orange;
    switch (record['state']) {
      case 'draft':
        stateColor = Colors.blue;
        break;
      case 'sent':
        stateColor = Colors.purple;
        break;
      case 'order':
        stateColor = Colors.green;
        break;
      case 'cancel':
        stateColor = Colors.red;
        break;
    }
    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Stack(
            children: 
              [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration( borderRadius: BorderRadius.circular(10), color: stateColor),
                    child: Text(record['state'].toUpperCase(), style: TextStyle(fontSize: 11, color: Colors.white, ))
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Form(  
                    key: _formKey,  
                    child: Column(  
                      crossAxisAlignment: CrossAxisAlignment.start,  
                      children: <Widget>[  

                        Many2OneField(
                          object: 'res.partner',
                          value: record['partner_id'], 
                          hint:'Select customer',
                          label: 'Customer',
                          icon: Icons.person,
                          controller: _partnerIdController,
                          onSelect: (master) {
                            saleOrder.partnerId = int.parse(master['id']);
                            _partnerIdController.text = master['name'];
                            },
                        ),
                       
                        TextFormField(  
                          initialValue: record['date_order'],
                          readOnly: true,
                          decoration: const InputDecoration(  
                            icon:  Icon(Icons.calendar_today),  
                            hintText: 'Enter date order',  
                            labelText: 'Order Date',  
                          ),  
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1950),
                                //DateTime.now() - not to allow to choose before today.
                                lastDate: DateTime(2100));

                                if (pickedDate != null) {
                                  print(pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                  String formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(pickedDate);
                                  print(formattedDate); //formatted date output using intl package =>  2021-03-16
                                  // setState(() {
                                  //   dateInput.text =formattedDate; //set output date to TextField value.
                                  // });
                                } else {}
                          },
                        ),
                        
                        Many2OneField(
                          object: 'account.payment.term',
                          value: (record['payment_term_id'] is List) ? record['payment_term_id'] : [], 
                          hint:'Select payment term',
                          label: 'Payment Term',
                          icon: Icons.abc,
                          controller: _paymentTermIdController,
                          onSelect: (master) {
                            print(saleOrder.toString());
                            saleOrder.paymentTermId = int.parse(master['id']);
                            print(saleOrder.toString());
                            _paymentTermIdController.text = master['name'];
                          },
                        ),
                        
                        AmountField(
                          currency_id: record['currency_id'], 
                          value: record['amount_total'], 
                          hint:'Enter amount total'
                        )
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text("Order Lines", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)),
        ),
        SizedBox(
          height: 300,
          child: Column(
            children: [
              FutureBuilder(
                future: getOrderLies(context, lines),
                builder: (context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!=null) {                  
                      return Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            final record = snapshot.data[index] as Map<String, dynamic>;
                            return buildListItem(record);
                          }),
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  }
                  else{
                    return Container(child: Text('no data'),);
                  }
                },
              ),
              TextButton(onPressed: () {}, child: Text("Add new item"))
            ],
          ),
        ),
        
        ]
    );
  }

  Widget buildListItem(Map<String, dynamic> record) {
    var unique = record['__last_update'] as String;
    unique = unique.replaceAll(RegExp(r'[^0-9]'), '');

    final productUrl ='${client?.baseURL}/web/image?model=product.template&field=image&id=${record["product_id"][0]}&unique=$unique';
    
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        leading: CircleAvatar(backgroundImage: NetworkImage(productUrl)),
        title: Text(record['name']),
        subtitle: Text(
          "${record['product_id'][1]}", 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        ),
        trailing: Text(
          "${record['currency_id'][1]} ${record['price_unit']}\nx ${record['product_uom_qty']} ${record['product_uom'][1]}\n${record['currency_id'][1]} ${record['price_subtotal']}",
          )
        
      ),
    );
  }


}
