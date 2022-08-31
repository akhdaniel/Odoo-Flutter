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


OdooSession? session ;
OdooClient? client ;
SaleOrderModel saleOrder = SaleOrderModel.newSaleOrder();
// List saleOrderLines = [];
var saleOrderLines = c.saleOrderLines.value;
SaleOrderLineModel currentSaleOrderLine = SaleOrderLineModel.newOrderLine();

getOrder(context, id) async {
  final prefs = SharedPref();
  final sobj = await prefs.readObject('session');
  session = OdooSession.fromJson(sobj);
  client = OdooClient(c.baseUrl.toString(), session);

  try {
    var so = await client?.callKw({
      'model': 'sale.order',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        // 'context': {'bin_size': true},
        'domain': [
          ['id', '=', int.parse(id)]
        ],
      },
    });

    var sol_ids = so[0]['order_line'];


    //simpan object name ke state 
    c.setObjectName(so[0]['name']);

    // c.saleOrderLines.value.clear();
    var sol = await getOrderLines(context, sol_ids);
    c.saleOrderLines.value = sol.map((e)=> SaleOrderLineModel.fromJson(e)).toList();
    return so;

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

getOrderLines(context, ids) async {
  print(ids);
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
        'fields':['id','order_id','name','currency_id','product_id','product_uom_qty','product_uom','price_unit','price_subtotal','__last_update']
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


class SaleOrderView extends StatelessWidget {
  const SaleOrderView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    c.loading(false);
    var size = MediaQuery.of(context).size*0.5; //this gonna give us total height and with of our device
    var id = Get.parameters['id'] ?? '0';


    if (id=='0'){
      c.setObjectName('New');
      c.saveSaleOrder(SaleOrderModel.newSaleOrder().toJson());
      c.saleOrderLines.value=[];
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Odoo App',
      theme: ThemeData(
        fontFamily: "Cairo",
        scaffoldBackgroundColor: kPrimaryLightColor,
        textTheme: Theme.of(context).textTheme.apply(displayColor: kTextColor),
      ),
      home: Scaffold(
        bottomNavigationBar: Obx(()=>ObjectBottomNavBar(
          showEdit: c.enableEditing.value,
          showConfirm: c.enableEditing.value,
          showSave: c.enableEditing.value,
          onEdit: editSaleOrder,
          onSave: () { saveSaleOrder(context); }, 
          onConfirm: confirmSaleOrder,
        )),
        body:  Stack(
          children: <Widget>[
            Header(size: size),
            c.isLoading.isTrue ? Center(child: CircularProgressIndicator()) : 
              Body(title: "Sale Order", id: id)
          ],
        ),
      ),
    );
  }

  saveSaleOrder(context)  {
    Widget okButton = ElevatedButton(
        child: Text("OK"),
        onPressed: () async { 
          Navigator.pop(context, true);

          
          Iterable<List<Object>> orderLinesOrm = c.saleOrderLines.value.map((e) { 
            var command = e.id == 0 ? 0 : 1 ;
            var id = e.id;
            return [command, id , {
              'product_id':e.productId[0],
              'product_uom': e.uomId[0],
              'product_uom_qty':e.qty,
              'price_unit':e.priceUnit,
              'price_subtotal':e.priceSubtotal,
              }];
            });

            final prefs = SharedPref();
            final sobj = await prefs.readObject('session');
            session = OdooSession.fromJson(sobj);
            client = OdooClient(c.baseUrl.toString(), session);
            
            c.isLoading.value = true;

            // print(orderLinesOrm.toList());
            // print(saleOrder.id);

            try {      
              var response;

              if(saleOrder.id==0){
                response = await client?.callKw({
                  'model': 'sale.order',
                  'method': 'create',
                  'args': [
                    {
                      'date_order': saleOrder.orderDate,
                      'partner_id': saleOrder.partnerId[0],
                      'payment_term_id': saleOrder.paymentTermId[0],
                      'order_line': orderLinesOrm.toList(),//o2m fields
                    }
                  ],
                  'kwargs': {},
                });

                saleOrder.id= response;
              }
              else{
                response = await client?.callKw({
                  'model': 'sale.order',
                  'method': 'write',
                  'args': [
                    [saleOrder.id],
                    {
                      // 'name': saleOrder.name,
                      'date_order': saleOrder.orderDate,
                      'partner_id': saleOrder.partnerId[0],
                      'payment_term_id': saleOrder.paymentTermId[0],
                      'order_line': orderLinesOrm.toList(),//o2m fields
                    }
                  ],
                  'kwargs': {},
                });
              }
              if(response!=null) {
                c.loading(false) ;
                var so = await getOrder(context, saleOrder.id.toString());
                var sol_ids = so[0]['order_line'];
                var sol = await getOrderLines(context, sol_ids);
                c.saleOrderLines.value = sol.map((e)=> SaleOrderLineModel.fromJson(e)).toList();

                showDialog(context: context, builder: (context) {
                  return const SimpleDialog(
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
                          Center(child: Text("Error on save ${e.toString()}"))
                    ]);
              });
            }          
        },
      );    

    AlertDialog alert = AlertDialog(
      title: Text("Confirm save?"),
      content: Text("confirm save?."),
      actions: [
        okButton,
      ],
    );

    // confirm 
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
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
    required this.id,
  }) : super(key: key);
  final _formKey = GlobalKey<FormState>();  

  final String? title;
  String? subtitle ;
  final String id;

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
            Obx(()=>Text(
              c.objectName.value,
              style:TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: Colors.white),
            )),
            
            id=='0'? 
            buildForm(context, 
              {'state':'draft','name':'','partner_id':[0,''],'date_order':'','payment_term_id':[0,''],'currency_id':[0,'']}
            ) : 
            FutureBuilder(
              future: getOrder(context, id),
              builder: (context, AsyncSnapshot<dynamic>  orderSnapshot) {
                if (orderSnapshot.hasData) {
                  if (orderSnapshot.data!=null) {

                    return Expanded(
                      child: ListView.builder(
                        itemCount: orderSnapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          final record = orderSnapshot.data[index] as Map<String, dynamic>;
                          saleOrder = SaleOrderModel.fromJson(record);
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

  buildForm(context, record){
    // var lines = record['order_line'];//[3,4,5,6]
    var stateColor = getStateColor(record);
    var size = MediaQuery.of(context).size;

    var state = record['state'];
    var enableEditing = state == 'draft';

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
                          fields: ['id','name','city'],
                          icon: Icons.person,
                          controller: _partnerIdController,
                          enableEditing: enableEditing,
                          onSelect: (master) {
                            saleOrder.partnerId = [int.parse(master['id']), master['name']];
                            _partnerIdController.text = master['name'];
                          },
                        ),
                       
                        DateField(
                          initialValue: record['date_order'],
                          controller: _dateOrderController,
                          enableEditing: enableEditing,
                          onSelect: (date) {
                            saleOrder.orderDate = date;
                            // print(saleOrder.toString());
                          },
                        ),
                        
                        Many2OneField(
                          object: 'account.payment.term',
                          value: (record['payment_term_id'] is List) ? record['payment_term_id'] : [], 
                          hint:'Select payment term',
                          label: 'Payment Term',
                          fields: ['id','name'],
                          icon: Icons.abc,
                          controller: _paymentTermIdController,
                          enableEditing: enableEditing,
                          onSelect: (master) {
                            saleOrder.paymentTermId = [int.parse(master['id']), master['name']];
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
                Visibility(
                  visible: enableEditing,
                  child: ElevatedButton(
                    onPressed: () {
                      currentSaleOrderLine = SaleOrderLineModel.newOrderLine();
                      currentSaleOrderLine.currencyId = saleOrder.currencyId;
                      showDialog(context: context, builder: (context) {
                        return SaleOrderLineForm();
                      });
                    }, 
                    child: const Text("Add new item")
                  ),
                )
              ],
            ),
          ),
        ),
        
        SizedBox(
          height: size.height*0.4,
          child: Column(
            children: [

              Obx(()=>Expanded(
                child: ListView.builder(
                  itemCount: c.saleOrderLines.value.length,
                  itemBuilder: (BuildContext context, int index){
                    final record = c.saleOrderLines.value[index].toJson();
                    return buildListItem(context, record);
                  }),
              )),
              // FutureBuilder(
              //   future: getOrderLines(context, lines),
              //   builder: (context, AsyncSnapshot<dynamic> snapshot) {
              //     if (snapshot.hasData) {
              //       if (snapshot.data!=null) {     
              //         saleOrderLines.clear();             
              //         return Expanded(
              //           child: ListView.builder(
              //             itemCount: snapshot.data.length,
              //             itemBuilder: (BuildContext context, int index) {
              //               final record = snapshot.data[index] as Map<String, dynamic>;
              //               saleOrderLines.add( SaleOrderLineModel.fromJson(record));
              //               return buildListItem(context, record);
              //             }),
              //         );
              //       } else {
              //         return const Center(child: CircularProgressIndicator());
              //       }
              //     }
              //     else{
              //       return const Center(child: CircularProgressIndicator());
              //     }
              //   },
              // ),
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
          currentSaleOrderLine = SaleOrderLineModel.fromJson(record);
          print(currentSaleOrderLine.id);
          // c.saveSaleOrderLine(sol.toJson());
          showDialog(context: context, builder: (context) {
            return SaleOrderLineForm();
          });
        },
        leading: CircleAvatar(backgroundImage: NetworkImage(productUrl)),
        title: Text(record['name'],
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
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
  SaleOrderLineForm({
    Key? key,
  }) : super(key: key);

  final TextEditingController _addNewProductController = TextEditingController();
  final TextEditingController _addNewUomController = TextEditingController();
  final TextEditingController _addNewQtyController = TextEditingController();
  final TextEditingController _addNewPriceUnit = TextEditingController();
  final TextEditingController _addNewPriceSubtotal = TextEditingController();
  
  @override
  Widget build(BuildContext context) {

    _addNewQtyController.text = currentSaleOrderLine.qty.toString();
    _addNewPriceUnit.text = currentSaleOrderLine.priceUnit.toString();
    _addNewPriceSubtotal.text = currentSaleOrderLine.priceSubtotal.toString();

    return SimpleDialog(
      contentPadding: const EdgeInsets.all(20),
      children: <Widget>[
          Many2OneField(
            object: 'product.product', 
            value: currentSaleOrderLine.productId, 
            controller: _addNewProductController, 
            hint: 'select product', 
            label: 'Product', 
            icon: Icons.add_box, 
            fields: ['id','name','list_price', 'uom_id'],
            enableEditing: true,
            // domain: [['sale','=',true]],
            onSelect: (master){
              _addNewProductController.text = master['name'];
              _addNewPriceUnit.text = master['price'];

              currentSaleOrderLine.productId = [ int.parse(master['id']), master['name']];
              currentSaleOrderLine.name = master['name'];
              currentSaleOrderLine.priceUnit = double.parse(master['price']);
              currentSaleOrderLine.priceSubtotal = currentSaleOrderLine.priceUnit * currentSaleOrderLine.qty ;

              _addNewPriceSubtotal.text = currentSaleOrderLine.priceSubtotal.toString();
            }
          ),
          TextField(
            onChanged: (val){
              print(val);
              currentSaleOrderLine.qty = val!=''?double.parse(val):0;
              currentSaleOrderLine.priceSubtotal = currentSaleOrderLine.priceUnit * currentSaleOrderLine.qty ;
              _addNewPriceSubtotal.text = currentSaleOrderLine.priceSubtotal.toString();
            },
            controller: _addNewQtyController,
            decoration: const InputDecoration(  
              icon:  Icon(Icons.abc),  
              hintText: 'Enter qty',  
              labelText: 'Quantity',  
            ),
          ),
          Many2OneField(
            object: 'product.uom', 
            value: currentSaleOrderLine.uomId, 
            controller: _addNewUomController, 
            hint: 'select uom', 
            label: 'UoM', 
            fields: ['id','name'],
            icon: Icons.add_box, 
            enableEditing: true,
            onSelect: (master){
              _addNewUomController.text = master['name'];
              currentSaleOrderLine.uomId = [ int.parse(master['id']), master['name']];
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
              if (currentSaleOrderLine.id!=0){
                // print(currentSaleOrderLine);
                //update list value by id
                var sol = c.saleOrderLines.value;
                int index = sol.indexWhere((e) => e.id==currentSaleOrderLine.id);
                c.updateSaleOrderLines(index,currentSaleOrderLine);

              }
              else {
                c.addSaleOrderLines(
                  SaleOrderLineModel(
                    id: 0, 
                    name: currentSaleOrderLine.name,
                    productId: currentSaleOrderLine.productId, 
                    saleOrderId: [saleOrder.id, saleOrder.name], 
                    uomId: currentSaleOrderLine.uomId, 
                    currencyId: currentSaleOrderLine.currencyId, 
                    qty: currentSaleOrderLine.qty, 
                    priceUnit: currentSaleOrderLine.priceUnit, 
                    priceSubtotal: currentSaleOrderLine.priceSubtotal,
                    lastUpdate: currentSaleOrderLine.lastUpdate,
                  )
                );
              }


              // print(c.saleOrderLines.value.length); 
              Navigator.pop(context, true);
            }, 
            child: const Text("Ok")
          )
        ]);
  }
}