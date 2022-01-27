import 'package:flutter/material.dart';
import 'package:pubnub/pubnub.dart';

class PumpPage extends StatefulWidget {
  const PumpPage({Key? key}) : super(key: key);

  @override
  _PumpPageState createState() => _PumpPageState();
}

class _PumpPageState extends State<PumpPage> {
  var pubnub = PubNub(
      defaultKeyset: Keyset(
          subscribeKey: 'sub-c-91c29a42-7e21-11ec-8e41-c2c95df3c49a',
          publishKey: 'pub-c-d79f4642-99a1-44fa-9ece-708cde163413',
          uuid: const UUID('p9Mn66G4D5cOmBlSJSFCmSV8uQn2')));

  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 20), primary: Colors.blue);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 30),
          ElevatedButton(
            style: style,
            onPressed: () {
              pubnub.publish('pump-p9Mn66G4D5cOmBlSJSFCmSV8uQn2', '1');
            },
            child: const Text('Pump water'),
          ),
        ],
      ),
    );
  }
}
