import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

import '../../components/fields.dart';
import '../../components/object_bottom_nav_bar.dart';
import '../../constants.dart';
import '../../controllers.dart';
import '../../models/sale_order.dart';
import '../../models/sale_order_line.dart';
import '../../shared_prefs.dart';
import '../header.dart';

final Controller c = Get.find();

final TextEditingController _partnerIdController = TextEditingController();
final TextEditingController _paymentTermIdController = TextEditingController();
final TextEditingController _dateOrderController = TextEditingController();
final TextEditingController _addNewProductController = TextEditingController();
final TextEditingController _addNewUomController = TextEditingController();
final TextEditingController _addNewQtyController = TextEditingController();
final TextEditingController _addNewPriceUnit = TextEditingController();
final TextEditingController _addNewPriceSubtotal = TextEditingController();
  
OdooSession? session ;
OdooClient? client ;


class SaleOrderView extends StatelessWidget {
  const SaleOrderView({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    c.loading(false);
    var size = MediaQuery.of(context).size*0.5; //this gonna give us total height and with of our device
    var name = Get.parameters['name'] ?? '0';

    SaleOrderModel saleOrder = SaleOrderModel(id: 0, name: '', partnerId: 0, paymentTermId: 0, orderDate: '', amountTotal: 0, state:'', orderLines: []);
    c.saveSaleOrder(saleOrder.toJson());

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
          onEdit: editSaleOrder,
          onSave: () { saveSaleOrder(context); }, 
          onConfirm: confirmSaleOrder,
        ),
        body:  Stack(
          children: <Widget>[
            Header(size: size),
            c.isLoading.isTrue ? Center(child: CircularProgressIndicator()) : 
              Body(title: "Sale Order", name: name)
          ],
        ),
      ),
    );
  }

  saveSaleOrder(context) async {
    // print('save');
    var saleOrder = c.saleOrder;
    // print(saleOrder);

    final prefs = SharedPref();
    final sobj = await prefs.readObject('session');
    session = OdooSession.fromJson(sobj);
    client = OdooClient(c.baseUrl.toString(), session);
    
    c.isLoading.value = true;

    try {
      print('rpc');
      // print(c.isLoading);
      // print(c.isLoading);
      var response = await client?.callKw({
        'model': 'sale.order',
        'method': 'write',
        'args': [
          [saleOrder['id']],
          {
            'name': saleOrder['name'],
            'date_order': saleOrder['orderDate'],
            'partner_id': saleOrder['partnerId'],
            'payment_term_id': saleOrder['paymentTermId'],
          }
        ],
        'kwargs': {},
      });
      print(c.isLoading);
      print(response);
      if(response!=null) {
        c.loading(false) ;
        showDialog(context: context, builder: (context) {
          return SimpleDialog(
              children: <Widget>[
                    Center(child: Text("Successfull save"))
              ]);
        });
      }
    } catch (e) { 
      client?.close();
      c.loading(false) ;
      showDialog(context: context, builder: (context) {
        return SimpleDialog(
            children: <Widget>[
                  Center(child: Text("Erro save ${e.toString()}"))
            ]);
      });
    }
  }

  void editSaleOrder(){
    print('edit');
    print(c.saleOrder);
  }
  
  void confirmSaleOrder(){
    print('confirm');
    print(c.saleOrder);
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
                          var saleOrder = SaleOrderModel.fromJson(record);
                          c.saveSaleOrder(saleOrder.toJson());
                          // print(c.saleOrder);
                          // _dateOrderController.text = saleOrder.orderDate;
                          return buildForm(context, record);
                        }),
                    );

                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                }
                else{
                    return Center(child: CircularProgressIndicator());
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
            ['id', 'in', ids] //[2,3,4]
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

    var lines = record['order_line'];//[3,4,5,6]
    var stateColor = getStateColor(record);
    var saleOrder = c.saleOrder;
    var size = MediaQuery.of(context).size;

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
                            saleOrder['partnerId'] = int.parse(master['id']);
                            _partnerIdController.text = master['name'];
                            },
                        ),
                       
                        DateField(
                          initialValue: record['date_order'],
                          controller: _dateOrderController,
                          onSelect: (date) {
                            saleOrder['orderDate'] = date;
                            // print(saleOrder.toString());
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
                            saleOrder['paymentTermId'] = int.parse(master['id']);
                            _paymentTermIdController.text = master['name'];
                          },
                        ),
                        
                        AmountField(
                          currency_id: record['currency_id'], 
                          value: (record['amount_total'] != null) ? record['amount_total'] : 0, 
                          hint:'Enter amount total'
                        )
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Order Lines", 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                ),
                ElevatedButton(
                    onPressed: () {
                      var sol = SaleOrderLineModel.newOrderLine();
                      print(sol);
                      c.saveSaleOrderLine(sol);
                      showDialog(context: context, builder: (context) {
                        return SaleOrderLineForm();
                      });
                    }, 
                    child: Text("Add new item")
                  )
              ],
            ),
          ),
        ),
        
        SizedBox(
          height: size.height*0.5,
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
                            return buildListItem(context, record);
                          }),
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }
                  else{
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ],
          ),
        ),
   
      ]
    );
  }

  MaterialColor getStateColor(record) {
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
    return stateColor;
  }

  Widget buildListItem(context, Map<String, dynamic> record) {
    var unique = record['__last_update'] as String;
    unique = unique.replaceAll(RegExp(r'[^0-9]'), '');

    final productUrl ='${client?.baseURL}/web/image?model=product.template&field=image&id=${record["product_id"][0]}&unique=$unique';
    
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        onTap: ()  {
          SaleOrderLineModel sol = SaleOrderLineModel.fromJson(record);
          print(sol);
          c.saveSaleOrderLine(sol.toJson());
          showDialog(context: context, builder: (context) {
            return SaleOrderLineForm();
          });
        },
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

class SaleOrderLineForm extends StatelessWidget {
  const SaleOrderLineForm({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var value = c.saleOrderLine.value;
    var saleOrder = c.saleOrder.value;
    SaleOrderLineModel sol = SaleOrderLineModel.fromJson(value);
    _addNewQtyController.text = sol.qty.toString();
    _addNewPriceUnit.text = sol.priceUnit.toString();
    _addNewPriceSubtotal.text = sol.priceSubtotal.toString();
    // print(sol);
    return SimpleDialog(
      contentPadding: const EdgeInsets.all(20),
      children: <Widget>[
          Many2OneField(
            object: 'product.product', 
            value: sol.productId, 
            controller: _addNewProductController, 
            hint: 'select product', 
            label: 'Product', 
            icon: Icons.add_box, 
            onSelect: (master){
              _addNewProductController.text = master['name'];
              sol.productId = master['id'];
            }
          ),
          TextField(
            controller: _addNewQtyController,
            decoration: const InputDecoration(  
              icon:  Icon(Icons.abc),  
              hintText: 'Enter qty',  
              labelText: 'Quantity',  
            ),
          ),
          Many2OneField(
            object: 'product.uom', 
            value: sol.uomId, 
            controller: _addNewUomController, 
            hint: 'select uom', 
            label: 'UoM', 
            icon: Icons.add_box, 
            onSelect: (master){
              _addNewUomController.text = master['name'];
            }
          ),          
          TextField(
            controller: _addNewPriceUnit,
            decoration: const InputDecoration(  
              icon:  Icon(Icons.abc),  
              hintText: 'Unit price',  
              labelText: 'Unit Price',  
            ),
          ),
          TextField(
            controller: _addNewPriceSubtotal,
            decoration: const InputDecoration(  
              icon:  Icon(Icons.abc),  
              hintText: 'Amount Subtotal',  
              labelText: 'Sub Total',  
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: (){

            }, 
            child: Text("Ok")
          )
        ]);
  }
}

