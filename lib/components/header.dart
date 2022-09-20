import 'package:flutter/material.dart';

import '../constants.dart';


class Header extends StatelessWidget {
  const Header({
    Key? key,
    required this.size,
  }) : super(key: key);

  final Size size;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: MyClipper(),
      child: Container(
        // Here the height of the container is 45% of our total height
        height: size.height * .55,
        decoration: const BoxDecoration(
          color: kPrimaryColor,
          image: DecorationImage(
            alignment: Alignment.centerLeft,
            image: AssetImage("assets/images/undraw_pilates_gpdb.png"),
          ),
        ),
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 140);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

