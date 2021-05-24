import 'dart:convert';

import 'package:flutter/services.dart';

class Country {
  final String region;
  final String isoCode;
  final String iso3Code;
  final String flag;
  final String name;

  Country({
    this.region,
    this.isoCode,
    this.iso3Code,
    this.flag,
    this.name,
  });
}

class Language {
  final String name;
  final String code;

  Language(this.name, this.code);
}

class Locale {
  final Country country;
  final Language language;

  Locale(this.country, this.language);

  Locale copyWith({
    Country country,
    Language language,
  }) {
    return Locale(
      country ?? this.country,
      language ?? this.language,
    );
  }
}

Future<List<Country>> loadCountries() async {
  final countriesStr = await rootBundle.loadString('assets/countries.json');
  final countries = jsonDecode(countriesStr) as Map;
  return countries.entries.map((entry) {
    final map = entry.value;
    return Country(
      region: map['region'],
      isoCode: map['isoCode'],
      iso3Code: map['iso3Code'],
      flag: map['flag'],
      name: map['name'],
    );
  }).toList();
}

Future<List<Language>> loadLanguages() async {
  final languagesStr = await rootBundle.loadString('assets/languages.json');
  final languages = jsonDecode(languagesStr) as Map;
  return languages.entries.map((entry) {
    final map = entry.value;
    return Language(map['language'], map['code']);
  }).toList();
}
