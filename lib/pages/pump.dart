import 'package:flutter/material.dart';

class PumpPage extends StatefulWidget {
  const PumpPage({Key? key}) : super(key: key);

  @override
  _PumpPageState createState() => _PumpPageState();
}

class _PumpPageState extends State<PumpPage> {
  @override
  Widget build(BuildContext context) {
    return const Text(
      'Pomp',
      style: TextStyle(color: Colors.white),
    );
  }
}
