import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../constants.dart';
import '../../controllers.dart';
import '../header.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/menu.dart';
import 'widgets/search_bar.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import '../../shared_prefs.dart';

final Controller c = Get.find();

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  void getUsers() async {
    final prefs = SharedPref();
    final sobj = await prefs.readObject('session');
    final session = OdooSession.fromJson(sobj);
    final client = OdooClient(c.baseUrl.toString(), session);
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
      // print('\nUser info: \n' + res[0].toString());
      c.setCurrentUser(res[0]['userName']);

    } catch (e) { 
      client.close();
      print(e);
      // showDialog(context: context, builder: (context) {
      //   return SimpleDialog(
      //       children: <Widget>[
      //             Center(child: Text(e.toString()))
      //       ]);
      // });
    }
    
  }

  @override
  Widget build(BuildContext context) {     

    getUsers();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Odoo App',
      theme: ThemeData(
        fontFamily: "Cairo",
        scaffoldBackgroundColor: kPrimaryLightColor,
        textTheme: Theme.of(context).textTheme.apply(displayColor: kTextColor),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size; //this gonna give us total height and with of our device
    var username = c.currentUser.toString();
    return Scaffold(
      bottomNavigationBar: const BottomNavBar(),
      body: Stack(
        children: <Widget>[
          Header(size: size),
          Body(username: username)
        ],
      ),
    );
  }
}

class Body extends StatelessWidget {
  const Body({
    Key? key,
    required this.username,
  }) : super(key: key);

  final String? username;

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
            Align(
              alignment: Alignment.topRight,
              child: Container(
                alignment: Alignment.center,
                height: 52,
                width: 52,
                decoration: const BoxDecoration(
                  color: kTextColor,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset("assets/icons/menu.svg"),
              ),
            ),
            Text(
              "Good Morning",
              style:TextStyle(fontSize: 25, fontWeight: FontWeight.w100, color: Colors.white),
            ),
            Text(
              "$username",
              style:TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: Colors.white),
            ),
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

