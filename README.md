# Rick & Morty App

Мобильное приложение на Flutter для просмотра персонажей, локаций и эпизодов мультсериала «Рик и Морти» с избранным и полноценным офлайн-режимом.

---

## Функциональность

- **Персонажи** — карточки с фото, именем, статусом, видом, полом и локацией; пагинация; поиск; фильтр (статус, вид, тип, пол); сортировка (имя А→Я / Я→А, живые/мёртвые первые)
- **Локации** — список с пагинацией, поиск, фильтр (тип, измерение), детальная страница с жителями
- **Эпизоды** — список с пагинацией, поиск, фильтр по коду серии, детальная страница с актёрами
- **Избранное** — добавление/удаление персонажей, свайп для удаления, персистентное хранение
- **Офлайн-режим** — кэшированные данные отображаются без интернета; баннер при отсутствии сети
- **Тема** — светлая и тёмная, сохраняется между сессиями
- **Локализация** — русский и английский (ARB + flutter_localizations)

---

## Архитектура

Проект построен по **Clean Architecture** с feature-first структурой.

```
lib/
├── app/
│   ├── app.dart                   # MaterialApp + глобальные BlocProvider-ы
│   └── view/
│       └── main_scaffold.dart     # BottomNavigationBar + IndexedStack
│
├── core/
│   ├── constants/                 # API URL константы
│   ├── di/                        # Dependency Injection (GetIt)
│   ├── error/                     # Exceptions & Failures
│   ├── l10n/                      # AppLocalizations extension
│   ├── local/                     # LocalStorageService (абстракция над SharedPreferences)
│   ├── network/                   # DioClient, NetworkInfo, ConnectivityBanner
│   ├── observers/                 # AppBlocObserver
│   ├── theme/                     # AppTheme + ThemeCubit
│   ├── usecases/                  # UseCase<T, Params> + NoParams, IdParam, IdsParam
│   └── widgets/                   # OverlayLoader
│
├── features/
│   ├── home/                      # Персонажи
│   │   ├── data/
│   │   │   ├── datasources/       # CharacterRemoteDataSource + CharacterLocalDataSource
│   │   │   ├── models/            # CharacterModel (JSON ↔ Entity)
│   │   │   └── repositories/      # CharacterRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/          # Character, CharacterFilter, SortBy
│   │   │   ├── repositories/      # CharacterRepository (abstract)
│   │   │   └── usecases/          # GetCharacters, GetCharacterById, GetMultipleCharacters
│   │   └── presentation/
│   │       ├── bloc/              # CharacterBloc + sealed Event + State
│   │       ├── cubit/             # CharacterDetailCubit
│   │       ├── pages/             # HomePage, CharacterDetailPage
│   │       └── widgets/           # CharacterCard, CharacterShimmer
│   │
│   ├── location/                  # Локации (аналогичная структура)
│   ├── episode/                   # Эпизоды (аналогичная структура)
│   └── favorite/                  # Избранное
│       ├── data/repositories/     # FavoriteRepositoryImpl (только LocalStorage)
│       ├── domain/                # FavoriteRepository + GetFavorites + ToggleFavorite
│       └── presentation/          # FavoriteBloc + FavoritePage
│
├── l10n/                          # ARB файлы (app_ru.arb, app_en.arb) + сгенерированный код
├── bootstrap.dart                 # Инициализация: DI, BlocObserver, ориентация экрана
└── main.dart                      # Точка входа
```

### Слои и их ответственность

| Слой | Ответственность |
|---|---|
| **Domain** | Бизнес-логика и контракты; не зависит ни от Flutter, ни от внешних пакетов |
| **Data** | Источники данных (API + кэш), маппинг моделей в entities |
| **Presentation** | BLoC/Cubit + UI; только отображение состояний |

### Ключевые паттерны

- **`UseCase<T, Params>`** — единый контракт для всех use cases; результат всегда `Either<Failure, T>`
- **`Either<Failure, T>`** (dartz) — явная обработка ошибок без исключений в BLoC
- **`sealed class` Event** — компилятор гарантирует полное покрытие всех событий
- **`copyWith` + `clearError`** — иммутабельное состояние без лишних перестроений
- **`LocalStorageService`** — абстракция над SharedPreferences; реализацию можно заменить (Hive, Isar) без изменения фич
- **`IndexedStack` + `AutomaticKeepAliveClientMixin`** — сохранение состояния вкладок при переключении

---

## Используемые технологии

| Назначение | Пакет |
|---|---|
| State Management | `flutter_bloc` 8.x + `bloc` |
| Dependency Injection | `get_it` |
| Networking | `dio` |
| Connectivity | `connectivity_plus` |
| Local Storage | `shared_preferences` |
| Functional types | `dartz` (`Either<Failure, T>`) |
| Локализация | `flutter_localizations` + `intl` |
| Skeleton loader | `shimmer` |
| Value equality | `equatable` |

---

## Запуск проекта

**Требования:** Flutter SDK ≥ 3.11.0

```bash
git clone <repo-url>
cd rick_and_morty

flutter pub get
flutter run
```

Сборка релиза:
```bash
flutter build apk --release   # Android
flutter build ios --release   # iOS
```

---

## API

Публичный [Rick and Morty API](https://rickandmortyapi.com):

| Эндпоинт | Описание |
|---|---|
| `GET /character?page={n}&name={q}&status={s}...` | Список персонажей с фильтрами |
| `GET /character/{id}` | Персонаж по ID |
| `GET /character/{id1},{id2},...` | Несколько персонажей по ID |
| `GET /location?page={n}&name={q}&type={t}...` | Список локаций с фильтрами |
| `GET /location/{id}` | Локация по ID |
| `GET /episode?page={n}&name={q}&episode={e}` | Список эпизодов с фильтрами |
| `GET /episode/{id}` | Эпизод по ID |
