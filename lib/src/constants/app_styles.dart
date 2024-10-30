import 'dart:math';

import 'package:flutter/material.dart';

const Color kColorWhite = Color(0xFFFFFFFF);
const Color kColorBlack = Color(0xFF000000);
const Color kColorGrey = Color(0XFFA7A7A7);


// ------------------------ Message -------------------------------- //

const Color mColorIcon = Color(0XFF9095A0);

Color getRandomColor() {
  Random random = Random();
  return Color.fromRGBO(
    random.nextInt(256),
    random.nextInt(256),
    random.nextInt(256),
    1,
  );
}



const kEnableBorder = OutlineInputBorder(
  borderSide: BorderSide(color: kColorBlack, width: 1),
  borderRadius: BorderRadius.all(Radius.circular(15)),
);
const kFocusBorder = OutlineInputBorder(
  borderSide: BorderSide(color: kColorBlack, width: 1),
  borderRadius: BorderRadius.all(Radius.circular(15)),
);