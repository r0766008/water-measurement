import 'dart:async';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:regenwaterput/globals/globals.dart' as globals;

class RoofPage extends StatefulWidget {
  final Function function;
  const RoofPage({Key? key, required this.function}) : super(key: key);

  @override
  _RoofPageState createState() => _RoofPageState();
}

class _RoofPageState extends State<RoofPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController roofController = TextEditingController();

  void save() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('roof', roofController.text);
    globals.roof = roofController.text;
    widget.function();
  }

  @override
  Widget build(BuildContext context) {
    roofController.text = globals.roof;
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
                  'Dakoppervlakte',
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 16),
                          child: TextFormField(
                            controller: roofController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: getTextFieldDecoration('Dakoppervlakte'),
                            validator: (value) => value!.isEmpty
                                ? 'Vul het dakoppervlakte in'
                                : (RegExp(r'^[0-9]+(,[0-9]{3})*(\.[0-9]+)*$')
                                        .hasMatch(value)
                                    ? null
                                    : 'Het dakoppervlakte heeft geen geldige getalwaarde'),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              color: Colors.black,
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
                              if (_formKey.currentState!.validate()) {
                                save();
                              }
                            },
                            child: const Text('Opslaan'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool isNumeric(String s) {
    // ignore: unnecessary_null_comparison
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
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
