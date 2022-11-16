import 'package:intl/intl.dart';

class FormatDateAndTime {
  String FormatDateToString(DateTime date) {
    String stringDate;
    stringDate = DateFormat("dd/MM/yyyy").format(date);
    return stringDate;
  }

  String FormatTimeToString24h(DateTime time) {
    String stringTime;
    stringTime = DateFormat("HH:mm").format(time);
    return stringTime;
  }

  String FormatDateAndTimeToString(DateTime dateTime) {
    String stringDateTime;
    stringDateTime = DateFormat("HH:mm dd/MM/yyyy").format(dateTime);
    return stringDateTime;
  }

  String FormatMilliseconds(int milliseconds) {
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(milliseconds);
    String dateString = DateFormat("dd/MM/yyyy").format(date);
    return dateString;
  }


  static DateTime convertStringToDateWithFormat(String date, String format) {
    var _fm = DateFormat(format);
    return _fm.parse(date);
  }
 
 static String convertDatetoStringWithFormat(DateTime date, String format) {
    var _fm = DateFormat(format);
    return _fm.format(date);
  }
  //// Check phone number
  static int vietnamPhoneNumberValidate(String phoneNumber) {
    int state = 0;
    RegExp regExp =
        new RegExp(r'^(3[2-9]|5[689]|7[06789]|8[12345689]|9[0-9])[0-9]{7}$');
    String rawPhoneNumber = phoneNumber.replaceAll(new RegExp(r'[+ #*-.]'), '');
    if (phoneNumber.isEmpty || phoneNumber == '' || phoneNumber == null) {
      state = 0;
    } else if (phoneNumber.startsWith('+84') && rawPhoneNumber.length == 11) {
      String temp = rawPhoneNumber.replaceFirst('84', '');
      state = regExp.hasMatch(temp) ? 1 : 2;
    } else if (phoneNumber.startsWith('0') && rawPhoneNumber.length == 10) {
      String temp = rawPhoneNumber.replaceFirst('0', '');
      state = regExp.hasMatch(temp) ? 1 : 2;
    } else {
      state = 2;
    }
    return state;
  }

////////Check Phone Number

  static bool validatePhoneNumber(String phoneNumber) {
    Pattern pattern = r'^[0-9]+$';
    RegExp regex = new RegExp(pattern.toString());
    if (phoneNumber.length <= 9 || phoneNumber.length > 13) {
      return false;
    }

    return regex.hasMatch(phoneNumber) &&
        ((phoneNumber.length == 10 && phoneNumber[0] == "0") ||
            (phoneNumber.length == 11 && phoneNumber[0] == "0") ||
            (phoneNumber.length == 12 && phoneNumber[0] == "0") ||
            (phoneNumber.length == 13 && phoneNumber[0] == "0") ||
            (phoneNumber.length == 9 && phoneNumber[0] != "0"));
  }
}
