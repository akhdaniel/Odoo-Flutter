import 'package:flutter/material.dart';
import 'package:flutter_auth/Screens/Inventory/location.dart';
import 'package:flutter_auth/Screens/Inventory/picking.dart';
import 'package:flutter_auth/Screens/Inventory/warehouse.dart';
import 'package:flutter_auth/Screens/Partner/partner.dart';
import 'package:flutter_auth/Screens/Sales/sale_home.dart';
import 'package:flutter_auth/Screens/Welcome/welcome_screen.dart';
import 'package:flutter_auth/constants.dart';
import 'package:get/get.dart';

import 'Screens/Accounting/accounting_home.dart';
import 'Screens/Accounting/invoice.dart';
import 'Screens/Inventory/inventory_home.dart';
import 'Screens/Purchase/purchase_home.dart';
import 'Screens/Purchase/purchase_order.dart';
import 'Screens/Sales/sale_order.dart';
import 'controllers.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final Controller c = Get.put(Controller());
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Auth ${c.isLoggedIn}',
      theme: ThemeData(
          primaryColor: kPrimaryColor,
          scaffoldBackgroundColor: Colors.white,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              primary: kPrimaryColor,
              shape: const StadiumBorder(),
              maximumSize: const Size(double.infinity, 56),
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: kPrimaryLightColor,
            iconColor: kPrimaryColor,
            prefixIconColor: kPrimaryColor,
            contentPadding: EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              borderSide: BorderSide.none,
            ),
          )),
      home: const WelcomeScreen(),
      getPages: [
        GetPage(name: '/salesHome', page: () => const SalesHome()),
        GetPage(name: '/purchaseHome', page: () => const PurchaseHome()),
        GetPage(name: '/accountingHome', page: () => const AccountingHome()),
        GetPage(name: '/inventoryHome', page: () => const InventoryHome()),
        GetPage(name: '/purchaseOrder/:state', page: () => const PurchaseOrder()),
        GetPage(name: '/saleOrder/:state', page: () => const SaleOrder()),
        GetPage(name: '/partner/:type', page: () => const Partner()),
        GetPage(name: '/picking/:type', page: () => const Picking()),
        GetPage(name: '/warehouse', page: () => const Warehouse()),
        GetPage(name: '/location', page: () => const Location()),
        GetPage(name: '/invoice/:type', page: () => const Invoice()),
      ],
    );
  }
}
