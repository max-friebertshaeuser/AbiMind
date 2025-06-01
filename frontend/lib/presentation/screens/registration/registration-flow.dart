import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Abimind/presentation/screens/registration/pages/registration-flow-0.dart';
import 'package:Abimind/presentation/screens/registration/pages/registration-flow-1.dart';
import 'package:Abimind/presentation/screens/registration/pages/registration-flow-2.dart';
import 'package:Abimind/presentation/screens/registration/pages/registration-flow-3.dart';
import 'package:Abimind/presentation/screens/registration/pages/registration-flow-4.dart';

import '../../../routes/routes.dart';

class RegistrationFlow extends StatefulWidget {
  const RegistrationFlow({super.key});

  @override
  State<RegistrationFlow> createState() => _RegistrationFlowState();
}

class _RegistrationFlowState extends State<RegistrationFlow> {
  String name = '';
  String phoneNumber = '';
  String verificationCode = '';
  String username = '';
  DateTime examDay = DateTime.now();
  RegExp phoneNumberRegex = RegExp(r'\+[0-9]');
  String number = '';
  String country = '';

  String verificationId = '';

  bool reachedUsername = false;

  PageController controller = PageController(
    initialPage: 0,
  );

  // change goBack behaviour
  //make things responsive
  //do the whole authentication thing
  // make go back impossible
  //make scrolling without values impossible
  //todo: save user in db
  //todo:

  @override
  Widget build(BuildContext context) {
    void handleName(String value) {
      setState(() {
        name = value;
      });
      if (name != '') {
        controller.nextPage(
            duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
        //todo: save name of user
      }
    }

    handlePhoneNumber(String value) async {
      phoneNumber = value;
      setState(() {
        country = value.substring(0, 3);
        number = value.substring(3);
      });
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        //todo: remove debug value
        verificationCompleted: (PhoneAuthCredential credential) async {
          //android only
          print(' verification completed');
          await FirebaseAuth.instance.signInWithCredential(credential);
          print('signed in');
          controller.animateToPage(3,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeIn);
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          this.verificationId = verificationId;
          print('code sent');
          controller.animateToPage(2,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeIn);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('code auto retrieval timeout');
        },
      );
    }

    handleVerificationCode(value) async {
      verificationCode = value;
      if (verificationCode != '') {
        print(verificationCode); //todo: remove debug value
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: verificationId, smsCode: verificationCode);

        await FirebaseAuth.instance.signInWithCredential(credential);
        if (FirebaseAuth.instance.currentUser != null) {
          controller.animateToPage(3,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeIn);
        } else {
          print('something went wrong');
        }
      }
    }

    handleUsername(value) {
      username = value;
      if (username != '') {
        FirebaseAuth.instance.currentUser!.updateDisplayName(username);
        //todo: what happens with double usernames?
        controller.nextPage(
            duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
      }
    }

    handleBirthday(value) {
      examDay = value;
      Navigator.removeRouteBelow(context, ModalRoute.of(context)!);
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }

    return SafeArea(
      child: PageView(
        controller: controller,
        onPageChanged: (value) {
          if (value == 3) reachedUsername = true;
          if (reachedUsername && value < 3) {
            controller.animateToPage(3,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn);
            if (value == 2) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You can\'t go back there'),
                  duration: Duration(milliseconds: 500),
                ),
              );
            }
          }
        },
        children: <Widget>[
          RegistrationFlow0(
            handleName: (name) => handleName(name),
            name: name,
          ),
          RegistrationFlow1(
            name: name,
            handlePhoneNumber: (phoneNumber) => handlePhoneNumber(phoneNumber),
          ),
          RegistrationFlow2(
            name: name,
            handleVerificationCode: handleVerificationCode,
            number: number,
            countryCode: country,
            verificationCode: verificationCode,
          ),
          RegistrationFlow3(handleUsername: handleUsername, username: username),
          RegistrationFlow4(
            handleExamDay: handleBirthday,
          ),
        ],
      ),
    );
  }
}
