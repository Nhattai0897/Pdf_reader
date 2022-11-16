import 'package:flutter/material.dart';

class NoDataScreen extends StatelessWidget {
  double? heightScreen;
  bool? isVisible;
  String? imagePath;
  String? content;
  Color? colorContent, colorImage;

  NoDataScreen({
    this.heightScreen,
    @required this.isVisible,
    this.imagePath,
    this.content,
    this.colorContent,
    this.colorImage,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible!,
      child: Container(
        height: heightScreen != 0 ? heightScreen : 175.0,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (imagePath == null || imagePath!.trim() == '')
                ? SizedBox()
                : Column(
                    children: [
                      Image.asset(
                        imagePath!,
                        height: 75,
                        width: 75,
                        color: colorImage ?? Colors.black,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
            Text(
              content ?? "Không có dữ liệu",
              // style: ConfigTextStyle.regularStyle(
              //     fontSize: ConfigFontSize.defaultAddTwo,
              //     color: colorContent ?? Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
