import 'package:animated_glitch/animated_glitch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('glitch with shader display child correctly',
      (widgetTester) async {
    const key = Key('key');
    final child = Container(
      key: key,
      height: 300,
      width: 300,
      color: Colors.red,
    );

    await widgetTester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AnimatedGlitch(child: child),
      ),
    ));
    await widgetTester.pump();

    expect(find.byKey(key), findsOneWidget);
  });

}
