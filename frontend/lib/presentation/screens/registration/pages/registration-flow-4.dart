import 'package:flutter/material.dart';

import '../../login/flow-content.dart';

class RegistrationFlow4 extends StatefulWidget {
  const RegistrationFlow4({super.key, required this.handleExamDay});

  final void Function(DateTime) handleExamDay;

  @override
  State<RegistrationFlow4> createState() => _RegistrationFlow4State();
}

class _RegistrationFlow4State extends State<RegistrationFlow4> {
  DateTime examDay = DateTime.now().subtract(const Duration(days: 365 * 18));
  RegExp dateRegex = RegExp(r'[0-9]{4}-[0-9]{2}-[0-9]{2}');
  String? error;

  void checkDate(String value) {
    if (dateRegex.hasMatch(value)) {
      examDay = DateTime.parse(value);
      setState(() {
        error = null;
      });
      widget.handleExamDay(examDay);
    } else {
      setState(() {
        error = "Please enter a valid date";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlowContent(
      title: 'Mathe Abitur Datum',
      description:
          'Um deinen optimalen Lernplan zu erstellen, benötigen wir dein Mathe Abitur Datum.',
      buttonText: 'Let\'s goooo!',
      callback: () => widget.handleExamDay(examDay),
      content: Column(
        children: [
          TextField(
            onChanged: (value) => examDay = DateTime.parse(value),
            onSubmitted: (value) => widget.handleExamDay(examDay),
            controller: TextEditingController(
                text: examDay.toString().substring(0, 10)),
            autofocus: false,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Mathe Abitur Datum ',
              helperText: 'YYYY-MM-DD',
            ),
          ),
          CalendarDatePicker(
            initialDate:
                DateTime.now().subtract(const Duration(days: 365 * 18)),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            onDateChanged: (value) {
              examDay = value;
              setState(() {});
            },
          )
        ],
      ),
    );
  }
}
