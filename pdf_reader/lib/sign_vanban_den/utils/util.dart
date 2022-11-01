 
import 'package:intl/intl.dart'; 

class Util {
  ///get đuôi file và lấy icon default tương ứng
  static String? getIconFile(String pathFile) {
    var typeFile = pathFile.split('.').last;
    // print('getIconFile - $pathFile');
    // print('typeFile - $typeFile');
    switch (typeFile.toLowerCase()) {
      case "jpg":
      case "png":
        return "assets/filetxt.png";
      case "xlsx":
        return "assets/filexls.png"; 
      case "docx":
      case "doc":
        return "assets/filedoc.png";
      case "pdf":
        return "assets/filepdf.png";
      case "ppt":
        return "assets/fileppt.png";
      case "mp4":
        return "assets/filevideo.png";
      default:
        return "assets/filenotfound.png";
    }
  }

   static DateTime? convertStringToDateWithFormat(String date, String format) {
    var _fm = DateFormat(format);
    return _fm.parse(date);
  }
}

enum MediaLoaiChucNangDinhKem { Camera, Album, Video, File }