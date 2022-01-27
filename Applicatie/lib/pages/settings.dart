import 'package:flutter/material.dart';
import 'package:pubnub/pubnub.dart';
import 'package:regenwaterput/pages/settings/buffer.dart';
import 'package:regenwaterput/pages/settings/location.dart';
import 'package:regenwaterput/pages/settings/measurements.dart';
import 'package:regenwaterput/globals/globals.dart' as globals;
import 'package:regenwaterput/services/authentication.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 0;

  var pubnub = PubNub(
      defaultKeyset: Keyset(
          subscribeKey: 'sub-c-91c29a42-7e21-11ec-8e41-c2c95df3c49a',
          publishKey: 'pub-c-d79f4642-99a1-44fa-9ece-708cde163413',
          uuid: const UUID('p9Mn66G4D5cOmBlSJSFCmSV8uQn2')));

  void pubnubSetting(setting, value) async {
    await pubnub.publish('p9Mn66G4D5cOmBlSJSFCmSV8uQn2', setting + "|" + value);
  }

  static const List<Widget> _pages = <Widget>[
    MeasurementsPage(),
    BufferPage(),
    LocationPage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return getWidget();
  }

  Widget getWidget() {
    if (_selectedIndex > 0) return _pages[_selectedIndex - 1];
    return _settings();
  }

  Column _settings() {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                height: 130.0,
              ),
              const Text(
                'Settings',
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
                  children: <Widget>[
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: const Icon(
                          Icons.straighten,
                          color: Colors.green,
                        ),
                      ),
                      title: const Text('Afmetingen'),
                      subtitle: Text(
                          double.parse(globals.width).toStringAsFixed(1) +
                              ' x ' +
                              double.parse(globals.length).toStringAsFixed(1) +
                              ' x ' +
                              double.parse(globals.depth).toStringAsFixed(1)),
                      trailing: const Icon(Icons.keyboard_arrow_right),
                      onTap: () {
                        _onItemTapped(1);
                      },
                    ),
                    _buildDivider(),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: const Icon(
                          Icons.height,
                          color: Colors.green,
                        ),
                      ),
                      title: const Text('Buffermeldingen'),
                      subtitle: Text(double.parse(globals.bufferLow)
                              .toStringAsFixed(0) +
                          '% - ' +
                          double.parse(globals.bufferHigh).toStringAsFixed(0) +
                          '%'),
                      trailing: const Icon(Icons.keyboard_arrow_right),
                      onTap: () {
                        _onItemTapped(2);
                      },
                    ),
                    _buildDivider(),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: const Icon(
                          Icons.location_city,
                          color: Colors.green,
                        ),
                      ),
                      title: const Text('Locatie'),
                      subtitle: Text(globals.location.toString()),
                      trailing: const Icon(Icons.keyboard_arrow_right),
                      onTap: () {
                        _onItemTapped(3);
                      },
                    ),
                    _buildDivider(),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 20)),
                        onPressed: () {
                          context.read<AuthenticationService>().signOut();
                        },
                        child: const Text('Sign Out'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
