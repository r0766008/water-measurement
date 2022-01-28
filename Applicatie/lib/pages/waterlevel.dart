import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:pubnub/pubnub.dart';
import 'package:regenwaterput/globals/globals.dart' as globals;

class WaterLevelPage extends StatefulWidget {
  const WaterLevelPage({Key? key}) : super(key: key);

  @override
  _WaterLevelPageState createState() => _WaterLevelPageState();
}

class _WaterLevelPageState extends State<WaterLevelPage> {
  var pubnub = PubNub(
      defaultKeyset: Keyset(
          subscribeKey: 'sub-c-91c29a42-7e21-11ec-8e41-c2c95df3c49a',
          publishKey: 'pub-c-d79f4642-99a1-44fa-9ece-708cde163413',
          uuid: const UUID('p9Mn66G4D5cOmBlSJSFCmSV8uQn2')));

  double width = double.parse(globals.width);
  double length = double.parse(globals.length);
  double depth = double.parse(globals.depth);

  double distance = globals.distance;
  double liter = globals.liter;
  int percentage = globals.percentage;

  late Subscription subscription;

  @override
  void initState() {
    subscription = pubnub.subscribe(channels: {'p9Mn66G4D5cOmBlSJSFCmSV8uQn2'});
    subscription.messages.listen((envelope) async {
      calculate(double.parse(envelope.payload));
    });
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
    await subscription.dispose();
  }

  void calculate(double newDistance) {
    const double pi = 3.1415926535897932;
    double maxLiter = (pi * (length * length) * depth) / 1000;
    double newLiter =
        (pi * (length * length) * (depth - newDistance.clamp(0, depth))) / 1000;
    int newPercentage = ((newLiter / maxLiter) * 100).round().clamp(0, 100);
    setState(() {
      distance = newDistance;
      liter = newLiter;
      percentage = newPercentage;
    });
    globals.distance = newDistance;
    globals.liter = newLiter;
    globals.percentage = newPercentage;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            const SizedBox(
              height: 130.0,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Waterniveau',
                    style: TextStyle(
                        fontSize: 28.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Afmetingen',
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        'Breedte: ' + width.toStringAsFixed(1) + " cm",
                        style: const TextStyle(
                          fontSize: 17.0,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Lengte: ' + length.toStringAsFixed(1) + " cm",
                        style: const TextStyle(
                          fontSize: 17.0,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Diepte: ' + depth.toStringAsFixed(1) + " cm",
                        style: const TextStyle(
                          fontSize: 17.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Berekeningen',
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        'Gemeten afstand: ' +
                            distance.toStringAsFixed(1) +
                            " cm",
                        style: const TextStyle(
                          fontSize: 17.0,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Aantal liter: ' + liter.toStringAsFixed(2) + " l",
                        style: const TextStyle(
                          fontSize: 17.0,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Percentage: ' + percentage.toString() + " %",
                        style: const TextStyle(
                          fontSize: 17.0,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      const Text(
                        'Instellingen',
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Text(
                        "Automatich/manueel:",
                        style: TextStyle(
                          fontSize: 17.0,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      FlutterSwitch(
                        width: 70.0,
                        height: 30.0,
                        valueFontSize: 12.0,
                        toggleSize: 20.0,
                        value: globals.pumpstatus,
                        borderRadius: 30.0,
                        padding: 6.0,
                        showOnOff: true,
                        onToggle: (val) {
                          setState(() {
                            globals.pumpstatus = val;
                          });
                          print(globals.pumpstatus);
                          pubnub.publish('pump-p9Mn66G4D5cOmBlSJSFCmSV8uQn2',
                              "pumpstate|" + globals.pumpstatus.toString());
                        },
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Text(
                        "pomp aan/uit:",
                        style: TextStyle(
                          fontSize: 17.0,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      FlutterSwitch(
                        width: 70.0,
                        height: 30.0,
                        valueFontSize: 12.0,
                        toggleSize: 20.0,
                        value: globals.pumpAutomatic,
                        borderRadius: 30.0,
                        padding: 6.0,
                        showOnOff: true,
                        onToggle: (val1) {
                          setState(() {
                            globals.pumpAutomatic = val1;
                          });
                          print(globals.pumpAutomatic);
                          pubnub.publish(
                              'pump-p9Mn66G4D5cOmBlSJSFCmSV8uQn2',
                              "pumpAutomatic|" +
                                  globals.pumpAutomatic.toString());
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Center(
          child: SizedBox(
            width: 100.0,
            height: size.height - 400,
            child: LiquidLinearProgressIndicator(
              borderColor: Colors.transparent,
              borderWidth: 0,
              borderRadius: 30.0,
              value: percentage / 100,
              direction: Axis.vertical,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation(Colors.blue),
              center: Text(
                "${percentage.toStringAsFixed(0)}%",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
