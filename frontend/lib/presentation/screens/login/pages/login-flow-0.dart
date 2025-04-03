import 'package:flutter/material.dart';

import '../flow-content.dart';
import '../widgets/phonenumber-textfield.dart';

class LoginFlow0 extends StatefulWidget {
  LoginFlow0({
    super.key,
    required this.handlePhoneNumber,
    required this.country,
    required this.number,
  });

  String country;
  String number;
  final void Function(String) handlePhoneNumber;

  @override
  State<LoginFlow0> createState() => _LoginFlow0State();
}

class _LoginFlow0State extends State<LoginFlow0> {
  RegExp phoneNumberRegex = RegExp(r'\+[0-9]{12}');

  //todo remove debug values
  String? error;

  @override
  Widget build(BuildContext context) {
    return FlowContent(
      title: 'Welcome back then!',
      description: 'Please enter your Phonenumber',
      buttonText: 'Verify',
      callback: () => {},
      content: PhonenumberTextfield(
        number: widget.number,
        country: widget.country,
        handleCountry: (value) => {},
        handleNumber: (value) => {},
        error: error,
        enabled: true,
      ),
    );
  }
}
