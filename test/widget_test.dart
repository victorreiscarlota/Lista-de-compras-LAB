// Testes de widget para o Todo App

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/main.dart';

void main() {
  testWidgets('Teste inicial do Todo App', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Todo App'), findsOneWidget); 
    expect(find.byType(TextField), findsOneWidget); 
    expect(find.byIcon(Icons.add), findsOneWidget); 
  });

  testWidgets('Teste de adição de tarefa', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    
    await tester.enterText(find.byType(TextField), 'Comprar leite');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('Comprar leite'), findsOneWidget);
  });
}
