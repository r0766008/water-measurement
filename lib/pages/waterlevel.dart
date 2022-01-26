import 'package:flutter/material.dart';

import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

import 'package:pubnub/pubnub.dart';

import 'package:regenwaterput/globals/globals.dart' as globals;

class WaterLevelPage extends StatefulWidget {
  const WaterLevelPage({Key? key}) : super(key: key);

  @override
  _WaterLevelPageState createState() => _WaterLevelPageState();
}

class _WaterLevelPageState extends State<WaterLevelPage> {
  double width = 20.0;
  double length = 30.0;
  double depth = 40.0;

  double distance = globals.distance;
  double liter = globals.liter;
  int percentage = globals.percentage;

  late Subscription subscription;

  @override
  void initState() {
    var pubnub = PubNub(
        defaultKeyset: Keyset(
            subscribeKey: 'sub-c-91c29a42-7e21-11ec-8e41-c2c95df3c49a',
            publishKey: 'pub-c-d79f4642-99a1-44fa-9ece-708cde163413',
            uuid: const UUID('p9Mn66G4D5cOmBlSJSFCmSV8uQn2')));

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
    double maxLiter = (width * length * depth) / 1000;
    double newLiter = (width * length * (depth - newDistance)) / 1000;
    int newPercentage = ((newLiter / maxLiter) * 100).round();
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
              margin: const EdgeInsets.only(left: 20.0),
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
                        'Breedte: ' + width.toString() + " cm",
                        style: const TextStyle(
                          fontSize: 17.0,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Lengte: ' + length.toString() + " cm",
                        style: const TextStyle(
                          fontSize: 17.0,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Diepte: ' + depth.toString() + " cm",
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
