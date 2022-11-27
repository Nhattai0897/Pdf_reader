import 'package:flutter/material.dart';

void customModalBottomSheet(BuildContext? ctx,
    {bool? isChupHinh = false,
    bool? isVideo = false,
    bool? isAlbum = false,
    bool? isFile = false,
    bool? isUrl = false,
    bool? isXemTapTin = false,
    bool? isXoaTapTin = false,
    Function()? fChupHinh,
    Function()? fVideo,
    Function()? fAlbum,
    Function()? fUrl,
    Function()? fFile,
    Function()? fXemTapTin,
    Function()? fXoaTapTin}) {
  showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
      context: ctx!,
      builder: (BuildContext ct) {
        return Container(
          height: 200.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                //margin: EdgeInsets.only(top: 20.0),
                child: Text(
                  'Chọn chức năng',
                  // style: CoreTextStyle.mediumTextFont(
                  //     color: Colors.blue, fontSize: CoreFontSize.defaultAddSix),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: isChupHinh ?? false,
                      child: Expanded(
                        child: ItemFunction(
                          pathImage: 'assets/mbs_camera.png',
                          title: 'Chụp hình',
                          function: fChupHinh,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isVideo ?? false,
                      child: Expanded(
                        child: ItemFunction(
                          pathImage: 'assets/mbs_video.png',
                          title: 'Quay video',
                          function: fVideo,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isAlbum ?? false,
                      child: Expanded(
                        child: ItemFunction(
                          pathImage: 'assets/mbs_album.png',
                          title: 'Bộ sưu tập',
                          function: fAlbum,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isFile ?? false,
                      child: Expanded(
                        child: ItemFunction(
                          pathImage: 'assets/storage_phone.png',
                          title: 'Chọn file',
                          function: fFile,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isXemTapTin ?? false,
                      child: Expanded(
                        child: ItemFunction(
                          pathImage: 'assets/mbs_view_file.png',
                          title: 'Xem tập tin',
                          function: fXemTapTin,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isXoaTapTin ?? false,
                      child: Expanded(
                        child: ItemFunction(
                          pathImage: 'assets/mbs_delete_file.png',
                          title: 'Xoá tập tin',
                          function: fXoaTapTin,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isUrl ?? false,
                      child: Expanded(
                        child: ItemFunction(
                          pathImage: 'assets/url.png',
                          title: 'Url link',
                          function: fUrl,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      });
}

class ItemFunction extends StatelessWidget {
  String? pathImage;
  String? title;
  Function()? function;

  ItemFunction({Key? key, this.pathImage, this.title, this.function})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 5.0),
              child: Image.asset(
                pathImage.toString(),
                height: 65.0,
                width: 65.0,
              ),
            ),
            Text(
              title.toString(),
            ),
          ],
        ),
      ),
      onTap: function,
    );
  }
}
