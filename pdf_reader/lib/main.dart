import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_reader/sign_vanban_den/model/pdf_result.dart';
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
  runApp(MyApp());
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

class MyApp extends StatelessWidget {
  // This widget is the root of your application
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: DashboardHome());
  }
}
