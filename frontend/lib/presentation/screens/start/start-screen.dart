import 'dart:ffi';

import 'package:flutter/material.dart';

class StarScreen extends StatelessWidget {
  const StarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'AbiMind',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {}, // Optional drawer
        ),
      ),
      body: Container(
        child: Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(
              flex: 1,
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Card(
                    title: 'Current Exercise',
                    boxFlex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: Colors.yellow,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Card(
                    title: 'Streak',
                    boxFlex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 0, 0, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Card extends StatelessWidget {
  const Card({
    super.key,
    required this.title,
    required this.boxFlex,
    required this.child,
  });

  final String title;
  final int boxFlex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: boxFlex,
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
