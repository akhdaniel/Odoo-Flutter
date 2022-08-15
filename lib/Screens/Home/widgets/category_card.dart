import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants.dart';

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback press;
  CategoryCard({
    Key? key,
    required this.icon,
    required this.iconColor,
    this.title='',
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            offset: Offset(5, 5),
            blurRadius: 5,
            spreadRadius: -5,
            color: Colors.black,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: press,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Spacer(),
                Icon(icon, size: 50, color: iconColor ),
                Spacer(),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  // style: Theme.of(context)
                  //     .textTheme
                  //     .title
                  //     .copyWith(fontSize: 15),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
