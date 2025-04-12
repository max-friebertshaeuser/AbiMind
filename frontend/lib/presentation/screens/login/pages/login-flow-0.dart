import 'package:flutter/material.dart';

import '../../../widgets/phonenumber-textfield.dart';
import '../flow-content.dart';

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
  void handleNumber(String value) {
    print('submitted number: $value');
    widget.number = value;
  }

  void handleCountry(String value) {
    print('submitted coutry: $value');
    widget.country = value;
  }

  @override
  Widget build(BuildContext context) {
    return FlowContent(
      title: 'Welcome back then!',
      description: 'Please enter your Phonenumber',
      buttonText: 'Verify',
      callback: () => widget.handlePhoneNumber(widget.country + widget.number),
      content: PhonenumberTextfield(
        number: widget.number,
        country: widget.country,
        handleCountry: (value) => handleCountry(value),
        handleNumber: (value) => handleNumber(value),
        error: error,
        enabled: true,
      ),
    );
  }
}
