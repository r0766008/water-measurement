import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pubnub/pubnub.dart';
import 'package:regenwaterput/pages/authentication/sign_in.dart';
import 'package:regenwaterput/pages/pump.dart';
import 'package:regenwaterput/pages/settings.dart';
import 'package:regenwaterput/pages/waterlevel.dart';
import 'package:regenwaterput/services/authentication.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'globals/globals.dart' as globals;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  var pubnub = PubNub(
      defaultKeyset: Keyset(
          subscribeKey: 'sub-c-91c29a42-7e21-11ec-8e41-c2c95df3c49a',
          publishKey: 'pub-c-d79f4642-99a1-44fa-9ece-708cde163413',
          uuid: const UUID('p9Mn66G4D5cOmBlSJSFCmSV8uQn2')));
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SharedPreferences prefs = await _prefs;
  globals.width = (prefs.getString('width') ?? "20.0");
  globals.length = (prefs.getString('length') ?? "30.0");
  globals.depth = (prefs.getString('depth') ?? "40.0");
  globals.bufferLow = (prefs.getString('bufferLow') ?? "10");
  globals.bufferHigh = (prefs.getString('bufferHigh') ?? "90");
  globals.location = (prefs.getString('location') ?? "Geel, Belgium");
  globals.distance = double.parse((prefs.getString('depth') ?? "40.0"));
  pubnub.publish(
      'settings-p9Mn66G4D5cOmBlSJSFCmSV8uQn2',
      'init|width|' +
          globals.width +
          "|length|" +
          globals.length +
          "|depth|" +
          globals.depth +
          "|bufferLow|" +
          globals.bufferLow +
          "|bufferHigh|" +
          globals.bufferHigh);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(FirebaseAuth.instance),
        ),
        StreamProvider(
          initialData: null,
          create: (context) =>
              context.read<AuthenticationService>().authStateChanges,
        )
      ],
      child: MaterialApp(
        title: 'Regenwaterput',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        debugShowCheckedModeBanner: false,
        home: const AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      prefs = value;
      prefs.setBool('signing_in', true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    if (firebaseUser != null) {
      return const MyHomePage();
    }
    return const SignInPage();
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