import 'package:flutter/material.dart';
import 'package:pubnub/pubnub.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:regenwaterput/globals/globals.dart' as globals;

class BufferPage extends StatefulWidget {
  const BufferPage({Key? key}) : super(key: key);

  @override
  _BufferPageState createState() => _BufferPageState();
}

class _BufferPageState extends State<BufferPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String bufferLow = double.parse(globals.bufferLow).toString();
  String bufferHigh = double.parse(globals.bufferHigh).toString();

  RangeValues _currentRangeValues = const RangeValues(10, 90);

  @override
  void initState() {
    _currentRangeValues = RangeValues(double.parse(bufferLow), double.parse(globals.bufferHigh));
    super.initState();
  }

  void save() async {
    var pubnub = PubNub(
        defaultKeyset: Keyset(
            subscribeKey: 'sub-c-91c29a42-7e21-11ec-8e41-c2c95df3c49a',
            publishKey: 'pub-c-d79f4642-99a1-44fa-9ece-708cde163413',
            uuid: const UUID('p9Mn66G4D5cOmBlSJSFCmSV8uQn2')));
    final SharedPreferences prefs = await _prefs;
    prefs.setString('bufferLow', bufferLow);
    prefs.setString('bufferHigh', bufferHigh);
    globals.bufferLow = bufferLow;
    globals.bufferHigh = bufferHigh;
    pubnub.publish('settings-p9Mn66G4D5cOmBlSJSFCmSV8uQn2', 'bufferLow|' + bufferLow);
    pubnub.publish('settings-p9Mn66G4D5cOmBlSJSFCmSV8uQn2', 'bufferHigh|' + bufferHigh);
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
              'Buffermeldingen',
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
                  RangeSlider(
                    values: _currentRangeValues,
                    min: 10,
                    max: 90,
                    divisions: 16,
                    labels: RangeLabels(
                      _currentRangeValues.start.round().toString(),
                      _currentRangeValues.end.round().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _currentRangeValues = values;
                        bufferLow = values.start.toString();
                        bufferHigh = values.end.toString();
                      });
                    },
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
