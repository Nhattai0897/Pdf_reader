import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_reader/dashboard/onboarding_intro.dart';
import 'package:pdf_reader/sign_vanban_den/model/pdf_result.dart';
import 'package:pdf_reader/utils/base_multi_language.dart';
import 'package:pdf_reader/utils/shared_prefs.dart';

import 'dashboard/dashboard_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Get path docdument
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  // Initialize hive
  Hive.init(appDocumentDirectory.path);
  // Registering the adapter
  Hive.registerAdapter(PDFModelAdapter());
  // Opening the box
  await Hive.openBox('pdfBox', keyComparator: _reverseOrder);
  await Hive.openBox('pdfPriavteBox', keyComparator: _reverseOrder);
  await Hive.openBox('countPermisBox');
  await Hive.openBox('introuctionBox');
  await SharedPrefs.initializer();
  var isFirst = setupIntroduction();
  runApp(MyHomePage(isFirst: isFirst));
}

bool setupIntroduction() {
  final Box conutPermissBox = Hive.box('introuctionBox');
  return conutPermissBox.get('isFirst') ?? true;
}

//Sort by Datetime
int _reverseOrder(k1, k2) {
  if (k1 is int) {
    if (k2 is int) {
      if (k1 > k2) {
        return -1;
      } else if (k1 < k2) {
        return 1;
      } else {
        return 0;
      }
    } else {
      return -1;
    }
  } else {
    return 0;
  }
}

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  var isFirst;
  MyHomePage({required this.isFirst});
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
        title: 'PDF Editor',
        localizationsDelegates: [LanguageDelegate()],
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.deepPurple),
        home: widget.isFirst ? OnBoardingPage() : DashboardHome());
  }
}
