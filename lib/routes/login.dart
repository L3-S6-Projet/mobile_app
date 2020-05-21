import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scolendar/auth.dart';
import 'package:openapi/api.dart';

class LoginRoute extends StatefulWidget {
  static const ROUTE_NAME = '/login';

  @override
  _LoginRouteState createState() => _LoginRouteState();
}

class _LoginRouteState extends State<LoginRoute> {
  final _formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool enabled = true;
  bool obscureText = true;

  void onSubmit() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        enabled = false;
      });

      try {
        final response = await login();
        print(response);

        final auth = await Auth.instance();
        await auth.logIn(response);
      } catch (e) {
        print("Exception when calling AuthApi->login: $e\n");

        setState(() {
          enabled = true;
        });
      }
    } else {
      print('nop');
    }
  }

  Future<SuccessfulLoginResponse> login() async {
    var apiInstance = AuthApi();
    var loginRequest = LoginRequest();

    loginRequest.username = usernameController.text;
    loginRequest.password = passwordController.text;

    return await apiInstance.login(loginRequest);
  }

  String validator(String value) {
    if (value.isEmpty || value.length < 3) {
      return 'Le champ doint contenir au moins 3 caractères.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Scolendar'),
        ),
        body: Center(
            child: Form(
                key: _formKey,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: usernameController,
                        validator: this.validator,
                        enabled: this.enabled,
                        decoration: InputDecoration(
                          labelText: 'Nom d\'utilisateur',
                        ),
                      ),
                      TextFormField(
                        controller: passwordController,
                        validator: this.validator,
                        enabled: this.enabled,
                        obscureText: this.obscureText,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  this.obscureText = !this.obscureText;
                                });
                              },
                              icon: const Icon(Icons.remove_red_eye)),
                        ),
                      ),
                      RaisedButton(
                          color: theme.primaryColor,
                          child: Text(
                            'CONNEXION',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onPressed: (this.enabled) ? this.onSubmit : null),
                      Spacer(),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            style: theme.textTheme.bodyText2,
                            text: 'En se connectant, vous acceptez les ',
                            children: [
                              TextSpan(
                                  text: 'termes et conditions',
                                  style: TextStyle(
                                      decoration: TextDecoration.underline)),
                              TextSpan(
                                  text:
                                      '.\n\n© Scolendar 2020 - Tous droits réservés.')
                            ]),
                      )
                    ],
                  ),
                ))));
  }
}
