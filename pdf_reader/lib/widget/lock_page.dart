import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class LockPage extends StatefulWidget {
  final BuildContext ctx;

  LockPage({
    Key? key,
    required this.ctx,
  }) : super(key: key);

  @override
  _LockPageState createState() => _LockPageState();
}

class _LockPageState extends State<LockPage> with TickerProviderStateMixin {
  var screenWidth, screenHeight;
  bool isZoom = false;

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance!.addPostFrameCallback((_) async => {
          setState(() => isZoom = true),
          await Future.delayed(Duration(milliseconds: 1500)),
          Navigator.pop(context),
        });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Colors.black.withOpacity(0.1),
        body: Center(
            child: AnimatedSize(
          curve: Curves.easeInOutCirc,
          vsync: this,
          duration: new Duration(milliseconds: 200),
          child: Container(
            width: isZoom ? 150 : 0,
            height: isZoom ? 150 : 0,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Color.fromRGBO(51, 204, 204, 1.0),
                  width: 3,
                ),
                borderRadius: BorderRadius.all(Radius.circular(100.0))),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 23.0, right: 23.0, bottom: 20, top: 27),
              child: Image.asset('assets/lock_file.gif'),
            ),
          ),
        )));
  }
}
