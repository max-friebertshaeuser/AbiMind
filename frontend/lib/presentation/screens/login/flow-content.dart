import '../../../core/utils/constants.dart';
import '../../widgets/custom-scaffold.dart';
import '../../widgets/full-width-button.dart';
import 'package:flutter/material.dart';

class FlowContent extends StatelessWidget {
  const FlowContent(
      {super.key,
      required this.title,
      required this.description,
      this.content,
      required this.buttonText,
      required this.callback,
      this.first = false});

  final String title, description;
  final Widget? content;
  final String buttonText;
  final void Function() callback;
  final bool first;

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        leading: first ? null : const SizedBox(),
        centerTitle: true,
        title: const Text(
          'AbiMind',
          style: kAchievdHeaderStyle,
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(title, style: kHeaderStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(description),
            ),
            Expanded(child: content ?? const SizedBox()),
            FullWidthButton(
              text: buttonText,
              onPressed: callback,
            ),
          ],
        ),
      ),
    );
  }
}
