import 'package:flutter/material.dart';
import 'package:regenwaterput/pages/pump.dart';
import 'package:regenwaterput/pages/settings.dart';
import 'package:regenwaterput/pages/waterlevel.dart';

import 'globals/globals.dart' as globals;

void main() async {
  globals.distance = 40.0;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Regenwaterput',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1;

  static const List<Widget> _pages = <Widget>[
    PumpPage(),
    WaterLevelPage(),
    SettingsPage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.white60,
        backgroundColor: Colors.black87,
        elevation: 0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.power_settings_new),
            label: 'Pomp',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.speed),
            label: 'Waterniveau',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Instellingen',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      body: Container(
        color: Colors.black87,
        child: Center(
          child: _pages.elementAt(_selectedIndex),
        ),
      ),
    );
  }
}
