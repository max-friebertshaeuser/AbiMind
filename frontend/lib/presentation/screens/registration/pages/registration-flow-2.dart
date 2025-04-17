import 'package:flutter/material.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';
import '../../../widgets/phonenumber-textfield.dart';
import '../../login/flow-content.dart';

class RegistrationFlow2 extends StatelessWidget {
  RegistrationFlow2(
      {super.key,
      required this.name,
      required this.handleVerificationCode,
      required this.number,
      required this.countryCode,
      required this.verificationCode});

  final String name;
  final void Function(String) handleVerificationCode;
  String verificationCode;
  final String number;
  final String countryCode;

  @override
  Widget build(BuildContext context) {
    return FlowContent(
      title: 'Hi $name!',
      description: 'Please enter your phone number to create an account',
      buttonText: 'Verify',
      callback: () => handleVerificationCode(verificationCode),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PhonenumberTextfield(
            country: countryCode,
            number: number,
            enabled: false,
            handleCountry: (value) => {},
            handleNumber: (value) => {},
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'We\'ve sent you a code to $countryCode $number. \nPlease enter it below',
              textAlign: TextAlign.left,
            ),
            //todo make this dynamic
          ),
          Center(
            child: VerificationCode(
              fullBorder: true,
              margin: const EdgeInsets.only(top: 8),
              keyboardType: TextInputType.number,
              padding: const EdgeInsets.all(8),
              textStyle: const TextStyle(fontSize: 20.0),
              length: 6,
              onCompleted: (String value) {
                verificationCode = value;
                handleVerificationCode(value);
              },
              onEditing: (bool value) {},
            ),
          ),
        ],
      ),
    );
  }
}
