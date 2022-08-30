import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../constants.dart';
import '../controllers.dart';
final Controller c = Get.find();


class ObjectBottomNavBar extends GetView<Controller> {
  const ObjectBottomNavBar({
    Key? key,
    required this.onSave,
    required this.onEdit,
    required this.onConfirm,

    required this.showConfirm,
    required this.showEdit,
    required this.showSave

  }) : super(key: key);

  final VoidCallback onSave;
  final VoidCallback onEdit;
  final VoidCallback onConfirm;

  final bool showConfirm;
  final bool showEdit;
  final bool showSave;


  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      height: 80,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Visibility(
            visible: showEdit,
            child: BottomNavItem(
              title: "Edit",
              svgScr: "assets/icons/edit-svgrepo-com.svg",
              isActive: false,
              press: onEdit,
            ),
          ),
          Obx(()=>BottomNavItem(
            isActive: false,
            title: controller.isLoading.value?"Uploading...":"Save",
            svgScr: "assets/icons/save-svgrepo-com.svg",
            press: controller.isLoading.value?(){}:onSave,
          )),
          Visibility(
            visible: showConfirm,
            child: BottomNavItem(
              title: "Confirm",
              svgScr: "assets/icons/check-svgrepo-com.svg",
              press: onConfirm,
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  final String svgScr;
  final String title;
  final VoidCallback press;
  final bool isActive;
  const BottomNavItem({
    Key? key,
    this.svgScr='',
    this.title='',
    required this.press,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          SvgPicture.asset(
            svgScr,
            width:40,
            color: isActive ? kActiveIconColor : kTextColor,
          ),
          Text(
            title,
            style: TextStyle(color: isActive ? kActiveIconColor : kTextColor),
          ),
        ],
      ),
    );
  }
}
