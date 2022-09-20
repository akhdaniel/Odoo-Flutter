import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

import '../../components/controllers.dart';
import '../../components/header.dart';
import '../../components/menu.dart';
import '../../constants.dart';
import '../../shared_pref.dart';
import 'search_bar.dart';

final Controller c = Get.find();

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {     

    getUsers(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Odoo App',
      theme: ThemeData(
        fontFamily: "Cairo",
        scaffoldBackgroundColor: kPrimaryLightColor,
        textTheme: Theme.of(context).textTheme.apply(displayColor: kPrimaryColor),
      ),
      home: HomeScreen(),
    );
  }


  void getUsers(context) async {
    final prefs = SharedPref();
    final sobj = await prefs.readObject('session');
    var baseUrl=await prefs.readString('baseUrl');

    final session = OdooSession.fromJson(sobj);
    final client = OdooClient(baseUrl, session);
    try {
      var res = await client.callKw({
        'model': 'res.users',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'context': {'bin_size': true},
          'domain': [
            ['id', '=', session.userId]
          ],
          'fields': ['id', 'name', '__last_update', 'image_small'],
        },
      });
      c.setCurrentUser(res[0]);

    } catch (e) { 
      client.close();
      showDialog(context: context, builder: (context) {
        return SimpleDialog(
            children: <Widget>[
                  Center(child: Text(e.toString()))
            ]);
      });
    }
    
  }

}

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size; //this gonna give us total height and with of our device
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Header(size: size),
          Body()
        ],
      ),
    );
  }
}

class Body extends StatelessWidget {
  Body({
    Key? key,
    // required this.username,
  }) : super(key: key);

  // final String? username;



  @override
  Widget build(BuildContext context) {

    final List<Map> menus = [
    {'name':'Sales', 'route':'/salesHome', 'icon': Icons.public, 'iconColor': Colors.red[300]},
    {'name':'Purchase','route':'/purchaseHome',  'icon': Icons.shopping_basket, 'iconColor': Colors.orange[300]},
    {'name':'Accounting', 'route':'/accountingHome', 'icon': Icons.account_balance, 'iconColor': Colors.purple[300]},
    {'name':'Inventory','route':'/inventoryHome',  'icon': Icons.warehouse, 'iconColor': Colors.blue[300]},
  ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            
            Text(
              "Good Morning",
              style:TextStyle(fontSize: 25, fontWeight: FontWeight.w100, color: Colors.white),
            ),
            Obx(()=>Text(
              "${c.currentUser.value['name']}",
              style:TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: Colors.white),
            )) ,
            const SearchBar(),
            Expanded(
              child: GridMenu(menus: menus),
            ),
          ],
        ),
      ),
    );
  }
}

