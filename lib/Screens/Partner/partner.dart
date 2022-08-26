import 'package:flutter/material.dart';
import 'package:flutter_auth/components/top_right_menu.dart';
import 'package:get/get.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

import '../../constants.dart';
import '../../controllers.dart';
import '../../shared_prefs.dart';
import '../Home/widgets/search_bar.dart';
import '../header.dart';
final Controller c = Get.find();

class Partner extends StatelessWidget {
  
  const Partner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Odoo App',
      theme: ThemeData(
        fontFamily: "Cairo",
        scaffoldBackgroundColor: kPrimaryLightColor,
        textTheme: Theme.of(context).textTheme.apply(displayColor: kTextColor),
      ),
      home: PartnerScreen(),
    );
  }
}

class PartnerScreen extends StatelessWidget {
  const PartnerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size*0.5; //this gonna give us total height and with of our device
    var type = Get.parameters['type'] ?? 'customer';

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Header(size: size),
          Body(title: "Partner", subtitle: type, type: type)
        ],
      ),
    );
  }
}


class Body extends StatelessWidget {
  Body({
    Key? key,
    required this.type,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  final String? type;
  final String? title;
  final String? subtitle;

  OdooSession? session ;
  OdooClient? client ;


  getPartners(context, type) async {
    final prefs = SharedPref();
    final sobj = await prefs.readObject('session');
    session = OdooSession.fromJson(sobj);
    client = OdooClient(c.baseUrl.toString(), session);
    var domain;
    if (type=='customer')
      domain = ['customer','=',true];
    else
      domain = ['supplier','=',true];
    try {
      return await client?.callKw({
        'model': 'res.partner',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            domain
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
              "$subtitle".toUpperCase(),
              style:TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SearchBar(),
            FutureBuilder(
              future: getPartners(context, type),
              builder: (context, AsyncSnapshot<dynamic>  orderSnapshot) {
                if (orderSnapshot.hasData) {
                  // print(orderSnapshot.data[0].toString());
                  if (orderSnapshot.data!=null) {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: orderSnapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          // SaleOrderModel saleOrder = orderSnapshot.data[index];
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
      ),
    );
  }



  Widget buildListItem(Map<String, dynamic> record) {
    var unique = record['__last_update'] as String;
    unique = unique.replaceAll(RegExp(r'[^0-9]'), '');

    // print(record.toString());
    final avatarUrl ='${client?.baseURL}/web/image?model=res.partner&field=image&id=${record["id"]}&unique=$unique';
    var city = record['city'];
    // print(city);
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(avatarUrl)),
      title: Text(record['name']),
      subtitle: Text(city==false?'':city, style: TextStyle(fontWeight: FontWeight.bold),),
    );
  }

}

