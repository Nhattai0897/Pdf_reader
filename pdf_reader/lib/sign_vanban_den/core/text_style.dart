import 'dart:ui';
import 'package:flutter/material.dart';
import 'colors.dart';

class CoreFontFamily {
  static String? bold;
  static String? boldItalic;
  static String? italic;
  static String? regular;
  static String? semiBold;
  static String? medium;
}

class CoreTextStyle {
  static TextStyle regularTextFont(
          {Color? color, double? fontSize, TextDecoration? textDecoration}) =>
      TextStyle(
          fontFamily: CoreFontFamily.regular,
          decoration: textDecoration ?? TextDecoration.none,
          fontSize: fontSize ?? CoreFontSize.defaultSize,
          color: color ?? CoreColors.textColor,
          height: 1.2);

  static TextStyle boldTextFont({Color? color, double? fontSize}) => TextStyle(
        fontFamily: CoreFontFamily.bold,
        fontSize: fontSize ?? CoreFontSize.defaultSize,
        color: color ?? Color(0xff1f274a),
      );

  static TextStyle boldItalicTextFont({Color? color, double? fontSize}) =>
      TextStyle(
        fontFamily: CoreFontFamily.boldItalic,
        fontSize: fontSize ?? CoreFontSize.defaultSize,
        color: color ?? CoreColors.textColor,
      );

  static TextStyle italicTextFont({Color? color, double? fontSize}) => TextStyle(
        fontFamily: CoreFontFamily.italic,
        fontSize: fontSize ?? CoreFontSize.defaultSize,
        color: color ?? CoreColors.textColor,
      );

  static TextStyle semiBoldTextFont({Color? color, double? fontSize}) =>
      TextStyle(
        fontFamily: CoreFontFamily.semiBold,
        fontSize: fontSize ?? CoreFontSize.defaultSize,
        color: color ?? CoreColors.textColor,
      );
  static TextStyle mediumTextFont({Color? color, double? fontSize}) => TextStyle(
        fontFamily: CoreFontFamily.medium,
        fontSize: fontSize ?? CoreFontSize.defaultSize,
        color: color ?? CoreColors.textColor,
      );
}

class CoreFontSize {
  static double? defaultSize;
  static double? defaultSubTwo;
  static double? defaultAddTwo; // Kích cỡ mặc định
  static double? defaultAddFour; // Kích cỡ dành cho tiêu đề
  static double? defaultAddSix;
  static double? defaultAddEight;
  static double? defaultAddTen;
  static double? defaultAddTwelve;

  // static void setInitFontSize(BuildContext context) {
  //   var _dataTemp = 16.0;
  //   defaultSize = ConvertFontSize(context: context, fontSize: _dataTemp / 4);

  //   defaultSubTwo =
  //       ConvertFontSize(context: context, fontSize: (_dataTemp - 2.0) / 4);
  //   defaultAddTwo =
  //       ConvertFontSize(context: context, fontSize: (_dataTemp + 2.0) / 4);
  //   defaultAddFour =
  //       ConvertFontSize(context: context, fontSize: (_dataTemp + 4.0) / 4);
  //   defaultAddSix =
  //       ConvertFontSize(context: context, fontSize: (_dataTemp + 6.0) / 4);
  //   defaultAddEight =
  //       ConvertFontSize(context: context, fontSize: (_dataTemp + 8.0) / 4);
  //   defaultAddTen =
  //       ConvertFontSize(context: context, fontSize: (_dataTemp + 10.0) / 4);
  //   defaultAddTwelve =
  //       ConvertFontSize(context: context, fontSize: (_dataTemp + 12.0) / 4);
  // }

  // static double ConvertFontSize({BuildContext context, double fontSize = 4.0}) {
  //   return MediaQuery.of(context).size.width * (fontSize / 100);
  // }
}
