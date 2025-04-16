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
              flex: 2,
              child: Column(
                children: [
                  Container(
                      width: 100,
                      height: 100,
                      color: Colors.red),
                  Container(
                      width: 100,
                      height: 100,
                      color: Colors.blue),
                ],
              ),
            ),
            Expanded(
                flex: 1,
                child:Container(
                  width: 100,
                  height: 100,
                  color: Colors.green)
            )


          ],
        ),
      ),
    );
  }
}
