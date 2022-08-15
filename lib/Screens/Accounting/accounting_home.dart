import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants.dart';
import '../Home/widgets/menu.dart';
import '../Home/widgets/search_bar.dart';
import '../header.dart';

class AccountingHome extends StatelessWidget {
  
  const AccountingHome({Key? key}) : super(key: key);

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
      home: AccountingHomeScreen(),
    );
  }
}

class AccountingHomeScreen extends StatelessWidget {
  const AccountingHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size*0.5; //this gonna give us total height and with of our device

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Header(size: size),
          Body(title: "Accounting Menu")
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
    final List<Map> menus = [
    {'name':'Invoices','route':'/invoice/customer',  'icon': Icons.money, 'iconColor': Colors.green[300]},
    {'name':'Vendor Bills','route':'/invoice/bill',  'icon': Icons.money, 'iconColor': Colors.blue[300]},
    {'name':'Payment','route':'/payment',  'icon': Icons.access_alarm_outlined, 'iconColor': Colors.deepOrange[300]},
    {'name':'Bank Book','route':'/bank',  'icon': Icons.comment_bank, 'iconColor': Colors.purple[300]},
    {'name':'Cash Book','route':'/cash',  'icon': Icons.card_membership, 'iconColor': Colors.orange[300]},
    {'name':'Journal Entry','route':'/journal',  'icon': Icons.add_chart, 'iconColor': Colors.blue[300]},
    {'name':'Reports','route':'/reports',  'icon': Icons.leaderboard , 'iconColor': Colors.red[300]},
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
              title??'',
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

