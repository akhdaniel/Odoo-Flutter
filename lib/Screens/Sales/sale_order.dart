import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

import '../../components/controllers.dart';
import '../../components/header.dart';
import '../../constants.dart';
import '../../shared_pref.dart';
import '../Home/search_bar.dart';

final Controller c = Get.find();

class SaleOrder extends StatelessWidget {
  
  const SaleOrder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Odoo App',
      theme: ThemeData(
        fontFamily: "Cairo",
        scaffoldBackgroundColor: kPrimaryLightColor,
        textTheme: Theme.of(context).textTheme.apply(displayColor: kPrimaryColor),
      ),
      home: SaleOrderScreen(),
    );
  }
}

class SaleOrderScreen extends StatelessWidget {
  const SaleOrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size*0.5; //this gonna give us total height and with of our device
    var state = Get.parameters['state'] ?? 'draft';
    var states = state=='draft'?['draft','sent']:['sale','done','cancel'];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: <Widget>[
          Header(size: size),
          Body(title: "Sale Order", subtitle: state, states: states)
        ],
      ),
    );
  }
}


class Body extends StatelessWidget {
  Body({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.states,
  }) : super(key: key);


  final String? title;
  final String? subtitle;
  List states;
  // List orders = [];

  OdooSession? session ;
  OdooClient? client ;

  getOrders(context, states) async {
    final prefs = SharedPref();
    final sobj = await prefs.readObject('session');
    final baseUrl = await prefs.readString('baseUrl');
    session = OdooSession.fromJson(sobj);
    client = OdooClient(baseUrl.toString(), session);
    try {
      return await client?.callKw({
        'model': 'sale.order',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['state', 'in', states]
          ],
          'fields': ['id', 'name', 'partner_id', 'state', 'currency_id', 'amount_total', '__last_update', 'amount_total'],
          'limit':100,
          'offset':0
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
            Text(
              title??'',
              style:TextStyle(fontSize: 25, fontWeight: FontWeight.w100, color: Colors.white),
            ),
            Text(
              "$subtitle".toUpperCase(),
              style:TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SearchBar(),
            FutureBuilder(
              future: getOrders(context, states),
              builder: (context, AsyncSnapshot<dynamic>  orderSnapshot) {
                if (orderSnapshot.hasData) {
                  if (orderSnapshot.data!=null) {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: orderSnapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          final record = orderSnapshot.data[index] as Map<String, dynamic>;
                          return buildListItem(record);
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

  Widget buildListItem(Map<String, dynamic> record) {
    var unique = record['__last_update'] as String;
    unique = unique.replaceAll(RegExp(r'[^0-9]'), '');
    final avatarUrl ='${client?.baseURL}/web/image?model=res.partner&field=image&id=${record["partner_id"][0]}&unique=$unique';
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
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        onTap: () {
          Get.toNamed( '/saleOrderView/${record['id']}' );
        },
        leading: CircleAvatar(backgroundImage: NetworkImage(avatarUrl)),
        title: Text(record['name']),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration( borderRadius: BorderRadius.circular(10), color: stateColor),
              child: Text(record['state'].toUpperCase(), style: TextStyle(fontSize: 9, color: Colors.white, ),)
            ),
            Text(record['currency_id'][1] + ' ' + record['amount_total'].toString() ),
          ],
        ),
        subtitle: Text(record['partner_id'][1], style: TextStyle(fontWeight: FontWeight.bold),),
      ),
    );
  }

}
