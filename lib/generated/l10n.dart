// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `CourseTimetableRemake`
  String get appTitle {
    return Intl.message(
      'CourseTimetableRemake',
      name: 'appTitle',
      desc: '',
      args: [],
    );
  }

  /// `ADD/EDIT COURSE`
  String get mainPageDrawerAddEditSingle {
    return Intl.message(
      'ADD/EDIT COURSE',
      name: 'mainPageDrawerAddEditSingle',
      desc: '',
      args: [],
    );
  }

  /// `ADD/EDIT COURSES`
  String get mainPageDrawerAddEdit {
    return Intl.message(
      'ADD/EDIT COURSES',
      name: 'mainPageDrawerAddEdit',
      desc: '',
      args: [],
    );
  }

  /// `COPY COURSE`
  String get mainPageDrawerCopy {
    return Intl.message(
      'COPY COURSE',
      name: 'mainPageDrawerCopy',
      desc: '',
      args: [],
    );
  }

  /// `PASTE COURSE`
  String get mainPageDrawerPasteSingle {
    return Intl.message(
      'PASTE COURSE',
      name: 'mainPageDrawerPasteSingle',
      desc: '',
      args: [],
    );
  }

  /// `PASTE COURSES`
  String get mainPageDrawerPaste {
    return Intl.message(
      'PASTE COURSES',
      name: 'mainPageDrawerPaste',
      desc: '',
      args: [],
    );
  }

  /// `DELETE COURSES`
  String get mainPageDrawerDelete {
    return Intl.message(
      'DELETE COURSES',
      name: 'mainPageDrawerDelete',
      desc: '',
      args: [],
    );
  }

  /// `DELETE COURSE`
  String get mainPageDrawerDeleteSingle {
    return Intl.message(
      'DELETE COURSE',
      name: 'mainPageDrawerDeleteSingle',
      desc: '',
      args: [],
    );
  }

  /// `DELETE ALL`
  String get mainPageDrawerDeleteAll {
    return Intl.message(
      'DELETE ALL',
      name: 'mainPageDrawerDeleteAll',
      desc: '',
      args: [],
    );
  }

  /// `GENERAL OPERATIONS`
  String get mainPageDrawerGeneralOperations {
    return Intl.message(
      'GENERAL OPERATIONS',
      name: 'mainPageDrawerGeneralOperations',
      desc: '',
      args: [],
    );
  }

  /// `DARK MODE`
  String get mainPageDrawerDarkMode {
    return Intl.message(
      'DARK MODE',
      name: 'mainPageDrawerDarkMode',
      desc: '',
      args: [],
    );
  }

  /// `SESSION SETTINGS`
  String get mainPageDrawerSessionSetting {
    return Intl.message(
      'SESSION SETTINGS',
      name: 'mainPageDrawerSessionSetting',
      desc: '',
      args: [],
    );
  }

  /// `GENERAL SETTINGS`
  String get mainPageDrawerGeneralSettings {
    return Intl.message(
      'GENERAL SETTINGS',
      name: 'mainPageDrawerGeneralSettings',
      desc: '',
      args: [],
    );
  }

  /// `WIDGET SETTINGS`
  String get mainPageDrawerWidgetSettings {
    return Intl.message(
      'WIDGET SETTINGS',
      name: 'mainPageDrawerWidgetSettings',
      desc: '',
      args: [],
    );
  }

  /// `OUTPUT AS IMAGE`
  String get mainPageDrawerOutputAsImage {
    return Intl.message(
      'OUTPUT AS IMAGE',
      name: 'mainPageDrawerOutputAsImage',
      desc: '',
      args: [],
    );
  }

  /// `SETTINGS`
  String get mainPageDrawerSetting {
    return Intl.message(
      'SETTINGS',
      name: 'mainPageDrawerSetting',
      desc: '',
      args: [],
    );
  }

  /// `SAVE/LOAD PROFILE`
  String get mainPageDrawerSaveLoadProfile {
    return Intl.message(
      'SAVE/LOAD PROFILE',
      name: 'mainPageDrawerSaveLoadProfile',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}