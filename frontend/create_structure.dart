import 'dart:io';

void main() {
  final directories = [
    'lib/core/theme',
    'lib/core/utils',
    'lib/data/models',
    'lib/data/repositories',
    'lib/data/services',
    'lib/presentation/screens/home',
    'lib/presentation/screens/login',
    'lib/presentation/widgets',
    'lib/presentation/state',
    'lib/routes',
  ];

  for (var dir in directories) {
    final directory = Directory(dir);
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
      print('Created: $dir');
    } else {
      print('Already exists: $dir');
    }
  }

  // Optionally create some basic files
  File('lib/core/config.dart').createSync(recursive: true);
  File('lib/main.dart').createSync();
  print('Created: lib/core/config.dart');
  print('Created: lib/main.dart');
}
