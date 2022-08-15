import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../constants.dart';
import '../Home/widgets/search_bar.dart';
import '../header.dart';

class Warehouse extends StatelessWidget {
  
  const Warehouse({Key? key}) : super(key: key);

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
      home: WarehouseScreen(),
    );
  }
}

class WarehouseScreen extends StatelessWidget {
  const WarehouseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size*0.5; //this gonna give us total height and with of our device
    var type = Get.parameters['type'] ?? 'receiving';

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Header(size: size),
          Body(title: "Warehouse\n$type")
        ],
      ),
    );
  }
}


class Body extends StatelessWidget {
  const Body({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String? title;

  @override
  Widget build(BuildContext context) {
  //   final List<Map> menus = [
  //   {'name':'RFQ', 'route':'/Warehouse/draft', 'icon': Icons.public, 'iconColor': Colors.red[300]},
  //   {'name':'Purchase Order','route':'/Warehouse/confirmed',  'icon': Icons.shopping_basket, 'iconColor': Colors.orange[300]},
  //   {'name':'Vendors', 'route':'/vendors', 'icon': Icons.account_balance, 'iconColor': Colors.purple[300]},
  //   {'name':'Receiving','route':'/receiving',  'icon': Icons.warehouse, 'iconColor': Colors.blue[300]},
  //   {'name':'Bills','route':'/bills',  'icon': Icons.money, 'iconColor': Colors.green[300]},
  // ];
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
              title??'',
              style:TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SearchBar(),
            // Expanded(
            //   child: GridMenu(menus: menus),
            // ),
          ],
        ),
      ),
    );
  }
}

