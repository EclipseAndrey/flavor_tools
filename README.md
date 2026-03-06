<p align="center">
    <a href="https://pub.dev/packages/flavor_tools" align="center">
        <img src="https://github.com/EclipseAndrey/flavor_tools/blob/main/ft_logo.png?raw=true" width="4000px">
    </a>
</p>

<p align="center">
    <a href="https://github.com/EclipseAndrey/flavor_tools/issues/new" align="center">
        <img src="https://github.com/EclipseAndrey/xcode_parser/blob/main/wrong_button.png?raw=true" width="300px">
    </a>
</p>

# Flavor Tools

CLI-утилита для быстрого создания и управления flavors в Flutter-проектах. Автоматически настраивает iOS (Xcode project, xcconfig, schemes) и Android (Gradle, AndroidManifest).

## Возможности

- Создание flavor для iOS и Android одной командой
- Пакетное создание из YAML-конфига (`create-all`)
- Обновление существующих flavors (`update`)
- Настройка target device family для iOS
- Поддержка Kotlin DSL (`build.gradle.kts`) и Groovy (`build.gradle`)
- Автоопределение настроек из существующего Xcode-проекта (SWIFT_VERSION, IPHONEOS_DEPLOYMENT_TARGET и др.)
- Проверка дубликатов перед созданием
- Поддержка `flutter_launcher_icons`

## Установка

```yaml
dependencies:
  flavor_tools: ^2.0.1
```

или

```shell
dart pub add flavor_tools
```

### Глобальная установка (опционально)

```shell
dart compile exe bin/flavor_tools.dart -o flavor_tools
mv flavor_tools /usr/local/bin/
```

## Команды

### `create` — создание одного flavor

```shell
dart run flavor_tools create \
  -p com.example.app \
  -f dev \
  -d "My App Dev"
```

| Флаг | Сокращение | Описание |
|------|-----------|----------|
| `--packageName` | `-p` | Package name для iOS и Android |
| `--packageNameIos` | `-i` | Package name только для iOS |
| `--packageNameAndroid` | `-a` | Package name только для Android |
| `--flavorName` | `-f` | Имя flavor |
| `--displayName` | `-d` | Отображаемое имя приложения |
| `--teamId` | `-t` | Apple Team ID (по умолчанию: пустой) |
| `--pathXcProject` | `-x` | Путь к project.pbxproj |
| `--iconsLauncher` | | `true` если используете `flutter_launcher_icons` |

### `create-all` — пакетное создание из YAML

```shell
dart run flavor_tools create-all -c flavor_tools.yaml
```

Формат `flavor_tools.yaml`:

```yaml
flavors:
  dev:
    package_name: com.example.app.dev
    display_name: "My App Dev"
  staging:
    package_name: com.example.app.staging
    display_name: "My App Staging"
  prod:
    package_name: com.example.app
    display_name: "My App"
    team_id: "ABC123"
    icons_launcher: true
```

Каждый flavor поддерживает поля:

| Поле | Описание |
|------|----------|
| `package_name` | Общий package name |
| `package_name_ios` | Package name только для iOS |
| `package_name_android` | Package name только для Android |
| `display_name` | Отображаемое имя |
| `dimension` | Flavor dimension (по умолчанию: `default`) |
| `team_id` | Apple Team ID |
| `icons_launcher` | Поддержка flutter_launcher_icons |

При повторном запуске `create-all` автоматически определяет изменения и обновляет только те flavors, у которых поменялся конфиг.

### `update` — обновление существующего flavor

```shell
dart run flavor_tools update \
  -f dev \
  -p com.example.newpackage \
  -d "New Display Name"
```

| Флаг | Описание |
|------|----------|
| `--flavorName` `-f` | Имя flavor (обязательный) |
| `--packageName` `-p` | Новый package name для iOS и Android |
| `--packageNameIos` | Новый package name только для iOS |
| `--packageNameAndroid` | Новый package name только для Android |
| `--displayName` `-d` | Новое отображаемое имя для iOS и Android |
| `--displayNameIos` | Новое имя только для iOS |
| `--displayNameAndroid` | Новое имя только для Android |

### `set-target-device-family` — целевые устройства iOS

```shell
dart run flavor_tools set-target-device-family -d "1,2"
```

- `1` — iPhone
- `2` — iPad
- `1,2` — iPhone и iPad

## Запуск flavor

```shell
flutter run --flavor=dev
```

## Что генерируется

**iOS:**
- `XCBuildConfiguration` для Debug, Release, Profile
- xcconfig-файлы (`ios/Flutter/Debug-{flavor}.xcconfig`, `Release-{flavor}.xcconfig`)
- Xcode scheme (`ios/Runner.xcodeproj/xcshareddata/xcschemes/{flavor}.xcscheme`)
- Обновление `Info.plist` и `Runner.entitlements`

**Android:**
- `flavorDimensions` и `productFlavors` в `build.gradle` / `build.gradle.kts`
- `resValue` для `app_name` в каждом flavor
- Обновление `AndroidManifest.xml`
