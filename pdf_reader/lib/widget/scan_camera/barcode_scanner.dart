import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf_reader/utils/base_multi_language.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanQRCode extends StatefulWidget {
  late String titleGuide;
  ScanQRCode({Key? key, required this.titleGuide}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ScanQRCodeState();
}

class _ScanQRCodeState extends State<ScanQRCode> with TickerProviderStateMixin {
  Barcode? result;
  bool isGranted = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  // QRcontroller
  QRViewController? controller;

  // RedLine controller
  late AnimationController controllerLine;
  late Animation<Offset> offset;

  // Fram QR size controller

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  void dispose() {
    controllerLine.dispose();
    controller?.dispose();
    super.dispose();
  }

  @override
  // ignore: must_call_super
  void initState() {
    controllerLine = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1700));
    offset = Tween<Offset>(begin: Offset.zero, end: Offset(0.0, 2.0))
        .animate(controllerLine);
    controllerLine.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar();
    double heightAppbar = appBar.preferredSize.height;
    ThemeData themeData = Theme.of(context);
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
            child: Stack(
          children: [
            Column(
              children: [
                buildAppbar(heightAppbar, context, themeData),
                Expanded(child: _buildQrView(context)),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 5.7,
                      left: 16.0,
                      right: 16.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      widget.titleGuide == ""
                          ? Language.of(context)!.trans("GuideCamera") ?? ""
                          : widget.titleGuide,
                      textAlign: TextAlign.center,
                      style: themeData.textTheme.headline4!.copyWith(
                          color: Colors.white.withOpacity(0.8), fontSize: 15.0),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50.0),
                        child: Container(
                          color: Color.fromRGBO(246, 246, 246, 1.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              "assets/icon_app.png",
                              height: 30,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Stack(
                          children: [
                            Hero(
                              tag: Language.of(context)!.trans("scanQR") ?? "",
                              child: Image.asset(
                                "assets/qr-code.png",
                                width: 43,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 12.6, top: 20.0),
                              child: Image.asset(
                                "assets/qr-code.gif",
                                width: 14.2,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        )));
  }

  Container buildAppbar(
      double heightAppbar, BuildContext context, ThemeData themeData) {
    return Container(
      height: heightAppbar,
      color: Colors.grey[900],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              )),
          Text(
            Language.of(context)!.trans("ScanTitle") ?? "",
            textAlign: TextAlign.center,
            style: themeData.textTheme.headline4!
                .copyWith(color: Colors.white.withOpacity(0.8), fontSize: 18.0),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: IconButton(
                onPressed: () async {
                  await controller?.toggleFlash();
                },
                icon: FutureBuilder(
                  future: controller?.getFlashStatus(),
                  builder: (context, snapshot) {
                    bool isSwitch = false;
                    if (snapshot.data != null) {
                      isSwitch = snapshot.data as bool;
                    }
                    return Image.asset(
                      isSwitch ? "assets/flash-off.png" : "assets/flash-on.png",
                      height: 22,
                    );
                  },
                )),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    bool isLarge = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400);
    var scanArea = isLarge ? 240.0 : 200.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    var redLine = Container(
      child: Padding(
        padding: EdgeInsets.all(47.0),
        child: Container(width: scanArea - 32, height: 1.0, color: Colors.red),
      ),
    );
    return Stack(
      children: [
        QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
              borderColor: Color.fromRGBO(118, 71, 248, 1.0),
              borderRadius: 8,
              borderLength: 30,
              borderWidth: 8,
              cutOutSize: scanArea),
          onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
        ),
        Center(
          child: Container(
            height: isLarge ? scanArea + 45 : scanArea + 80,
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SlideTransition(
                  position: offset,
                  child: redLine,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  void _requestMobilePermission() async {
    var isAccept = await Permission.camera.request().isGranted;
    if (isAccept) {
      setState(() {
        isGranted = true;
      });
    } else {
      isGranted = true;
      toastMessage(message: Language.of(context)!.trans("CameraGranted") ?? "");
      Navigator.of(context).pop();
    }
  }

  void toastMessage({required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      controller.stopCamera();
      Navigator.pop(context, scanData.code);
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    // log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      toastMessage(message:  Language.of(context)!.trans("CameraGranted") ??
              "");
      Navigator.of(context).pop();
    }
  }
}
