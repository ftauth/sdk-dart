import 'dart:convert';

import 'package:flutter/services.dart';

class Country {
  final String? region;
  final String isoCode;
  final String? iso3Code;
  final String? flag;
  final String name;

  const Country({
    this.region,
    required this.isoCode,
    this.iso3Code,
    this.flag,
    required this.name,
  });
}

class Language {
  final String name;
  final String code;

  const Language(this.name, this.code);
}

class Locale {
  final Country country;
  final Language language;

  const Locale(this.country, this.language);

  Locale copyWith({
    Country? country,
    Language? language,
  }) {
    return Locale(
      country ?? this.country,
      language ?? this.language,
    );
  }
}

Future<List<Country>> loadCountries() async {
  final countriesStr = await rootBundle.loadString('assets/countries.json');
  final countries = jsonDecode(countriesStr) as Map<String, dynamic>;
  return countries.entries.map((entry) {
    final map = (entry.value as Map).cast<String, Object?>();
    return Country(
      region: map['region'] as String?,
      isoCode: map['isoCode'] as String,
      iso3Code: map['iso3Code'] as String?,
      flag: map['flag'] as String?,
      name: map['name'] as String,
    );
  }).toList();
}

Future<List<Language>> loadLanguages() async {
  final languagesStr = await rootBundle.loadString('assets/languages.json');
  final languages = jsonDecode(languagesStr) as Map<String, dynamic>;
  return languages.entries.map((entry) {
    final map = (entry.value as Map).cast<String, Object?>();
    return Language(
      map['language'] as String,
      map['code'] as String,
    );
  }).toList();
}
