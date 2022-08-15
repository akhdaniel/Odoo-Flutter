import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants.dart';

class TopRightMenu extends StatelessWidget {
  const TopRightMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
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
    );
  }
}

