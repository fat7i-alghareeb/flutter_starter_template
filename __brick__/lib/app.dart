import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // title: {
      //   {project_name},
      // },
      debugShowCheckedModeBanner: false,

      theme: ThemeData(useMaterial3: true),
      // home: Scaffold()
    );
  }
}
