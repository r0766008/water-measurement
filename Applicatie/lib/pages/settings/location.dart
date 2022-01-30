import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:regenwaterput/globals/globals.dart' as globals;

class LocationPage extends StatefulWidget {
  final Function function;
  const LocationPage({Key? key, required this.function}) : super(key: key);

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
    widget.function();
  }

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 40),
          height: 60,
          child: Row(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  widget.function();
                },
                child: Container(
                    padding: const EdgeInsets.all(22),
                    child: const Icon(
                      Icons.arrow_left,
                      color: Colors.white,
                    )),
              ),
              Container(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: const Text(
                  'Locatie',
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
        SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                          margin: const EdgeInsets.only(
                              right: 20, left: 20, top: 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              TextFormField(
                                controller: locationController,
                                decoration: getTextFieldDecoration('Zoeken'),
                                keyboardType: TextInputType.streetAddress,
                                style: const TextStyle(
                                  color: Colors.black,
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
                                height: 20,
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
                                    title: Text(predictions[index]
                                        .description
                                        .toString()),
                                    onTap: () {
                                      location = predictions[index]
                                          .description
                                          .toString();
                                      locationController.text =
                                          predictions[index]
                                              .description
                                              .toString();
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 16),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 20),
                            minimumSize: const Size.fromHeight(50),
                          ),
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
        ),
      ],
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

  InputDecoration getTextFieldDecoration(String label) {
    return InputDecoration(
      labelStyle: const TextStyle(
        color: Colors.grey,
      ),
      labelText: label,
      fillColor: Colors.grey,
      contentPadding: const EdgeInsets.only(left: 30.0, right: 15.0),
      errorStyle: const TextStyle(color: Colors.red),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100.0),
        borderSide: const BorderSide(
          color: Colors.grey,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100.0),
        borderSide: const BorderSide(
          color: Colors.grey,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100.0),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100.0),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
    );
  }
}
