# 🚀 Guía de Despliegue - Soft Restaurant

## 📋 Checklist Pre-Despliegue

### Código
- [ ] Todas las features funcionan correctamente
- [ ] Tests pasan exitosamente
- [ ] No hay warnings críticos en `flutter analyze`
- [ ] Código formateado con `flutter format`
- [ ] Remover logs de debug (`print`, `debugPrint`)
- [ ] Actualizar versión en `pubspec.yaml`

### Seguridad
- [ ] API keys en variables de entorno
- [ ] Firebase rules configuradas correctamente
- [ ] Validaciones en frontend y backend
- [ ] Manejo seguro de datos sensibles
- [ ] HTTPS habilitado

### Rendimiento
- [ ] Imágenes optimizadas
- [ ] Lazy loading implementado
- [ ] Caché configurado
- [ ] Bundle size optimizado

### Legal
- [ ] Términos y condiciones
- [ ] Política de privacidad
- [ ] Permisos de la app justificados

## 📱 Despliegue Android

### 1. Configurar Signing

**Crear keystore:**
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Configurar en `android/key.properties`:**
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<ruta-al-keystore>
```

**Editar `android/app/build.gradle`:**
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

### 2. Build Release

```bash
# App Bundle (recomendado para Play Store)
flutter build appbundle --release

# APK (para distribución directa)
flutter build apk --release --split-per-abi
```

**Archivos generados:**
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`
- APKs: `build/app/outputs/flutter-apk/`

### 3. Google Play Console

1. **Crear aplicación**
   - Ve a https://play.google.com/console
   - Crear nueva aplicación
   - Completar información básica

2. **Configurar Store Listing**
   - Título (30 caracteres max)
   - Descripción corta (80 caracteres)
   - Descripción completa (4000 caracteres)
   - Screenshots (mínimo 2)
   - Icono de alta resolución (512x512)
   - Banner (1024x500)

3. **Subir App Bundle**
   - Production → Releases
   - Create new release
   - Upload app bundle
   - Release notes

4. **Completar Content Rating**
5. **Configurar Pricing & Distribution**
6. **Submit for Review**

### Optimizaciones Android

**android/app/build.gradle:**
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.tuempresa.softrestaurant"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
        
        // MultiDex support
        multiDexEnabled true
    }
    
    buildTypes {
        release {
            // Obfuscación
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

## 🍎 Despliegue iOS

### 1. Configurar Xcode

```bash
cd ios
pod install
open Runner.xcworkspace
```

**En Xcode:**
1. Seleccionar proyecto Runner
2. General → Identity
   - Display Name: Soft Restaurant
   - Bundle Identifier: com.tuempresa.softrestaurant
   - Version: 1.0.0
   - Build: 1

3. Signing & Capabilities
   - Team: Seleccionar tu equipo
   - Automatically manage signing ✓

### 2. Build Release

```bash
# Desde raíz del proyecto
flutter build ios --release

# O desde Xcode: Product → Archive
```

### 3. App Store Connect

1. **Crear App**
   - Ve a https://appstoreconnect.apple.com
   - My Apps → + → New App
   - Plataforma: iOS
   - Bundle ID: Seleccionar el tuyo

2. **Información de la App**
   - Nombre
   - Subtítulo
   - Categoría: Food & Drink
   - Keywords
   - Description
   - Screenshots (todos los tamaños requeridos)

3. **Subir Build**
   - Desde Xcode: Organizer → Upload to App Store
   - O usar Transporter app

4. **App Review Information**
   - Contact info
   - Demo account (si es necesario)
   - Notes para el revisor

5. **Submit for Review**

### Screenshots Requeridos para iOS

```
iPhone 6.7" (Pro Max):
- 1290 x 2796 px (mínimo 3-5 screenshots)

iPhone 6.5" (Plus):
- 1242 x 2688 px

iPhone 5.5":
- 1242 x 2208 px

iPad Pro 12.9" (opcional):
- 2048 x 2732 px
```

## 🌐 Despliegue Web

### 1. Build

```bash
flutter build web --release
```

### 2. Opciones de Hosting

#### Firebase Hosting (Recomendado)

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Inicializar
firebase init hosting

# Configurar public directory: build/web

# Deploy
firebase deploy --only hosting
```

**firebase.json:**
```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

#### Netlify

```bash
# Instalar Netlify CLI
npm install -g netlify-cli

# Deploy
netlify deploy --dir=build/web --prod
```

#### GitHub Pages

```yaml
# .github/workflows/deploy.yml
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter build web --release --base-href "/soft-restaurant/"
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
```

### Optimizaciones Web

**web/index.html:**
```html
<!-- Service Worker para PWA -->
<script>
  if ('serviceWorker' in navigator) {
    window.addEventListener('load', function() {
      navigator.serviceWorker.register('flutter_service_worker.js');
    });
  }
</script>

<!-- Preconnect a Firebase -->
<link rel="preconnect" href="https://firestore.googleapis.com">
<link rel="preconnect" href="https://firebase.googleapis.com">
```

**web/manifest.json:**
```json
{
  "name": "Soft Restaurant",
  "short_name": "SoftRest",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#FAFAFA",
  "theme_color": "#FF6B35",
  "description": "Sistema completo de gestión para restaurantes",
  "orientation": "portrait-primary",
  "prefer_related_applications": false,
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

## 🔍 Monitoreo y Analytics

### Firebase Crashlytics (Android/iOS)

**pubspec.yaml:**
```yaml
dependencies:
  firebase_crashlytics: ^3.4.8
```

**main.dart:**
```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  
  runApp(MyApp());
}
```

### Firebase Analytics

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

final analytics = FirebaseAnalytics.instance;

// Log event
await analytics.logEvent(
  name: 'product_added_to_cart',
  parameters: {
    'product_id': product.id,
    'product_name': product.name,
    'price': product.price,
  },
);
```

## 🔄 CI/CD con GitHub Actions

**.github/workflows/build.yml:**
```yaml
name: Build and Test

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Analyze
      run: flutter analyze
    
    - name: Run tests
      run: flutter test
    
    - name: Build APK
      run: flutter build apk --release
    
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: release-apk
        path: build/app/outputs/flutter-apk/app-release.apk
```

## 📊 Versioning

### Semantic Versioning (SemVer)

```
MAJOR.MINOR.PATCH

1.0.0 - Release inicial
1.1.0 - Nueva funcionalidad (backward compatible)
1.1.1 - Bug fix
2.0.0 - Breaking changes
```

**pubspec.yaml:**
```yaml
version: 1.0.0+1
#        │ │ │  └─ Build number (Android: versionCode, iOS: CFBundleVersion)
#        │ │ └─── PATCH
#        │ └───── MINOR
#        └─────── MAJOR
```

## 🛡️ Seguridad en Producción

### 1. Ofuscar código (Android)

**android/app/proguard-rules.pro:**
```proguard
-keep class com.google.firebase.** { *; }
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**
```

### 2. Certificado SSL Pinning

```dart
// Para APIs propias
import 'package:dio/dio.dart';
import 'package:dio/adapter.dart';

final dio = Dio();
(dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = 
  (client) {
    client.badCertificateCallback = 
      (X509Certificate cert, String host, int port) => false;
    return client;
  };
```

### 3. Variables de Entorno

**.env:**
```
API_KEY=tu_api_key_aqui
BASE_URL=https://api.tudominio.com
FIREBASE_API_KEY=...
```

**Usar con flutter_dotenv:**
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

await dotenv.load();
final apiKey = dotenv.env['API_KEY'];
```

## 📈 Post-Deployment

### Tareas Post-Launch

- [ ] Monitorear crashlytics primeras 24h
- [ ] Revisar analytics y métricas
- [ ] Responder reviews de usuarios
- [ ] Actualizar documentación
- [ ] Crear roadmap de features futuras
- [ ] Configurar alertas de errores
- [ ] Backup de base de datos

### Actualización de la App

```bash
# 1. Incrementar versión en pubspec.yaml
version: 1.1.0+2

# 2. Build nueva versión
flutter build appbundle --release

# 3. Subir a Play Console / App Store Connect

# 4. Release notes claros
```

## 📝 Recursos Adicionales

- [Flutter Deployment Docs](https://docs.flutter.dev/deployment)
- [Google Play Launch Checklist](https://developer.android.com/distribute/best-practices/launch/launch-checklist)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Firebase Hosting Docs](https://firebase.google.com/docs/hosting)

---

**¡Éxito con el lanzamiento! 🚀**
