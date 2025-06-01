import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:Abimind/presentation/screens/login/pages/login-flow-1.dart';
import 'package:Abimind/routes/routes.dart';

import 'pages/login-flow-0.dart';

class LoginFlow extends StatefulWidget {
  const LoginFlow({super.key});

  static const String route = '/login-flow';

  @override
  State<LoginFlow> createState() => _LoginFlowState();
}

class _LoginFlowState extends State<LoginFlow> {
  final PageController controller = PageController(
    initialPage: 0,
  );
  String number = '';
  String country = '';
  String phoneNumber = '';
  String verificationCode = '';
  String verificationId = '';

  @override
  Widget build(BuildContext context) {
    handlePhoneNumber(value) async {
      phoneNumber = value;
      country = value.substring(0, 3);
      number = value.substring(3);
      if (phoneNumber != '') {
        print(number);
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          //todo: remove debug value
          verificationCompleted: (PhoneAuthCredential credential) async {
            //android only
            print('verification completed');
            await FirebaseAuth.instance.signInWithCredential(credential);
            print('signed in');
            Navigator.removeRouteBelow(context, ModalRoute.of(context)!);
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          },
          verificationFailed: (FirebaseAuthException e) {
            print(e);
          },
          codeSent: (String verificationId, int? resendToken) {
            this.verificationId = verificationId;
            print('code sent');
            controller.animateToPage(1,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn);
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            print('code auto retrieval timeout ');
          },
        );
      }
    }

    handleVerificationCode(value) async {
      verificationCode = value;
      if (verificationCode != '') {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: verificationId, smsCode: verificationCode);

        await FirebaseAuth.instance.signInWithCredential(credential);
        if (FirebaseAuth.instance.currentUser != null) {
          Navigator.removeRouteBelow(context, ModalRoute.of(context)!);
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else {
          print('something went wrong with the verification code');
        }
      }
    }

    return PageView(
      controller: controller,
      children: <Widget>[
        LoginFlow0(
          handlePhoneNumber: handlePhoneNumber,
          number: number,
          country: country,
        ),
        LoginFlow1(
          handleVerificationCode: handleVerificationCode,
          number: number,
          country: country,
        ),
      ],
    );
  }
}
