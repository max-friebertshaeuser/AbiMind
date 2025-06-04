import 'package:flutter/material.dart';

import '../../../../core/utils/constants.dart';

class MainSurfaceCard extends StatelessWidget {
  const MainSurfaceCard({super.key, required this.title, required this.boxFlex, required this.child});

  final String title;
  final int boxFlex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      flex: boxFlex,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsetsGeometry.only(left: 20), child: Text(title, style: kHeaderStyle)),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
              decoration: BoxDecoration(color: colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(20)),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
