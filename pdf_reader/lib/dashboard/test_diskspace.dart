// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:path_provider_ex/path_provider_ex.dart';
 

// class MyAppDispace extends StatefulWidget{
//   @override
//   _MyAppDispaceState createState() => _MyAppDispaceState();
// }

// class _MyAppDispaceState extends State<MyAppDispace> {
//   List<StorageInfo> storageInfo = [];

//   @override
//   void initState() {
//     Future.delayed(Duration.zero, () async {
//          try {
//               storageInfo = await PathProviderEx.getStorageInfo();
//               /*
//                storageInfo[0] => Internal Storeage
//                storageInfo[1] => SD Card Storage
//               */ 
//               setState(() {}); //update UI
//          } on PlatformException {
//             print("Error while getting paths.");
//          }

//     });
//     super.initState();
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//           appBar: AppBar(
//               title:Text("Get Internal And SD Card Path"),
//               backgroundColor: Colors.redAccent,
//           ),
//           body: Padding( 
//              padding: EdgeInsets.all(20),
//              child:Column(
//               children: <Widget>[
//                 Text( 'Internal Storage root: ${(storageInfo.length > 0) ? storageInfo[0].rootDir : "unavailable"}\n'),
//                 Text('Internal Storage appFilesDir:${(storageInfo.length > 0) ? storageInfo[0].appFilesDir : "unavailable"}\n'),
//                 Text('Internal Storage AvailableGB: ${(storageInfo.length > 0) ? storageInfo[0].availableGB : "unavailable"}\n'),
//                 Text( 'SD Card root: ${(storageInfo.length > 1) ? storageInfo[1].rootDir : "unavailable"}\n'),
//                 Text('SD Card appFilesDir: ${(storageInfo.length > 1) ? storageInfo[1].appFilesDir : "unavailable"}\n'),
//                 Text('SD Card AvailableGB: ${(storageInfo.length > 1) ? storageInfo[1].availableGB : "unavailable"}\n'),
//               ]
//              )
//           )
//       );
//   }
// }