import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:pubnub/pubnub.dart';
import 'package:regenwaterput/globals/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

class WaterLevelPage extends StatefulWidget {
  const WaterLevelPage({Key? key}) : super(key: key);

  @override
  _WaterLevelPageState createState() => _WaterLevelPageState();
}

class _WaterLevelPageState extends State<WaterLevelPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
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

  RangeValues _currentRangeValues = const RangeValues(10, 90);

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
    double maxLiter = (pi * ((length / 2) * (length / 2)) * depth) / 1000;
    double newLiter = (pi *
            ((length / 2) * (length / 2)) *
            (depth - newDistance.clamp(0, depth))) /
        1000;
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

  void changeBuffer(value, mode) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString(mode, value.toString());
    if (mode == 'bufferLow') {
      globals.bufferLow = value.toString();
    } else {
      globals.bufferHigh = value.toString();
    }
    pubnub.publish(
        'settings-p9Mn66G4D5cOmBlSJSFCmSV8uQn2', mode + '|' + value.toString());
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 40),
          height: 60,
          child: Row(
            children: <Widget>[
              const SizedBox(
                width: 68,
              ),
              Container(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: const Text(
                  'Waterniveau',
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Container(
                  height: size.height - 400,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            value: globals.pumpAutomatic,
                            borderRadius: 30.0,
                            padding: 6.0,
                            showOnOff: true,
                            onToggle: (val1) {
                              setState(() {
                                globals.pumpAutomatic = val1;
                              });
                              pubnub.publish(
                                  'pump-p9Mn66G4D5cOmBlSJSFCmSV8uQn2',
                                  "pumpAutomatic|" +
                                      globals.pumpAutomatic.toString());
                            },
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          const Text(
                            "Pomp aan/uit:",
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
                              pubnub.publish(
                                  'pump-p9Mn66G4D5cOmBlSJSFCmSV8uQn2',
                                  "pumpstate|" + globals.pumpstatus.toString());
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: size.height - 400,
              child: Stack(
                children: [
                  RotatedBox(
                    quarterTurns: 3,
                    child: Center(
                      child: SizedBox(
                        height: 75,
                        width: size.height - 400,
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(30)),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.white,
                            valueColor:
                                const AlwaysStoppedAnimation(Colors.blue),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 21),
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: SliderTheme(
                        data: SliderThemeData(
                          thumbColor: Colors.red,
                          overlayColor: Colors.transparent,
                          rangeThumbShape: _CustomRangeThumbShape(),
                          activeTrackColor: Colors.transparent,
                          inactiveTickMarkColor: Colors.transparent,
                          valueIndicatorTextStyle:
                              const TextStyle(color: Colors.red),
                          rangeValueIndicatorShape:
                              const CustomSliderThumbCircle(thumbRadius: 24.0),
                          showValueIndicator: ShowValueIndicator.always,
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: RangeSlider(
                            inactiveColor: Colors.transparent,
                            values: _currentRangeValues,
                            min: 10,
                            max: 90,
                            divisions: 16,
                            labels: RangeLabels(
                              _currentRangeValues.start.round().toString(),
                              _currentRangeValues.end.round().toString(),
                            ),
                            onChangeEnd: (end) {
                              changeBuffer(end.start, 'bufferLow');
                              changeBuffer(end.end, 'bufferHigh');
                            },
                            onChanged: (RangeValues values) {
                              setState(() {
                                _currentRangeValues = values;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: 75,
                    child: Center(
                      child: Text(
                        percentage.toString() + "%",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}

class _CustomRangeThumbShape extends RangeSliderThumbShape {
  static const double _thumbSize = 37.5;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(_thumbSize);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool? isOnTop,
    TextDirection? textDirection,
    SliderThemeData? sliderTheme,
    Thumb? thumb,
    bool? isPressed,
  }) {
    final Canvas canvas = context.canvas;

    Path thumbPath = _line(_thumbSize, center);
    canvas.drawPath(thumbPath, Paint()..color = sliderTheme!.thumbColor!);
  }
}

Path _line(double size, Offset thumbCenter) {
  final Path thumbPath = Path();
  thumbPath.moveTo(thumbCenter.dx + 1, thumbCenter.dy);
  thumbPath.lineTo(thumbCenter.dx + 1, thumbCenter.dy + 37.5);
  thumbPath.lineTo(thumbCenter.dx - 1, thumbCenter.dy + 37.5);
  thumbPath.lineTo(thumbCenter.dx - 1, thumbCenter.dy);
  thumbPath.moveTo(thumbCenter.dx - 1, thumbCenter.dy);
  thumbPath.lineTo(thumbCenter.dx - 1, thumbCenter.dy - 37.5);
  thumbPath.lineTo(thumbCenter.dx + 1, thumbCenter.dy - 37.5);
  thumbPath.lineTo(thumbCenter.dx + 1, thumbCenter.dy);
  thumbPath.close();
  return thumbPath;
}

class CustomSliderThumbCircle extends RangeSliderValueIndicatorShape {
  final double thumbRadius;
  final int min;
  final int max;

  const CustomSliderThumbCircle({
    required this.thumbRadius,
    this.min = 10,
    this.max = 90,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete,
      {required TextPainter labelPainter, required double textScaleFactor}) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double>? activationAnimation,
    Animation<double>? enableAnimation,
    bool? isDiscrete,
    bool? isOnTop,
    required TextPainter labelPainter,
    required RenderBox? parentBox,
    required SliderThemeData? sliderTheme,
    TextDirection? textDirection,
    double? value,
    double? textScaleFactor,
    Size? sizeWithOverflow,
    Thumb? thumb,
  }) {
    final Canvas canvas = context.canvas;

    TextSpan span = TextSpan(
      style: TextStyle(
        fontSize: thumbRadius * .8,
        fontWeight: FontWeight.w700,
        color: sliderTheme?.thumbColor,
      ),
      text: getValue(value!),
    );

    TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp.layout();
    Offset textCenter =
        Offset(center.dx - (tp.width / 2), center.dy - (tp.height + 45));
    tp.paint(canvas, textCenter);
  }

  String getValue(double value) {
    return (min + (max - min) * value).round().toString();
  }
}
