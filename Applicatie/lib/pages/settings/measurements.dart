import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pubnub/pubnub.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:regenwaterput/globals/globals.dart' as globals;

class MeasurementsPage extends StatefulWidget {
  const MeasurementsPage({Key? key}) : super(key: key);

  @override
  _MeasurementsPageState createState() => _MeasurementsPageState();
}

class _MeasurementsPageState extends State<MeasurementsPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String width = double.parse(globals.width).toStringAsFixed(1);
  String length = double.parse(globals.length).toStringAsFixed(1);
  String depth = double.parse(globals.depth).toStringAsFixed(1);

  void save() async {
    var pubnub = PubNub(
        defaultKeyset: Keyset(
            subscribeKey: 'sub-c-91c29a42-7e21-11ec-8e41-c2c95df3c49a',
            publishKey: 'pub-c-d79f4642-99a1-44fa-9ece-708cde163413',
            uuid: const UUID('p9Mn66G4D5cOmBlSJSFCmSV8uQn2')));
    final SharedPreferences prefs = await _prefs;
    prefs.setString('width', width);
    prefs.setString('length', length);
    prefs.setString('depth', depth);
    globals.width = width;
    globals.length = length;
    globals.depth = depth;
    pubnub.publish('settings-p9Mn66G4D5cOmBlSJSFCmSV8uQn2', 'width|' + width);
    pubnub.publish('settings-p9Mn66G4D5cOmBlSJSFCmSV8uQn2', 'length|' + length);
    pubnub.publish('settings-p9Mn66G4D5cOmBlSJSFCmSV8uQn2', 'depth|' + depth);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Afmetingen',
              style: TextStyle(
                  fontSize: 28.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            Card(
              elevation: 4.0,
              margin: const EdgeInsets.fromLTRB(0, 8.0, 0, 16.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      padding: const EdgeInsets.only(top: 8, left: 8),
                      child: const Text(
                        'Breedte:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextFormField(
                      initialValue: width,
                      onChanged: (text) {
                        width = text;
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Breedte',
                      ),
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.only(top: 8, left: 8),
                      child: const Text(
                        'Lengte:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextFormField(
                      initialValue: length,
                      onChanged: (text) {
                        length = text;
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Lengte',
                      ),
                    ),
                  ),
                  Container(
                      padding: const EdgeInsets.only(top: 8, left: 8),
                      child: const Text(
                        'Diepte:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 8, right: 8, top: 8, bottom: 16),
                    child: TextFormField(
                      initialValue: depth,
                      onChanged: (text) {
                        depth = text;
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Diepte',
                      ),
                    ),
                  ),
                  _buildDivider(),
                  Container(
                    alignment: Alignment.center,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 20)),
                      onPressed: () {
                        save();
                      },
                      child: const Text('Opslaan'),
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

  Container _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      width: double.infinity,
      height: 1.0,
      color: Colors.grey.shade400,
    );
  }
}
