import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// Application title
  ///
  /// In ru, this message translates to:
  /// **'Rick & Morty'**
  String get appTitle;

  /// Bottom nav tab: characters
  ///
  /// In ru, this message translates to:
  /// **'Персонажи'**
  String get navCharacters;

  /// Bottom nav tab: locations
  ///
  /// In ru, this message translates to:
  /// **'Локации'**
  String get navLocations;

  /// Bottom nav tab: episodes
  ///
  /// In ru, this message translates to:
  /// **'Эпизоды'**
  String get navEpisodes;

  /// Bottom nav tab: favorites
  ///
  /// In ru, this message translates to:
  /// **'Избранное'**
  String get navFavorites;

  /// Generic search label
  ///
  /// In ru, this message translates to:
  /// **'Поиск'**
  String get search;

  /// Tooltip to close search bar
  ///
  /// In ru, this message translates to:
  /// **'Закрыть поиск'**
  String get closeSearch;

  /// Hint text for character search field
  ///
  /// In ru, this message translates to:
  /// **'Поиск персонажей...'**
  String get searchCharactersHint;

  /// Hint text for location search field
  ///
  /// In ru, this message translates to:
  /// **'Поиск локаций...'**
  String get searchLocationsHint;

  /// Hint text for episode search field
  ///
  /// In ru, this message translates to:
  /// **'Поиск эпизодов...'**
  String get searchEpisodesHint;

  /// Generic filter label
  ///
  /// In ru, this message translates to:
  /// **'Фильтр'**
  String get filter;

  /// Filters section title
  ///
  /// In ru, this message translates to:
  /// **'Фильтры'**
  String get filters;

  /// Filter icon button tooltip
  ///
  /// In ru, this message translates to:
  /// **'Фильтр'**
  String get filterTooltip;

  /// Reset filters button
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get reset;

  /// Apply filters button
  ///
  /// In ru, this message translates to:
  /// **'Применить'**
  String get apply;

  /// Retry button label
  ///
  /// In ru, this message translates to:
  /// **'Попробовать снова'**
  String get retry;

  /// Short retry label
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retryShort;

  /// Generic loading error message
  ///
  /// In ru, this message translates to:
  /// **'Ошибка загрузки'**
  String get loadingError;

  /// Shown when a list has no items
  ///
  /// In ru, this message translates to:
  /// **'Список пуст'**
  String get emptyList;

  /// Cancel button
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// Section title: information
  ///
  /// In ru, this message translates to:
  /// **'Информация'**
  String get information;

  /// Generic type label
  ///
  /// In ru, this message translates to:
  /// **'Тип'**
  String get type;

  /// Dimension label for locations
  ///
  /// In ru, this message translates to:
  /// **'Измерение'**
  String get dimension;

  /// Tooltip for theme toggle button
  ///
  /// In ru, this message translates to:
  /// **'Сменить тему'**
  String get changeTheme;

  /// Sort popup tooltip
  ///
  /// In ru, this message translates to:
  /// **'Сортировка'**
  String get sortBy;

  /// Sort option: default
  ///
  /// In ru, this message translates to:
  /// **'По умолчанию'**
  String get sortDefault;

  /// Sort option: name A to Z
  ///
  /// In ru, this message translates to:
  /// **'Имя А→Я'**
  String get sortNameAsc;

  /// Sort option: name Z to A
  ///
  /// In ru, this message translates to:
  /// **'Имя Я→А'**
  String get sortNameDesc;

  /// Sort option: alive first
  ///
  /// In ru, this message translates to:
  /// **'Живые первые'**
  String get sortAliveFirst;

  /// Sort option: dead first
  ///
  /// In ru, this message translates to:
  /// **'Мёртвые первые'**
  String get sortDeadFirst;

  /// Filter label: status
  ///
  /// In ru, this message translates to:
  /// **'Статус'**
  String get statusLabel;

  /// Character status: alive
  ///
  /// In ru, this message translates to:
  /// **'Живой'**
  String get statusAlive;

  /// Character status: dead
  ///
  /// In ru, this message translates to:
  /// **'Мёртвый'**
  String get statusDead;

  /// Character status: unknown
  ///
  /// In ru, this message translates to:
  /// **'Неизвестно'**
  String get statusUnknown;

  /// Filter label: gender
  ///
  /// In ru, this message translates to:
  /// **'Пол'**
  String get genderLabel;

  /// Gender: female
  ///
  /// In ru, this message translates to:
  /// **'Женщина'**
  String get genderFemale;

  /// Gender: male
  ///
  /// In ru, this message translates to:
  /// **'Мужчина'**
  String get genderMale;

  /// Gender: genderless
  ///
  /// In ru, this message translates to:
  /// **'Без пола'**
  String get genderGenderless;

  /// Filter label: species
  ///
  /// In ru, this message translates to:
  /// **'Вид (species)'**
  String get speciesLabel;

  /// Hint text for species filter field
  ///
  /// In ru, this message translates to:
  /// **'Human, Alien...'**
  String get speciesHint;

  /// Filter label: character type
  ///
  /// In ru, this message translates to:
  /// **'Тип (type)'**
  String get typeCharacterLabel;

  /// Hint text for character type filter field
  ///
  /// In ru, this message translates to:
  /// **'Parasite, Genetic experiment...'**
  String get typeCharacterHint;

  /// Tooltip: add to favorites
  ///
  /// In ru, this message translates to:
  /// **'Добавить в избранное'**
  String get addToFavorites;

  /// Tooltip: remove from favorites
  ///
  /// In ru, this message translates to:
  /// **'Убрать из избранного'**
  String get removeFromFavorites;

  /// Shown when character search returns no results
  ///
  /// In ru, this message translates to:
  /// **'Персонаж \"{name}\" не найден'**
  String characterNotFound(String name);

  /// Filter label: location type
  ///
  /// In ru, this message translates to:
  /// **'Тип локации (type)'**
  String get typeLocationLabel;

  /// Hint text for location type filter
  ///
  /// In ru, this message translates to:
  /// **'Planet, Cluster...'**
  String get typeLocationHint;

  /// Filter label: dimension
  ///
  /// In ru, this message translates to:
  /// **'Измерение (dimension)'**
  String get dimensionLabel;

  /// Hint text for dimension filter
  ///
  /// In ru, this message translates to:
  /// **'C-137, Post-Apocalyptic...'**
  String get dimensionHint;

  /// Section title: residents
  ///
  /// In ru, this message translates to:
  /// **'Жители'**
  String get residents;

  /// Section title: residents with count
  ///
  /// In ru, this message translates to:
  /// **'Жители ({count})'**
  String residentsCount(int count);

  /// Shown when location has no residents
  ///
  /// In ru, this message translates to:
  /// **'Жителей нет'**
  String get noResidents;

  /// Shown when location search returns no results
  ///
  /// In ru, this message translates to:
  /// **'Локация \"{name}\" не найдена'**
  String locationNotFound(String name);

  /// Episodes page title
  ///
  /// In ru, this message translates to:
  /// **'Эпизоды'**
  String get episodesTitle;

  /// Shown when episode search returns no results
  ///
  /// In ru, this message translates to:
  /// **'Эпизод \"{name}\" не найден'**
  String episodeNotFound(String name);

  /// Episode filter sheet title
  ///
  /// In ru, this message translates to:
  /// **'Фильтр по сезону / эпизоду'**
  String get filterBySeasonEpisode;

  /// Season label
  ///
  /// In ru, this message translates to:
  /// **'Сезон'**
  String get season;

  /// Label for specific episode code field
  ///
  /// In ru, this message translates to:
  /// **'Конкретный эпизод'**
  String get specificEpisode;

  /// Hint for episode code field
  ///
  /// In ru, this message translates to:
  /// **'S01E01, S03E07...'**
  String get specificEpisodeHint;

  /// Section title: characters with count
  ///
  /// In ru, this message translates to:
  /// **'Персонажи ({count})'**
  String episodeCharactersCount(int count);

  /// Shown when episode has no characters
  ///
  /// In ru, this message translates to:
  /// **'Персонажей нет'**
  String get noEpisodeCharacters;

  /// Suffix for character count in episode card
  ///
  /// In ru, this message translates to:
  /// **'персонажей'**
  String get characterCountLabel;

  /// Air date label
  ///
  /// In ru, this message translates to:
  /// **'Дата выхода'**
  String get airDate;

  /// Episode code label (e.g. S03E07)
  ///
  /// In ru, this message translates to:
  /// **'Код эпизода'**
  String get episodeCode;

  /// Favorites page title
  ///
  /// In ru, this message translates to:
  /// **'Избранное'**
  String get favoritesTitle;

  /// Tooltip and dialog title for clearing all favorites
  ///
  /// In ru, this message translates to:
  /// **'Очистить избранное'**
  String get clearFavorites;

  /// Dialog body for clearing favorites
  ///
  /// In ru, this message translates to:
  /// **'Все персонажи будут удалены из избранного.'**
  String get clearFavoritesContent;

  /// Clear button label
  ///
  /// In ru, this message translates to:
  /// **'Очистить'**
  String get clear;

  /// Empty favorites title
  ///
  /// In ru, this message translates to:
  /// **'Избранных персонажей нет'**
  String get noFavorites;

  /// Empty favorites hint
  ///
  /// In ru, this message translates to:
  /// **'Нажмите ★ на карточке персонажа,\nчтобы добавить его в избранное'**
  String get noFavoritesHint;

  /// SnackBar message after removing from favorites
  ///
  /// In ru, this message translates to:
  /// **'{name} удалён из избранного'**
  String removedFromFavorites(String name);

  /// Character detail section: traits
  ///
  /// In ru, this message translates to:
  /// **'Характеристики'**
  String get characterTraits;

  /// Character detail section: locations
  ///
  /// In ru, this message translates to:
  /// **'Локации'**
  String get characterLocations;

  /// Character detail section: episodes with count
  ///
  /// In ru, this message translates to:
  /// **'Эпизоды ({count})'**
  String characterEpisodesCount(int count);

  /// Character trait: species
  ///
  /// In ru, this message translates to:
  /// **'Вид'**
  String get species;

  /// Character trait: gender
  ///
  /// In ru, this message translates to:
  /// **'Пол'**
  String get gender;

  /// Character location: origin
  ///
  /// In ru, this message translates to:
  /// **'Происхождение'**
  String get origin;

  /// Character location: last known location
  ///
  /// In ru, this message translates to:
  /// **'Последнее местонахождение'**
  String get lastLocation;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
