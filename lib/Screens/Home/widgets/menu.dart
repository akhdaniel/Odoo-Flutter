import 'package:flutter/material.dart';
import 'package:flutter_auth/Screens/Sales/sale_home.dart';
import 'package:get/get.dart';

import 'category_card.dart';


class GridMenu extends StatelessWidget {
  List menus;

  GridMenu({
    Key? key,
    required this.menus
  }) : super(key: key);
  

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: menus.length,
      itemBuilder: (BuildContext context, int index) {
        return CategoryCard(
           title: menus[index]['name'],
            icon: menus[index]['icon'],
            iconColor: menus[index]['iconColor'],
            press: () {
              print(menus[index]['route']);
              Get.toNamed(menus[index]['route']);
            }, 
        );
      },
    );
  }
}

