import 'package:flutter/material.dart';
{{#include_flavors}}
import 'flavors.dart';
{{/include_flavors}}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final title = {{#include_flavors}}F.title{{/include_flavors}}{{^include_flavors}}'{{project_name}}'{{/include_flavors}};

    return MaterialApp(
      title: title,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Center(
          child: Text(
            'Hello from $title',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
    );
  }
}

