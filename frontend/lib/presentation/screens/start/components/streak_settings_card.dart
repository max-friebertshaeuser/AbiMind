import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StreakSettingScreen extends StatefulWidget {
  const StreakSettingScreen({super.key});
@override
State<StreakSettingScreen> createState() => _StreakSettingScreenState();
}

class _StreakSettingScreenState extends State<StreakSettingScreen> {
  final TextEditingController _controller = TextEditingController();
  var username = FirebaseAuth.instance.currentUser?.displayName ?? 'testUser';
  bool _goalSaved = false;

  void _saveGoal() {
    final minutes = int.tryParse(_controller.text);
    if (minutes != null && minutes > 0) {
      setState(() {
        _goalSaved = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid number of minutes.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Learning Goal"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(Icons.emoji_events, size: 80, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                "Hi ${username},",
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "Set yourself a daily learning goal",
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 32),
            Text("Daily Learning Goal", style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter minutes",
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text("Minutes", style: theme.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: _saveGoal,
                icon: const Icon(Icons.save),
                label: const Text("Save"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_goalSaved)
              Center(
                child: Text(
                  "Your daily goal is saved.",
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.secondary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
