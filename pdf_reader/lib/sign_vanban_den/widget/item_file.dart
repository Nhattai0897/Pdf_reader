import 'package:flutter/material.dart'; 

class ItemFileThem extends StatelessWidget {
  double? heightItem, widthItem;
  String? pathStr, tenFile;
  Function? fDelFile, fXemFile;

  ItemFileThem({
    Key? key,
    this.heightItem,
    this.widthItem,
    this.tenFile,
    this.pathStr,
    this.fDelFile,
    this.fXemFile,
  }) : super(key: key);

  //final getIt = GetIt.instance;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        fXemFile!();
      },
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        margin: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
        ),
        //padding: EdgeInsets.all(8.0),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(pathStr!,
                  fit: BoxFit.cover, width: double.infinity, height: 150),
            ),

            Positioned(
              right: 15.0,
              top: 10.0,
              child: Icon(
                Icons.close,
                color: Colors.red,
              ),
            )

            // Container(
            //   //  color: Colors.red,
            //   width: double.infinity,
            //   child: Text(
            //     tenFile,
            //     overflow: TextOverflow.ellipsis,
            //     maxLines: 1,
            //     style: CoreTextStyle.mediumTextFont(),
            //   ),
            // ),
            // InkWell(
            //   onTap: () {
            //     fDelFile();
            //   },
            //   child: Icon(
            //     Icons.close,
            //     color: CoreColors.colortext2,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
