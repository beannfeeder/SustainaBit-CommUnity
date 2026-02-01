# Contributing to SustainaBit CommUnity

Thank you for your interest in contributing to SustainaBit CommUnity! This document provides guidelines and best practices for contributing to the project.

## 🏗️ Architecture Overview

This project follows a feature-based architecture with clear separation of concerns:

```
lib/
├── main.dart                 # App entry point
└── src/
    ├── config/              # App configuration
    ├── models/              # Data models
    ├── screens/             # UI screens (pages)
    ├── widgets/             # Reusable UI components
    ├── services/            # Business logic & API calls
    ├── utils/               # Helper functions
    └── routes/              # Navigation configuration
```

## 📋 Code Standards

### Dart Style Guide

- Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide
- Run `flutter analyze` before committing
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

### File Naming

- Use `snake_case` for file names (e.g., `home_screen.dart`)
- Use `PascalCase` for class names (e.g., `HomeScreen`)
- Use `camelCase` for variables and functions (e.g., `getUserData`)

### Widget Guidelines

1. **Stateless vs Stateful**: Use `StatelessWidget` by default. Only use `StatefulWidget` when state management is needed within the widget.

2. **Extract Reusable Widgets**: If a widget is used more than once, extract it to `lib/src/widgets/`

3. **Widget Structure**:
```dart
class MyWidget extends StatelessWidget {
  // 1. Constructor parameters
  final String title;
  final VoidCallback? onTap;

  // 2. Constructor
  const MyWidget({
    super.key,
    required this.title,
    this.onTap,
  });

  // 3. Build method
  @override
  Widget build(BuildContext context) {
    // Implementation
  }

  // 4. Private helper methods (if needed)
  Widget _buildHelper() {
    // Helper implementation
  }
}
```

## 🧪 Testing

### Writing Tests

- Write tests for models, services, and utilities
- Place tests in the `test/` directory mirroring the `lib/src/` structure
- Test file names should end with `_test.dart`

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/user_model_test.dart

# Run tests with coverage
flutter test --coverage
```

## 🚀 Adding New Features

### 1. Adding a New Screen

1. Create screen file in `lib/src/screens/`:
```dart
// lib/src/screens/new_feature_screen.dart
import 'package:flutter/material.dart';

class NewFeatureScreen extends StatelessWidget {
  const NewFeatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Feature')),
      body: const Center(child: Text('New Feature')),
    );
  }
}
```

2. Add route in `lib/src/routes/app_router.dart`:
```dart
GoRoute(
  path: '/new-feature',
  name: 'newFeature',
  builder: (context, state) => const NewFeatureScreen(),
),
```

### 2. Adding a New Model

1. Create model file in `lib/src/models/`:
```dart
// lib/src/models/post.dart
class Post {
  final String id;
  final String title;
  final String content;

  Post({
    required this.id,
    required this.title,
    required this.content,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
    };
  }

  Post copyWith({
    String? id,
    String? title,
    String? content,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }
}
```

2. Write tests for the model:
```dart
// test/post_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sustainabit_community/src/models/post.dart';

void main() {
  group('Post Model Tests', () {
    test('should create from JSON', () {
      final json = {'id': '1', 'title': 'Test', 'content': 'Content'};
      final post = Post.fromJson(json);
      expect(post.id, '1');
      expect(post.title, 'Test');
    });
  });
}
```

### 3. Adding a New Service

1. Create service file in `lib/src/services/`:
```dart
// lib/src/services/post_service.dart
import 'api_service.dart';
import '../models/post.dart';

class PostService extends ApiService {
  Future<List<Post>> getPosts() async {
    final response = await get('/posts');
    return (response as List)
        .map((json) => Post.fromJson(json))
        .toList();
  }

  Future<Post> getPost(String id) async {
    final response = await get('/posts/$id');
    return Post.fromJson(response);
  }

  Future<Post> createPost(Post post) async {
    final response = await post('/posts', post.toJson());
    return Post.fromJson(response);
  }
}
```

### 4. Adding a Reusable Widget

1. Create widget file in `lib/src/widgets/`:
```dart
// lib/src/widgets/custom_text_field.dart
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
```

## 🔄 State Management

This project uses Provider for state management. To add a new provider:

1. Create provider class:
```dart
// lib/src/providers/theme_provider.dart
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
```

2. Register in `main.dart`:
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ],
  child: MaterialApp.router(...),
)
```

3. Use in widgets:
```dart
// Access provider
final themeProvider = Provider.of<ThemeProvider>(context);

// Or with Consumer
Consumer<ThemeProvider>(
  builder: (context, themeProvider, child) {
    return Text('Dark mode: ${themeProvider.isDarkMode}');
  },
)
```

## 🎨 Styling Guidelines

- Use theme colors from `AppTheme` in `lib/src/config/app_theme.dart`
- Maintain consistent spacing (use multiples of 4 or 8)
- Use Material Design 3 components
- Ensure accessibility (proper contrast, font sizes)

## 📦 Adding Dependencies

1. Add to `pubspec.yaml`:
```yaml
dependencies:
  new_package: ^1.0.0
```

2. Run:
```bash
flutter pub get
```

3. Import in code:
```dart
import 'package:new_package/new_package.dart';
```

## 🔍 Code Review Checklist

Before submitting a PR, ensure:

- [ ] Code follows Dart style guide
- [ ] All tests pass (`flutter test`)
- [ ] No analyzer warnings (`flutter analyze`)
- [ ] Code is properly documented
- [ ] Reusable components are extracted
- [ ] No hardcoded values (use constants)
- [ ] Proper error handling
- [ ] Responsive design considered
- [ ] Accessibility guidelines followed

## 🐛 Reporting Issues

When reporting issues, include:

- Flutter version (`flutter --version`)
- Device/Platform information
- Steps to reproduce
- Expected vs actual behavior
- Screenshots (if UI related)
- Error logs

## 📝 Commit Messages

Use conventional commit format:

```
feat: add user profile screen
fix: resolve navigation issue on settings page
docs: update README with routing examples
style: format code according to dart style guide
refactor: extract common button widget
test: add tests for user model
chore: update dependencies
```

## 🌿 Branch Naming

Use descriptive branch names:

- `feature/user-authentication`
- `fix/navigation-bug`
- `refactor/service-layer`
- `docs/api-documentation`

## 💬 Getting Help

- Check the README.md for project overview
- Review existing code for patterns
- Ask questions in team discussions

---

Thank you for contributing to SustainaBit CommUnity! 🌱
