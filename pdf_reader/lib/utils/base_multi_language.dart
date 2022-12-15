import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf_reader/utils/shared_prefs.dart';

class Language {
  Language(this.locale);

  late Locale locale;

  static String code = "";

  late Map<String, String> _sentences;

  static Language? of(BuildContext context) {
    return Localizations.of<Language>(context, Language);
  }

  Future<bool> load() async {
    String path = 'assets/json/${this.locale.languageCode.toLowerCase()}.json';
    var data = await rootBundle.loadString(path);
    Map<String, dynamic> _result = json.decode(data);
    this._sentences = new Map();
    _result.forEach((String key, dynamic value) {
      this._sentences[key] = value.toString();
    });
    return true;
  }

  String? trans(String key) {
    return this._sentences[key];
  }
}

class LanguageDelegate extends LocalizationsDelegate<Language> {
  const LanguageDelegate();

  @override
  bool isSupported(Locale locale) => ['vi', 'en'].contains(locale.languageCode);

  @override
  Future<Language> load(Locale locale) async {
    var prf = SharedPrefs().getValue<dynamic>(KeyPrefs.localeCode);
    if (prf != null) {
      locale = Locale(prf);
    } else {
      SharedPrefs().setValue(KeyPrefs.localeCode, "EN");
      locale = Locale('en');
    }
    Language localizations = new Language(locale);
    await localizations.load();
    Language.code = locale.languageCode; 
    return localizations;
  }

  @override
  bool shouldReload(LanguageDelegate old) => false;
}
