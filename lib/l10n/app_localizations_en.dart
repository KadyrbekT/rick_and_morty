// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Rick & Morty';

  @override
  String get navCharacters => 'Characters';

  @override
  String get navLocations => 'Locations';

  @override
  String get navEpisodes => 'Episodes';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get search => 'Search';

  @override
  String get closeSearch => 'Close search';

  @override
  String get searchCharactersHint => 'Search characters...';

  @override
  String get searchLocationsHint => 'Search locations...';

  @override
  String get searchEpisodesHint => 'Search episodes...';

  @override
  String get filter => 'Filter';

  @override
  String get filters => 'Filters';

  @override
  String get filterTooltip => 'Filter';

  @override
  String get reset => 'Reset';

  @override
  String get apply => 'Apply';

  @override
  String get retry => 'Try again';

  @override
  String get retryShort => 'Retry';

  @override
  String get loadingError => 'Loading error';

  @override
  String get emptyList => 'List is empty';

  @override
  String get cancel => 'Cancel';

  @override
  String get information => 'Information';

  @override
  String get type => 'Type';

  @override
  String get dimension => 'Dimension';

  @override
  String get changeTheme => 'Change theme';

  @override
  String get sortBy => 'Sort';

  @override
  String get sortDefault => 'Default';

  @override
  String get sortNameAsc => 'Name A→Z';

  @override
  String get sortNameDesc => 'Name Z→A';

  @override
  String get sortAliveFirst => 'Alive first';

  @override
  String get sortDeadFirst => 'Dead first';

  @override
  String get statusLabel => 'Status';

  @override
  String get statusAlive => 'Alive';

  @override
  String get statusDead => 'Dead';

  @override
  String get statusUnknown => 'Unknown';

  @override
  String get genderLabel => 'Gender';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderMale => 'Male';

  @override
  String get genderGenderless => 'Genderless';

  @override
  String get speciesLabel => 'Species';

  @override
  String get speciesHint => 'Human, Alien...';

  @override
  String get typeCharacterLabel => 'Type';

  @override
  String get typeCharacterHint => 'Parasite, Genetic experiment...';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String characterNotFound(String name) {
    return 'Character \"$name\" not found';
  }

  @override
  String get typeLocationLabel => 'Location type';

  @override
  String get typeLocationHint => 'Planet, Cluster...';

  @override
  String get dimensionLabel => 'Dimension';

  @override
  String get dimensionHint => 'C-137, Post-Apocalyptic...';

  @override
  String get residents => 'Residents';

  @override
  String residentsCount(int count) {
    return 'Residents ($count)';
  }

  @override
  String get noResidents => 'No residents';

  @override
  String locationNotFound(String name) {
    return 'Location \"$name\" not found';
  }

  @override
  String get episodesTitle => 'Episodes';

  @override
  String episodeNotFound(String name) {
    return 'Episode \"$name\" not found';
  }

  @override
  String get filterBySeasonEpisode => 'Filter by season / episode';

  @override
  String get season => 'Season';

  @override
  String get specificEpisode => 'Specific episode';

  @override
  String get specificEpisodeHint => 'S01E01, S03E07...';

  @override
  String episodeCharactersCount(int count) {
    return 'Characters ($count)';
  }

  @override
  String get noEpisodeCharacters => 'No characters';

  @override
  String get characterCountLabel => 'characters';

  @override
  String get airDate => 'Air date';

  @override
  String get episodeCode => 'Episode code';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get clearFavorites => 'Clear favorites';

  @override
  String get clearFavoritesContent =>
      'All characters will be removed from favorites.';

  @override
  String get clear => 'Clear';

  @override
  String get noFavorites => 'No favorites yet';

  @override
  String get noFavoritesHint =>
      'Tap ★ on a character card\nto add it to favorites';

  @override
  String removedFromFavorites(String name) {
    return '$name removed from favorites';
  }

  @override
  String get characterTraits => 'Traits';

  @override
  String get characterLocations => 'Locations';

  @override
  String characterEpisodesCount(int count) {
    return 'Episodes ($count)';
  }

  @override
  String get species => 'Species';

  @override
  String get gender => 'Gender';

  @override
  String get origin => 'Origin';

  @override
  String get lastLocation => 'Last known location';
}
