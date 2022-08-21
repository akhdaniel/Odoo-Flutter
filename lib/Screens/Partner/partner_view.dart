import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

import '../../components/object_bottom_nav_bar.dart';
import '../../components/top_right_menu.dart';
import '../../constants.dart';
import '../../controllers.dart';
import '../../shared_prefs.dart';
import '../header.dart';
final Controller c = Get.find();


class PartnerView extends StatelessWidget {
  const PartnerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size*0.5; //this gonna give us total height and with of our device
    var id = Get.parameters['id'] ?? '0';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Odoo App',
      theme: ThemeData(
        fontFamily: "Cairo",
        scaffoldBackgroundColor: kPrimaryLightColor,
        textTheme: Theme.of(context).textTheme.apply(displayColor: kTextColor),
      ),
      home: Scaffold(
        bottomNavigationBar: const ObjectBottomNavBar(),        
      body: Stack(
        children: <Widget>[
          Header(size: size),
          Body(title: "Partner", id: id)
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
    required this.id,
  }) : super(key: key);
  final _formKey = GlobalKey<FormState>();  


  final String? title;
  String? subtitle ;
  final String? id;

  OdooSession? session ;
  OdooClient? client ;

  getPartner(context, id) async {
    final prefs = SharedPref();
    final sobj = await prefs.readObject('session');
    session = OdooSession.fromJson(sobj);
    client = OdooClient(c.baseUrl.toString(), session);
    try {
      return await client?.callKw({
        'model': 'res.partner',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          // 'context': {'bin_size': true},
          'domain': [
            ['id', '=', id]
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
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TopRightMenu(),
            Text(
              title??'',
              style:TextStyle(fontSize: 25, fontWeight: FontWeight.w100, color: Colors.white),
            ),
            Text(
              id.toString(),
              style:TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            // const SearchBar(),
            FutureBuilder(
              future: getPartner(context, id),
              builder: (context, AsyncSnapshot<dynamic>  orderSnapshot) {
                if (orderSnapshot.hasData) {
                  if (orderSnapshot.data!=null) {
                    
                    return Expanded(
                      child: ListView.builder(
                        itemCount: orderSnapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          final record = orderSnapshot.data[index] as Map<String, dynamic>;
                          return buildForm(context, record);
                        }),
                    );

                  } else {
                    return CircularProgressIndicator();
                  }
                }
                else{
                  return Container(child: Text("No data.."),);
                }
              }
            )
          ],
        ),
    ));
  }

  buildForm(context, record){
    // var lines = record['order_line'];
    var type = record['type'];
    var typeColor = Colors.orange;
    switch (record['type']) {
      case 'vendor':
        typeColor = Colors.blue;
        break;
      case 'customer':
        typeColor = Colors.purple;
        break;
      
    }
    return Column(
      children: [
        Card(
          child: Stack(
            children: 
              [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration( borderRadius: BorderRadius.circular(10), color: typeColor),
                    child: Text(type.toUpperCase(), style: TextStyle(fontSize: 11, color: Colors.white, ))
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Form(  
                    key: _formKey,  
                    child: Column(  
                      crossAxisAlignment: CrossAxisAlignment.start,  
                      children: <Widget>[  
                        TextFormField(  
                          readOnly: true,
                          initialValue: record['name'],
                          decoration: const InputDecoration(  
                            icon: Icon(Icons.person),  
                            hintText: 'Enter your customer name',  
                            labelText: 'Name',  
                          ),  
                          validator: (value) {  
                            if (value!.isEmpty) {  
                              return 'Please enter some text';  
                            }  
                            return null;  
                          },  
                        ),  
                        TextFormField(  
                          initialValue: "${record['phone']}",
                          readOnly: true,
                          decoration: const InputDecoration(  
                            icon: const Icon(Icons.phone),  
                            hintText: 'Enter a phone number',  
                            labelText: 'Phone',  
                          ),  
                          validator: (value) {  
                            if (value!.isEmpty) {  
                              return 'Please enter valid phone';  
                            }  
                            return null;  
                          },  
                        ), 
                        TextFormField(  
                          initialValue: "${record['street']}",
                          readOnly: true,
                          decoration: const InputDecoration(  
                            icon: const Icon(Icons.phone),  
                            hintText: 'Enter a phone number',  
                            labelText: 'Street',  
                          ),  
                          validator: (value) {  
                            if (value!.isEmpty) {  
                              return 'Please enter valid phone';  
                            }  
                            return null;  
                          },  
                        ),  
                        TextFormField(  
                          initialValue: "${record['city']}",
                          readOnly: true,
                          decoration: const InputDecoration(  
                            icon: const Icon(Icons.phone),  
                            hintText: 'Enter a city number',  
                            labelText: 'City',  
                          ),  
                          validator: (value) {  
                            if (value!.isEmpty) {  
                              return 'Please enter city';  
                            }  
                            return null;  
                          },  
                        ),  
                        TextFormField(  
                          initialValue: record['country_id'] is List ? record['country_id'][1]:'',
                          readOnly: true,                
                          decoration: const InputDecoration(  
                          icon: const Icon(Icons.abc),  
                          hintText: 'Enter your payment terms',  
                          labelText: 'Country',  
                          ),  
                          validator: (value) {  
                            if (value!.isEmpty) {  
                              return 'Please enter valid date';  
                            }  
                            return null;  
                          },  
                        ),  
                        // TextFormField(  
                        //   initialValue: "${record['currency_id'][1]} ${record['amount_total']}",
                        //   readOnly: true,
                        //   decoration: const InputDecoration(  
                        //     icon: Icon(Icons.money_rounded),  
                        //     hintText: 'Enter your date of birth',  
                        //     labelText: 'Total',  
                        //   ),  
                        //   validator: (value) {  
                        //     if (value!.isEmpty) {  
                        //       return 'Please enter valid date';  
                        //     }  
                        //     return null;  
                        //   },  
                        // )
                        
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
        // SizedBox(
        //   height: 300,
        //   child: Column(
        //     children: [
        //       FutureBuilder(
        //         future: getOrderLies(context, lines),
        //         builder: (context, AsyncSnapshot<dynamic> snapshot) {
        //           if (snapshot.hasData) {
        //             if (snapshot.data!=null) {                  
        //               return Expanded(
        //                 child: ListView.builder(
        //                   itemCount: snapshot.data.length,
        //                   itemBuilder: (BuildContext context, int index) {
        //                     final record = snapshot.data[index] as Map<String, dynamic>;
        //                     return buildListItem(record);
        //                   }),
        //               );
        //             } else {
        //               return Container(child:CircularProgressIndicator());
        //             }
        //           }
        //           else{
        //             return Container(child: Text('no data'),);
        //           }
        //         },
        //       ),
        //     ],
        //   ),
        // ),
        
        ]
    );
  }


  Widget buildListItem(Map<String, dynamic> record) {
    var unique = record['__last_update'] as String;
    unique = unique.replaceAll(RegExp(r'[^0-9]'), '');

    final productUrl ='${client?.baseURL}/web/image?model=product.template&field=image&id=${record["product_id"][0]}&unique=$unique';
    
    return Card(
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
