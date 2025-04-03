import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//todo: denk dir smarte sachen aus
class PhonenumberTextfield extends StatefulWidget {
  PhonenumberTextfield({
    super.key,
    required this.handleNumber,
    required this.handleCountry,
    required this.enabled,
    required this.country,
    required this.number,
    this.error,
  });

  final bool enabled;
  String? error;
  String country;
  String number;
  final void Function(String) handleNumber;
  final void Function(String) handleCountry;

  @override
  State<PhonenumberTextfield> createState() => _PhonenumberTextfieldState();
}

class _PhonenumberTextfieldState extends State<PhonenumberTextfield> {
  late FocusNode phonefocus, countryfocus;

  // submit ? onChanged = handleNumber : onchanged = value => widget.country = value

  @override
  void initState() {
    super.initState();
    phonefocus = FocusNode();
    countryfocus = FocusNode();
    phonefocus.addListener(() {
      if (!phonefocus.hasFocus) {
        // widget.handleNumber(widget.number);
      }
    });
    countryfocus.addListener(() {
      if (!countryfocus.hasFocus) {
        // widget.handleCountry(widget.country);
      }
    });
  }

  @override
  void dispose() {
    phonefocus.dispose();
    countryfocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 66, //todo make this dynamic
          child: TextField(
            enabled: widget.enabled,
            onChanged: (value) {
              widget.country = value;
              widget.handleCountry(value);
            },
            onSubmitted: (value) {
              widget.handleCountry(value);
              FocusScope.of(context).requestFocus(phonefocus);
            },
            controller: TextEditingController(text: widget.country),
            inputFormatters: [
              FilteringTextInputFormatter(RegExp(r'\+?\d*'), allow: true),
              LengthLimitingTextInputFormatter(3),
            ],
            focusNode: countryfocus,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
            ),
            autofocus: true,
            decoration: InputDecoration(
              helperMaxLines: 1,
              errorText: widget.error != null ? ' ' : null,
              border: const OutlineInputBorder(),
              labelText: 'Country',
            ),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: MediaQuery.of(context).size.width -
              32 -
              72 -
              16, //todo make this dynamic
          child: TextField(
            enabled: widget.enabled,
            onChanged: (value) {
              widget.number = value;
              widget.handleNumber(value);
            },
            onSubmitted: (value) => widget.handleNumber(value),
            controller: TextEditingController(text: widget.number),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            focusNode: phonefocus,
            decoration: InputDecoration(
              errorText: widget.error,
              border: const OutlineInputBorder(),
              labelText: 'Your phone number',
            ),
          ),
        ),
      ],
    );
  }
}
