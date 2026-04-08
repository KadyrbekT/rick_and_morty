# Rick & Morty App

Мобильное приложение на Flutter для просмотра персонажей мультсериала «Рик и Морти» с возможностью добавления в избранное и работой в офлайн-режиме.

---

## Функциональность

- **Список персонажей** — карточки с фото, именем, статусом (жив/мёртв), видом, полом и локацией
- **Пагинация** — автоматическая подгрузка следующей страницы при прокрутке (20 персонажей за раз)
- **Избранное** — добавление/удаление персонажей, свайп для удаления, сохранение в SharedPreferences
- **Оффлайн-режим** — закешированные данные отображаются при отсутствии интернета
- **Поиск** — поиск по имени через Rick & Morty API
- **Сортировка** — по имени (А→Я / Я→А) и статусу (живые/мёртвые первые)
- **Смена темы** — светлая и тёмная тема с сохранением выбора

---

## Архитектура

Проект построен по принципу **Clean Architecture** с разделением на три слоя:

```
lib/
├── core/                          # Общие утилиты
│   ├── constants/                 # API URL константы
│   ├── di/                        # Dependency Injection (GetIt)
│   ├── error/                     # Exceptions & Failures
│   ├── network/                   # Dio client, NetworkInfo
│   └── theme/                     # AppTheme + ThemeCubit
│
├── features/
│   ├── home/                      # Фича: список персонажей
│   │   ├── data/
│   │   │   ├── datasources/       # Remote (Dio) + Local (SharedPreferences)
│   │   │   ├── models/            # CharacterModel (JSON ↔ Entity)
│   │   │   └── repositories/      # CharacterRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/          # Character (Equatable)
│   │   │   ├── repositories/      # Abstract CharacterRepository
│   │   │   └── usecases/          # GetCharacters (CharacterParams)
│   │   └── presentation/
│   │       ├── bloc/              # CharacterBloc + Event + State
│   │       ├── pages/             # HomePage
│   │       └── widgets/           # CharacterCard, CharacterShimmer
│   │
│   └── favorite/                  # Фича: избранное
│       ├── data/repositories/     # FavoriteRepositoryImpl
│       ├── domain/                # FavoriteRepository + UseCases
│       └── presentation/          # FavoriteBloc + FavoritePage
│
├── app.dart                       # Корневой виджет + BottomNavigationBar
├── bootstrap.dart                 # Инициализация (DI, BLoC observer, orientation)
└── main.dart                      # Точка входа
```

### Паттерны и принципы

| Слой | Ответственность |
|------|-----------------|
| **Domain** | Бизнес-логика, не зависит ни от чего |
| **Data** | Источники данных (API + кеш), маппинг |
| **Presentation** | BLoC + UI, только отображение состояний |

- `Either<Failure, T>` (dartz) — явная обработка ошибок без исключений в BLoC
- `sealed class` для Event — полное покрытие всех кейсов компилятором
- `IndexedStack` + `AutomaticKeepAliveClientMixin` — сохранение состояния вкладок

---

## Используемые технологии

| Назначение | Пакет |
|---|---|
| State Management | `flutter_bloc` 8.x + `bloc` |
| Dependency Injection | `get_it` |
| Networking | `dio` |
| Local Storage | `shared_preferences` |
| Connectivity | `connectivity_plus` |
| Functional types | `dartz` (Either<Failure, T>) |
| Loading skeleton | `shimmer` |
| Equatable models | `equatable` |

---

## Запуск проекта

### Требования

- Flutter SDK ≥ 3.11.0
- Dart SDK ≥ 3.0.0

### Установка и запуск

```bash
# Клонировать репозиторий
git clone <repo-url>
cd rick_and_morty

# Установить зависимости
flutter pub get

# Запустить приложение
flutter run

# Собрать APK (Android)
flutter build apk --release

# Собрать IPA (iOS)
flutter build ios --release
```

---

## API

Публичный [Rick and Morty API](https://rickandmortyapi.com):

- `GET /character?page={n}` — список персонажей с пагинацией
- `GET /character?name={query}&page={n}` — поиск по имени
