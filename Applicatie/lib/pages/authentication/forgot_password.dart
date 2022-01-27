import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:form_field_validator/form_field_validator.dart';

import 'package:regenwaterput/services/authentication.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();

  void resetPassword() async {
    context
        .read<AuthenticationService>()
        .forgotPassword(
          email: emailController.text.trim(),
        )
        .then((res) => {
              if (res['error'] != null)
                {
                  // ignore: avoid_print
                  print(res['error'])
                }
              else if (res['success'] != null)
                {
                  // ignore: avoid_print
                  print(res['success'])
                }
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10, left: 10),
        child: Align(
          alignment: Alignment.topLeft,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.pop(context);
            },
            elevation: 0,
            child: const Icon(Icons.arrow_back_ios_outlined),
            backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              foregroundDecoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/login_background.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
                minHeight: MediaQuery.of(context).size.height * 0.33,
              ),
            ),
            Container(
              transform: Matrix4.translationValues(0.0, -69.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Row(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: 70,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    transform: Matrix4.translationValues(0.0, -30.0, 0.0),
                    child: const Center(
                      child: Text(
                        'Forgot Password',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: emailController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: getTextFieldDecoration('Email'),
                        validator: MultiValidator([
                          RequiredValidator(errorText: 'Email required'),
                          EmailValidator(errorText: 'Invalid Email'),
                        ]),
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        resetPassword();
                      }
                    },
                    child: Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.white,
                      ),
                      child: const Center(
                        child: Text(
                          'Reset Password',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
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
