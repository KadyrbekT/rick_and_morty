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

## Скриншоты приложения

<img width="360" height="732" alt="Снимок экрана 2026-04-09 в 17 30 25" src="https://github.com/user-attachments/assets/b4f3c650-4669-4e75-a516-bc9532f0513a" />
<img width="357" height="722" alt="Снимок экрана 2026-04-09 в 17 31 16" src="https://github.com/user-attachments/assets/5dbf3c36-6222-4ec3-813c-e87c4943ff73" />
<img width="346" height="722" alt="Снимок экрана 2026-04-09 в 17 32 02" src="https://github.com/user-attachments/assets/d47eef74-f93f-4579-939b-be4d5b69eba3" />
<img width="356" height="724" alt="Снимок экрана 2026-04-09 в 17 32 37" src="https://github.com/user-attachments/assets/3805afae-af3d-43b2-b9aa-00e82d7b2abf" />
<img width="355" height="727" alt="Снимок экрана 2026-04-09 в 17 34 14" src="https://github.com/user-attachments/assets/b4934a99-ddbf-4ab7-8c9b-163577e9fd3d" />
<img width="354" height="722" alt="Снимок экрана 2026-04-09 в 17 34 51" src="https://github.com/user-attachments/assets/48947514-9c08-4c8c-99b3-4d5381a674f5" />
<img width="348" height="725" alt="Снимок экрана 2026-04-09 в 17 36 49" src="https://github.com/user-attachments/assets/e0109934-6fe7-4371-8e
<img width="363" height="725" alt="Снимок экрана 2026-04-09 в 17 37 32" src="https://github.com/user-attachments/assets/6a443cf4-631f-43cd-9207-bf868e4dbf22" />
d2-1c8cf2a5e0a7" />
<img width="354" height="727" alt="Снимок экрана 2026-04-09 в 17 38 17" src="https://github.com/user-attachments/assets/ce45b46d-1286-458e-a2d5-52821dc1a327" />
<img width="360" height="735" alt="Снимок экрана 2026-04-09 в 17 38 57" src="https://github.com/user-attachments/assets/1eb264a1-a2af-4c3f-9fc9-f648147d1852" />
<img width="356" height="730" alt="Снимок экрана 2026-04-09 в 17 40 14" src="https://github.com/user-attachments/assets/36f5d71c-e11a-470d-84a5-c0f7a60cb251" />
<img width="356" height="727" alt="Снимок экрана 2026-04-09 в 17 40 54" src="https://github.com/user-attachments/assets/69b89bff-f28d-40f5-b71e-e6ca511eff9f" />

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
