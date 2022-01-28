import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:regenwaterput/models/Measurement.dart';
import 'package:http/http.dart' as http;
import 'package:regenwaterput/globals/globals.dart' as globals;
import 'package:weather/weather.dart';

enum AppState { NOT_DOWNLOADED, DOWNLOADING, FINISHED_DOWNLOADING }

Future<List<Measurement>> fetchMeasurement() async {
  final response = await http.get(
      Uri.parse('https://water-measurement.herokuapp.com/api/measurements'));

  if (response.statusCode == 200) {
    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();

    return parsed
        .map<Measurement>((json) => Measurement.fromMap(json))
        .toList();
  } else {
    throw Exception('Failed to load measurements');
  }
}

class GraphPage extends StatefulWidget {
  const GraphPage({Key? key}) : super(key: key);

  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  String key = '1fdd8dd677917394a0e2ff370ba3d979';
  late WeatherFactory ws;
  List<Weather> _data = [];
  AppState _state = AppState.NOT_DOWNLOADED;
  double lat = 51.156;
  double lon = 5.456;

  late Future<List<Measurement>> futureMeasurement;
  List<FlSpot> distances = [];
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];
  bool showAvg = false;

  @override
  void initState() {
    super.initState();
    futureMeasurement = fetchMeasurement();
    ws = WeatherFactory(key);
  }

  void queryForecast() async {
    /// Removes keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      _state = AppState.DOWNLOADING;
    });

    List<Weather> forecasts = await ws.fiveDayForecastByLocation(lat, lon);
    setState(() {
      _data = forecasts;
      _state = AppState.FINISHED_DOWNLOADING;
    });
  }

  void queryWeather() async {
    /// Removes keyboard
    FocusScope.of(context).requestFocus(FocusNode());

    setState(() {
      _state = AppState.DOWNLOADING;
    });

    Weather weather = await ws.currentWeatherByLocation(lat, lon);
    setState(() {
      _data = [weather];
      _state = AppState.FINISHED_DOWNLOADING;
    });
  }

  Widget contentFinishedDownload() {
    return Center(
      child: ListView.separated(
        itemCount: _data.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_data[index].toString()),
          );
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
      ),
    );
  }

  Widget contentDownloading() {
    return Container(
      margin: EdgeInsets.all(25),
      child: Column(children: [
        Text(
          'Fetching Weather...',
          style: TextStyle(fontSize: 20),
        ),
        Container(
            margin: EdgeInsets.only(top: 50),
            child: Center(child: CircularProgressIndicator(strokeWidth: 10)))
      ]),
    );
  }

  Widget contentNotDownloaded() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Press the button to download the Weather forecast',
          ),
        ],
      ),
    );
  }

  Widget _buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(5),
          child: TextButton(
            child: Text(
              'Fetch weather',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: queryWeather,
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue)),
          ),
        ),
        Container(
          margin: EdgeInsets.all(5),
          child: TextButton(
            child: Text(
              'Fetch forecast',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: queryForecast,
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue)),
          ),
        )
      ],
    );
  }

  Widget _resultView() => _state == AppState.FINISHED_DOWNLOADING
      ? contentFinishedDownload()
      : _state == AppState.DOWNLOADING
          ? contentDownloading()
          : contentNotDownloaded();

  int calculate(double value) {
    double maxLiter = (double.parse(globals.width) *
            double.parse(globals.length) *
            double.parse(globals.depth)) /
        1000;
    double newLiter = (double.parse(globals.width) *
            double.parse(globals.length) *
            (double.parse(globals.depth) - value)) /
        1000;
    return ((newLiter / maxLiter) * 100).round().clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<List<Measurement>>(
          future: futureMeasurement,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print(snapshot.data!.length);
              for (int i = snapshot.data!.length - 1; i >= 0; i--) {
                distances.add(FlSpot(
                    (snapshot.data!.length - i - 1).toDouble(),
                    calculate(snapshot.data![i].distance.toDouble())
                        .toDouble()));
              }
              return AspectRatio(
                aspectRatio: 1.50,
                child: Container(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(18),
                      ),
                      color: Color(0xff232d37)),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        right: 18.0, left: 12.0, top: 24, bottom: 12),
                    child: LineChart(mainData()),
                  ),
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        _buttons(),
        Text(
          'Output:',
          style: TextStyle(fontSize: 20),
        ),
        Divider(
          height: 20.0,
          thickness: 2.0,
        ),
        SafeArea(child: _resultView())
      ],
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 10,
          interval: 1,
          getTextStyles: (context, value) => const TextStyle(
              color: Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontSize: 16),
          getTitles: (value) {
            switch (value.toInt()) {
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTextStyles: (context, value) => const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return '0%';
              case 25:
                return '25%';
              case 50:
                return '50%';
              case 75:
                return '75%';
              case 100:
                return '100%';
            }
            return '';
          },
          reservedSize: 50,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: distances.length.toDouble() - 1,
      minY: 0,
      maxY: 100,
      lineBarsData: [
        LineChartBarData(
          spots: distances,
          isCurved: true,
          colors: gradientColors,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }
}
