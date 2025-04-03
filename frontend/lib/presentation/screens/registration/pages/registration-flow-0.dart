import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../login/flow-content.dart';

class RegistrationFlow0 extends StatelessWidget {
  RegistrationFlow0({super.key, required this.handleName, required this.name});

  final void Function(String) handleName;
  String name;

  @override
  Widget build(BuildContext context) {
    return FlowContent(
      title: 'Let\'s get started!',
      description: 'Firstly, how should we call you?',
      first: true,
      buttonText: 'Next Step',
      callback: () => handleName(name),
      content: TextField(
        inputFormatters: [
          FilteringTextInputFormatter(RegExp("[a-z ( ) A-Z]"), allow: true),
        ],
        onChanged: (value) => name = value,
        onSubmitted: (value) => handleName(value),
        autofocus: true,
        controller: TextEditingController(text: name),
        decoration: const InputDecoration(
          counterText: 'This is not your username',
          border: OutlineInputBorder(),
          labelText: 'Your name',
        ),
      ),
    );
  }
}
