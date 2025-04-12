import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/routes/routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('---- Current User: ${FirebaseAuth.instance.currentUser} ----');
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
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.paint);
              },
              label: const Text('Start simple drawing board'),
              icon: const Icon(Icons.brush),
            ),
            ElevatedButton.icon(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.welcome, (route) => false);
              },
              icon: const Icon(Icons.logout), label: const Text('Log out'),
            )
          ],
        ),
      ),
    );
  }
}
