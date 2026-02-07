# SustainaBit-CommUnity
Kitahack 2026 SustainaBit

A Flutter application for sustainable living community built with a clean, scalable architecture focused on reusability and maintainability.

## 🏗️ Project Structure

```
lib/
├── main.dart                 # Application entry point
└── src/
    ├── config/              # Configuration files
    │   ├── app_theme.dart   # Theme configuration (light/dark themes)
    │   └── app_constants.dart # App-wide constants
    ├── models/              # Data models
    │   └── user.dart        # Example: User model
    ├── screens/             # UI screens
    │   ├── splash_screen.dart
    │   ├── home_screen.dart
    │   ├── profile_screen.dart
    │   └── settings_screen.dart
    ├── widgets/             # Reusable widgets
    │   ├── custom_card.dart
    │   ├── custom_button.dart
    │   ├── loading_indicator.dart
    │   └── error_widget.dart
    ├── services/            # Business logic and API services
    │   ├── api_service.dart      # HTTP API service
    │   └── storage_service.dart  # Local storage service
    ├── utils/               # Utility functions
    │   ├── date_formatter.dart  # Date formatting utilities
    │   └── validators.dart      # Form validation utilities
    └── routes/              # Navigation configuration
        └── app_router.dart  # Centralized routing with go_router
```

## ✨ Key Features

### 🎨 Theming
- Light and dark theme support
- Material Design 3
- Consistent color scheme throughout the app
- Customizable theme in `lib/src/config/app_theme.dart`

### 🧭 Navigation & Routing
- Declarative routing using `go_router`
- Deep linking support
- Type-safe navigation
- Centralized route configuration in `lib/src/routes/app_router.dart`

### 🔧 Reusable Components
- **CustomCard**: Consistent card UI with icon, title, and subtitle
- **CustomButton**: Flexible button with loading states
- **LoadingIndicator**: Standard loading widget
- **ErrorWidget**: Error display with retry functionality

### 🛠️ Services Layer
- **ApiService**: Base HTTP service with GET, POST, PUT, DELETE methods
- **StorageService**: Local storage with SharedPreferences and secure token storage using FlutterSecureStorage (Keychain/Keystore)
- Centralized error handling
- Easy to extend for specific API endpoints

### 📦 Models
- JSON serialization/deserialization
- `copyWith` methods for immutability
- Type-safe data structures

### 🔍 Utilities
- **DateFormatter**: Date/time formatting and relative time
- **Validators**: Form validation (email, password, phone, URL, etc.)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/beannfeeder/SustainaBit-CommUnity.git
cd SustainaBit-CommUnity
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## 📱 Navigation Example

```dart
import 'package:go_router/go_router.dart';

// Navigate to a route
context.push('/profile');

// Navigate and replace
context.go('/home');

// Navigate with parameters
context.push('/details?id=123');
```

## 🎯 Adding New Features

### Adding a New Screen

1. Create screen file in `lib/src/screens/`:
```dart
class NewScreen extends StatelessWidget {
  const NewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Screen')),
      body: const Center(child: Text('New Screen')),
    );
  }
}
```

2. Add route in `lib/src/routes/app_router.dart`:
```dart
GoRoute(
  path: '/new',
  name: 'new',
  builder: (context, state) => const NewScreen(),
),
```

### Adding a New Service

1. Create service file in `lib/src/services/`:
```dart
class UserService extends ApiService {
  Future<User> getUser(String id) async {
    final response = await get('/users/$id');
    return User.fromJson(response);
  }
}
```

### Adding a New Model

1. Create model file in `lib/src/models/`:
```dart
class Post {
  final String id;
  final String title;
  final String content;

  Post({required this.id, required this.title, required this.content});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'content': content};
  }
}
```

## 🔄 State Management

The project uses Provider for state management. To add a new provider:

1. Create a provider class:
```dart
class UserProvider extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
}
```

2. Add to providers in `main.dart`:
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => UserProvider()),
  ],
  child: MaterialApp.router(...),
)
```

## 🧪 Testing

Run tests:
```bash
flutter test
```

## 📝 Code Style

This project follows the official [Dart style guide](https://dart.dev/guides/language/effective-dart/style).

Run linting:
```bash
flutter analyze
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is part of Kitahack 2026.

## 👥 Team

SustainaBit CommUnity Team

---

Built with ❤️ using Flutter
