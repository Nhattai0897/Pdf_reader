import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppbarCustomize {
  static PreferredSizeWidget buildAppbarBasic(
      {Key? key,
      required BuildContext context,
      required String title,
      List<Widget>? actionRights,
      List<Widget>? actionLefts,
      Widget? child,
      double? heightAppbar,
      Color? color}) {
    final double _heightAppbar = heightAppbar ?? AppBar().preferredSize.height;
    final double systemBarHeight = MediaQuery.of(context).padding.top;

    List<Widget> _actionLefts = (actionLefts != null)
        ? actionLefts
        : [
            SizedBox(
              width: 20.0,
            )
          ];

    List<Widget> _actionRights = (actionRights != null)
        ? actionRights
        : [
            SizedBox(
              width: 20.0,
            )
          ];

    return PreferredSize(
      preferredSize: Size.fromHeight(_heightAppbar),
      child: Card(
        margin: const EdgeInsets.all(0.0),
        shadowColor: Colors.black,
        color: color ?? Colors.blue,
        elevation: 2.0,
        borderOnForeground: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Column(
          children: [
            SizedBox(height: systemBarHeight),
            Container(
              child: (child != null)
                  ? child
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: 60.0,
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: _actionLefts,
                          ),
                        ),
                        Expanded(
                          child: Text(title,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(color: Colors.white)),
                        ),
                        Container(
                          width: 100.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: _actionRights,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
