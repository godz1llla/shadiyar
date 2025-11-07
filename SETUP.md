# Инструкция по настройке проекта "Тірі Тарих"

## Предварительные требования

1. Установите Flutter SDK (последняя стабильная версия)
2. Убедитесь, что Flutter настроен правильно:
   ```bash
   flutter doctor
   ```

## Установка зависимостей

```bash
flutter pub get
```

## Настройка карт

Приложение использует **OpenStreetMap** через библиотеку `flutter_map`. 

**Преимущества:**
- Не требует API ключа
- Работает на всех платформах (Android, iOS, Linux, Web)
- Бесплатно и открыто
- Не требует дополнительной настройки

## Шрифты

Для использования шрифта Inter необходимо:

1. Скачать шрифты Inter с Google Fonts
2. Поместить файлы в директорию `assets/fonts/`:
   - Inter-Regular.ttf
   - Inter-Medium.ttf
   - Inter-Bold.ttf

## Запуск приложения

### Android
```bash
flutter run
```

### iOS
```bash
flutter run
```

## Сборка релизной версии

### Android APK
```bash
flutter build apk
```

### Android App Bundle
```bash
flutter build appbundle
```

### iOS
```bash
flutter build ios
```

## Структура проекта

- `lib/constants/` - константы (строки, цвета)
- `lib/data/` - локальные данные (хардкод)
- `lib/models/` - модели данных
- `lib/screens/` - экраны приложения
- `assets/` - ресурсы (изображения, шрифты)

## Важные замечания

1. Все данные хранятся локально (хардкод) - это MVP версия
2. Весь UI на казахском языке
3. AI-ответы эмулируются локально
4. Карты работают на основе OpenStreetMap - не требуют API ключа

