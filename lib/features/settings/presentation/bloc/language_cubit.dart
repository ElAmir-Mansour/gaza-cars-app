import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language_state.dart';

@injectable
class LanguageCubit extends Cubit<LanguageState> {
  final SharedPreferences sharedPreferences;

  LanguageCubit({required this.sharedPreferences})
      : super(const LanguageState(Locale('en'))) {
    _loadLanguage();
  }

  void _loadLanguage() {
    final languageCode = sharedPreferences.getString('language_code');
    if (languageCode != null) {
      emit(LanguageState(Locale(languageCode)));
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    await sharedPreferences.setString('language_code', languageCode);
    emit(LanguageState(Locale(languageCode)));
  }
}
