// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Rick & Morty';

  @override
  String get navCharacters => 'Персонажи';

  @override
  String get navLocations => 'Локации';

  @override
  String get navEpisodes => 'Эпизоды';

  @override
  String get navFavorites => 'Избранное';

  @override
  String get search => 'Поиск';

  @override
  String get closeSearch => 'Закрыть поиск';

  @override
  String get searchCharactersHint => 'Поиск персонажей...';

  @override
  String get searchLocationsHint => 'Поиск локаций...';

  @override
  String get searchEpisodesHint => 'Поиск эпизодов...';

  @override
  String get filter => 'Фильтр';

  @override
  String get filters => 'Фильтры';

  @override
  String get filterTooltip => 'Фильтр';

  @override
  String get reset => 'Сбросить';

  @override
  String get apply => 'Применить';

  @override
  String get retry => 'Попробовать снова';

  @override
  String get retryShort => 'Повторить';

  @override
  String get loadingError => 'Ошибка загрузки';

  @override
  String get emptyList => 'Список пуст';

  @override
  String get cancel => 'Отмена';

  @override
  String get information => 'Информация';

  @override
  String get type => 'Тип';

  @override
  String get dimension => 'Измерение';

  @override
  String get changeTheme => 'Сменить тему';

  @override
  String get sortBy => 'Сортировка';

  @override
  String get sortDefault => 'По умолчанию';

  @override
  String get sortNameAsc => 'Имя А→Я';

  @override
  String get sortNameDesc => 'Имя Я→А';

  @override
  String get sortAliveFirst => 'Живые первые';

  @override
  String get sortDeadFirst => 'Мёртвые первые';

  @override
  String get statusLabel => 'Статус';

  @override
  String get statusAlive => 'Живой';

  @override
  String get statusDead => 'Мёртвый';

  @override
  String get statusUnknown => 'Неизвестно';

  @override
  String get genderLabel => 'Пол';

  @override
  String get genderFemale => 'Женщина';

  @override
  String get genderMale => 'Мужчина';

  @override
  String get genderGenderless => 'Без пола';

  @override
  String get speciesLabel => 'Вид (species)';

  @override
  String get speciesHint => 'Human, Alien...';

  @override
  String get typeCharacterLabel => 'Тип (type)';

  @override
  String get typeCharacterHint => 'Parasite, Genetic experiment...';

  @override
  String get addToFavorites => 'Добавить в избранное';

  @override
  String get removeFromFavorites => 'Убрать из избранного';

  @override
  String characterNotFound(String name) {
    return 'Персонаж \"$name\" не найден';
  }

  @override
  String get typeLocationLabel => 'Тип локации (type)';

  @override
  String get typeLocationHint => 'Planet, Cluster...';

  @override
  String get dimensionLabel => 'Измерение (dimension)';

  @override
  String get dimensionHint => 'C-137, Post-Apocalyptic...';

  @override
  String get residents => 'Жители';

  @override
  String residentsCount(int count) {
    return 'Жители ($count)';
  }

  @override
  String get noResidents => 'Жителей нет';

  @override
  String locationNotFound(String name) {
    return 'Локация \"$name\" не найдена';
  }

  @override
  String get episodesTitle => 'Эпизоды';

  @override
  String episodeNotFound(String name) {
    return 'Эпизод \"$name\" не найден';
  }

  @override
  String get filterBySeasonEpisode => 'Фильтр по сезону / эпизоду';

  @override
  String get season => 'Сезон';

  @override
  String get specificEpisode => 'Конкретный эпизод';

  @override
  String get specificEpisodeHint => 'S01E01, S03E07...';

  @override
  String episodeCharactersCount(int count) {
    return 'Персонажи ($count)';
  }

  @override
  String get noEpisodeCharacters => 'Персонажей нет';

  @override
  String get characterCountLabel => 'персонажей';

  @override
  String get airDate => 'Дата выхода';

  @override
  String get episodeCode => 'Код эпизода';

  @override
  String get favoritesTitle => 'Избранное';

  @override
  String get clearFavorites => 'Очистить избранное';

  @override
  String get clearFavoritesContent =>
      'Все персонажи будут удалены из избранного.';

  @override
  String get clear => 'Очистить';

  @override
  String get noFavorites => 'Избранных персонажей нет';

  @override
  String get noFavoritesHint =>
      'Нажмите ★ на карточке персонажа,\nчтобы добавить его в избранное';

  @override
  String removedFromFavorites(String name) {
    return '$name удалён из избранного';
  }

  @override
  String get characterTraits => 'Характеристики';

  @override
  String get characterLocations => 'Локации';

  @override
  String characterEpisodesCount(int count) {
    return 'Эпизоды ($count)';
  }

  @override
  String get species => 'Вид';

  @override
  String get gender => 'Пол';

  @override
  String get origin => 'Происхождение';

  @override
  String get lastLocation => 'Последнее местонахождение';
}
