import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../login/flow-content.dart';

class RegistrationFlow3 extends StatefulWidget {
  RegistrationFlow3(
      {super.key, required this.handleUsername, required this.username});

  final void Function(String) handleUsername;
  String username;

  @override
  State<RegistrationFlow3> createState() => _RegistrationFlow3State();
}

class _RegistrationFlow3State extends State<RegistrationFlow3> {
  RegExp usernameRegex = RegExp(r'[a-z0-9-]{3,14}');
  String? error;

  void checkUsername(String value) {
    widget.username = value;
    if (usernameRegex.hasMatch(widget.username)) {
      setState(() {
        error = null;
      });
      widget.handleUsername(widget.username);
    } else {
      setState(() {
        error = "Please enter a valid username";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlowContent(
      title: 'You are verified!',
      description:
          'Let\'s find a username for you. \nIt\'s a unique identifier for your friends to find you',
      buttonText: 'Take me to the last step',
      callback: () => widget.handleUsername(widget.username),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextField(
            controller: TextEditingController(text: widget.username),
            onChanged: (value) => widget.username = value,
            onSubmitted: (value) => widget.handleUsername(widget.username),
            inputFormatters: [
              FilteringTextInputFormatter(RegExp("[a-z0-9-]"), allow: true),
            ],
            autofocus: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Username',
              helperText:
                  'Rules for your username: \n   - all lowercase\n  - only letters, numbers and - \n  - no special characters (ä, ö, ü, á, é)',
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'No worries, you can change this later on',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.5),
                ),
              )),
        ],
      ),
    );
  }
}
