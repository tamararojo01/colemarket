
# ColeMarket (Flutter)

Starter listo para iOS/Android/Web **sin Firebase aún**.

## Cómo correr en Codespaces
1. Sube este repo a GitHub y ábrelo en Codespaces.
2. En la terminal:
   ```bash
   flutter pub get
   flutter run -d chrome
   ```

## Si `pub get` falla con sugerencias de upgrade
Prueba:
```bash
flutter clean && rm -f pubspec.lock
flutter pub get
```
Este starter fija `intl: ^0.18.1` y `flutter_form_builder: ^9.2.1` para evitar conflictos comunes.
# colemarket
