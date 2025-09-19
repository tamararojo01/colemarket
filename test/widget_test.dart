import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:colemarket/main.dart'; // ajusta si tu paquete es 'colemarket'

void main() {
  testWidgets('smoke test', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ColeMarketApp()));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}