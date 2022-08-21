import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../constants.dart';

class WelcomeImage extends StatelessWidget {
  const WelcomeImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: defaultPadding * 2),
        Text(
          "Odoo Mobile",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        Row(
          children: [
            Spacer(),
            Expanded(
              flex: 8,
              // child: Image.asset('assets/images/meditation_bg.png')
              child: SvgPicture.asset(
                "assets/icons/scenes05.svg",
                width: 200, height: 300,
              ),
            ),
            Spacer(),
          ],
        ),
        // SizedBox(height: defaultPadding * 2),
      ],
    );
  }
}