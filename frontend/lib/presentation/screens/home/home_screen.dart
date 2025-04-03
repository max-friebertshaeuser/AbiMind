import 'package:flutter/material.dart';
import 'package:frontend/routes/routes.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.exercise);
              },
              icon: const Icon(Icons.calculate),
              label: const Text('Start New Exercise'),
            ),
            ElevatedButton.icon(onPressed: () {
              Navigator.pushNamed(context, AppRoutes.paint);
            }, label: const Text('Start simple drawing board'), icon: const Icon(Icons.brush)),
          ],
        ),
      ),
    );
  }
}
