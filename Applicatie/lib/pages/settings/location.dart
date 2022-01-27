import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:regenwaterput/globals/globals.dart' as globals;

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String location = globals.location;
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  final locationController = TextEditingController();

  @override
  void initState() {
    String apiKey = 'AIzaSyDacM0UqknLNI78PKPYrlZ8KeK7FPgBEoI';
    googlePlace = GooglePlace(apiKey);
    locationController.text = location;
    super.initState();
  }

  void save() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('location', location);
    globals.location = location;
  }

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
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
              'Locatie',
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
                  SafeArea(
                    child: Container(
                      margin:
                          const EdgeInsets.only(right: 20, left: 20, top: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextFormField(
                            controller: locationController,
                            decoration: const InputDecoration(
                              labelText: "Zoeken",
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blue,
                                  width: 2.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black54,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                autoCompleteSearch(value);
                              } else {
                                if (predictions.isNotEmpty && mounted) {
                                  setState(() {
                                    predictions = [];
                                  });
                                }
                              }
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: predictions.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(
                                    Icons.pin_drop,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                    predictions[index].description.toString()),
                                onTap: () {
                                  location = predictions[index].description.toString();
                                  locationController.text = predictions[index].description.toString();
                                  FocusScope.of(context).unfocus();
                                  setState(() {
                                    predictions = [];
                                  });
                                },
                              );
                            },
                          ),
                        ],
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

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
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
