import 'package:flutter/material.dart';

import '../../login/flow-content.dart';

class RegistrationFlow4 extends StatefulWidget {
  const RegistrationFlow4({super.key, required this.handleBirthday});

  final void Function(DateTime) handleBirthday;

  @override
  State<RegistrationFlow4> createState() => _RegistrationFlow4State();
}

class _RegistrationFlow4State extends State<RegistrationFlow4> {
  DateTime birthday = DateTime.now().subtract(const Duration(days: 365 * 18));
  RegExp birthdayRegex = RegExp(r'[0-9]{4}-[0-9]{2}-[0-9]{2}');
  String? error;

  void checkBirthday(String value) {
    if (birthdayRegex.hasMatch(value) &&
        DateTime.parse(value).isBefore(
            DateTime.now().subtract(const Duration(days: 365 * 18)))) {
      birthday = DateTime.parse(value);
      setState(() {
        error = null;
      });
      widget.handleBirthday(birthday);
    } else {
      setState(() {
        error = "Please enter a valid date";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlowContent(
      title: 'Sorry about the legal stuff',
      description:
          'For legal reasons we need your birthday. \n Just to make sure you\'re old enough to use achievd',
      buttonText: 'Let\'s goooo!',
      callback: () => widget.handleBirthday(birthday),
      content: Column(
        children: [
          TextField(
            onChanged: (value) => birthday = DateTime.parse(value),
            onSubmitted: (value) => widget.handleBirthday(birthday),
            controller: TextEditingController(
                text: birthday.toString().substring(0, 10)),
            autofocus: false,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Your birthday',
              helperText: 'YYYY-MM-DD',
            ),
          ),
          CalendarDatePicker(
            //todo: set min date
            initialDate:
                DateTime.now().subtract(const Duration(days: 365 * 18)),
            firstDate: DateTime(1900),
            lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
            onDateChanged: (value) {
              birthday = value;
              setState(() {});
            },
          )
        ],
      ),
    );
  }
}
