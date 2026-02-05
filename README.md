# Flutter Visitor App 🏢

A comprehensive visitor management application built with Flutter, featuring authentication, visitor registration, and management capabilities.

## 🛠 Tech Stack

- **Framework**: Flutter 3.8.1+
- **State Management**: BLoC Pattern with flutter_bloc
- **Code Generation**: Freezed for immutable classes
- **UI Components**: Material Design with custom styling
- **Charts**: FL Chart for data visualization
- **Camera**: Camera plugin for photo capture
- **Storage**: SharedPreferences for local data
- **Permissions**: Permission handler for device access

## 📦 Dependencies

### Core Dependencies

```yaml
flutter_bloc: ^9.1.1          # State management
freezed_annotation: ^3.1.0    # Code generation annotations
dartz: ^0.10.1                 # Functional programming utilities
```

### UI & UX

```yaml
google_fonts: ^6.2.1          # Custom fonts
carousel_slider: ^5.1.1       # Image carousels
shimmer: ^3.0.0               # Loading animations
fl_chart: ^1.0.0              # Charts and graphs
introduction_screen: ^3.1.17   # App introduction
```

### Device & Media

```yaml
camera: ^0.11.2               # Camera functionality
image_picker: ^1.1.2          # Image selection
mobile_scanner: ^7.0.1        # QR code scanning
signature: ^6.3.0             # Digital signatures
gal: ^2.3.2                   # Gallery access
```

### Utilities

```yaml
intl: ^0.20.2                 # Internationalization
shared_preferences: ^2.5.3    # Local storage
path_provider: ^2.1.5         # File system paths
permission_handler: ^12.0.1   # Device permissions
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.8.1 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code with Flutter extensions
- Android SDK for Android development
- Xcode for iOS development (macOS only)

### Recommended Extensions

**VS Code:**

- Flutter (by Dart-Code)
- Bloc (by Felix Angelov) - For easy BLoC generation
- Awesome Flutter Snippets
- Bracket Pair Colorizer

**Android Studio:**

- Flutter Plugin
- Dart Plugin
- Bloc Plugin - For BLoC code generation

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd flutter_visitor_app
   ```
2. **Install dependencies**

   ```bash
   flutter pub get
   ```
3. **Generate code (Freezed)**

   ```bash
   flutter packages pub run build_runner build
   ```
4. **Run the app**

   ```bash
   flutter run
   ```

## 🏗 Project Structure

```
lib/
├── core/                     # Core utilities and constants
│   ├── gen/                 # Generated assets
│   └── ...
├── data/                    # Data layer (repositories, models)
├── presentation/            # UI layer
│   └── auth/               # Authentication module
│       └── bloc/           # BLoC state management
│           └── login/      # Login feature
│               ├── login_bloc.dart
│               ├── login_event.dart
│               ├── login_state.dart
│               └── login_bloc.freezed.dart
└── ...
```

## 🔧 Development Workflow

### Code Generation

This project uses Freezed for generating immutable classes and unions. After making changes to files with `@freezed` annotations:

```bash
# One-time generation
flutter packages pub run build_runner build

# Watch mode (recommended during development)
flutter packages pub run build_runner watch

# Clean and rebuild (if conflicts occur)
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Creating New BLoC

#### Method 1: Using Extensions (Recommended)

**VS Code:**

1. Install **Bloc** extension by Felix Angelov
2. Right-click on folder → **Bloc: New Bloc**
3. Enter BLoC name (e.g., `login`)
4. Choose template (Bloc, Cubit, etc.)
5. Extension will generate all files automatically

**Android Studio:**

1. Install **Bloc** plugin
2. Right-click on folder → **New** → **Bloc Class**
3. Enter BLoC name
4. Plugin generates the complete structure

#### Method 2: Manual Creation

1. **Create the directory structure**:

   ```
   lib/presentation/[feature]/bloc/[bloc_name]/
   ├── [bloc_name]_bloc.dart
   ├── [bloc_name]_event.dart
   ├── [bloc_name]_state.dart
   └── [bloc_name]_bloc.freezed.dart  # Generated
   ```
2. **Define events** (`[bloc_name]_event.dart`):

   ```dart
        part of 'login_bloc.dart';

        @freezed
        class LoginEvent with _$LoginEvent {
            const factory LoginEvent.started() = _Started;
            const factory LoginEvent.login({
                required String email,
                required String password,
            }) = _Login;
        }
   ```
3. **Define state** (`[bloc_name]_state.dart`):

   ```dart
   part of 'login_bloc.dart';

    @freezed
    class LoginState with _$LoginState {
        const factory LoginState.initial() = _Initial;
            const factory LoginState.loading() = _Loading;
        const factory LoginState.success(UserModel userModel) = _Success;
        const factory LoginState.error(String message) = _Error;
        
    }
   ```
4. **Implement BLoC** (`[bloc_name]_bloc.dart`):

   ```dart
    class LoginBloc extends Bloc<LoginEvent, LoginState> {
        final AuthDatasource authDatasource;
        LoginBloc(this.authDatasource) : super(_Initial()) {
            on<_Login>((event, emit) async {
            emit(const _Loading());
            final result = await authDatasource.login(event.email, event.password);

            result.fold(
                (error) => emit(_Error(error)),
                (success) => emit(_Success(success)),
            );
         });
        }
    }
   ```
5. **Generate code**:

   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

## 📝 Code Style & Conventions

### State Management

- Use **BLoC pattern** for all business logic
- Implement **Freezed** for immutable data classes


## 🔒 Permissions

The app requires the following permissions:

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```
