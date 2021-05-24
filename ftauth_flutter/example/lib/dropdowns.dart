import 'package:flutter/material.dart';
import 'package:ftauth_example/data/locales.dart';

typedef CountrySelectionHandler = void Function(Country);
typedef LanguageSelectionHandler = void Function(Language);

class CountryDropdown extends StatelessWidget {
  final Country value;
  final List<Country> countries;
  final CountrySelectionHandler onSelect;

  const CountryDropdown({
    Key key,
    @required this.value,
    @required this.countries,
    @required this.onSelect,
  })  : assert(countries != null),
        assert(onSelect != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: value,
      items: <DropdownMenuItem<Country>>[
        for (var country in countries)
          DropdownMenuItem<Country>(
            value: country,
            child: Text('${country.flag} ${country.name}'),
          )
      ],
      onChanged: onSelect,
    );
  }
}

class LanguageDropdown extends StatelessWidget {
  final Language value;
  final List<Language> languages;
  final LanguageSelectionHandler onSelect;

  const LanguageDropdown({
    Key key,
    @required this.value,
    @required this.languages,
    @required this.onSelect,
  })  : assert(languages != null),
        assert(onSelect != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: value,
      items: <DropdownMenuItem<Language>>[
        for (var language in languages)
          DropdownMenuItem<Language>(
            value: language,
            child: Text(language.name),
          )
      ],
      onChanged: onSelect,
    );
  }
}
