import 'package:flutter/material.dart';

import '../flow-content.dart';
import '../widgets/phonenumber-textfield.dart';

class LoginFlow1 extends StatelessWidget {
  LoginFlow1({
    super.key,
    required this.handleVerificationCode,
    required this.number,
    required this.country,
  });

  final void Function(String) handleVerificationCode;
  String verificationCode = '123456'; //todo remove debug value
  final String number;
  final String country;

  @override
  Widget build(BuildContext context) {
    return FlowContent(
      title: 'Welcome back then!',
      description: 'Please enter your phone number to create an account',
      buttonText: 'Verify',
      callback: () => handleVerificationCode(verificationCode),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PhonenumberTextfield(
            country: country,
            number: number,
            enabled: false,
            handleCountry: (value) => {},
            handleNumber: (value) => {},
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'We\'ve sent you a code to $country $number. \nPlease enter it below',
              textAlign: TextAlign.left,
            ),
            //todo make this dynamic
          ),
          TextField(
            //todo: make this to 6 digits
            onChanged: (value) => verificationCode = value,
            onSubmitted: (value) => handleVerificationCode,
            autofocus: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Your code',
            ),
          ),
        ],
      ),
    );
  }
}
