import 'package:flutter/material.dart';
import 'package:mobile_scolendar/api_exception.dart';
import 'package:mobile_scolendar/auth.dart';
import 'package:mobile_scolendar/components/app_drawer.dart';
import 'package:openapi/api.dart';

class SettingsRoute extends StatelessWidget {
  static const ROUTE_NAME = '/settings';
  Future<SuccessfulLoginResponse> userFuture;

  SettingsRoute() {
    userFuture = this.loadUser();
  }

  Future<SuccessfulLoginResponse> loadUser() async {
    final auth = await Auth.instance();
    return await auth.getResponse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scolendar'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
          future: userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done)
              return Container();

            final isAdmin = snapshot.data.user.kind == Role.aDM_;

            return Container(
                height: double.maxFinite,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    ListTile(
                      title: Text('Changer mon mot de passe'),
                      onTap: () async {
                        final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    UpdatePassword()));

                        if (result == null || !result) return;

                        Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text('Mot de passe mis-à-jour.')));
                      },
                    ),
                    if (isAdmin)
                      ListTile(
                        title: Text('Supprimer toutes les données du serveur'),
                        onTap: () {
                          // TODO
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text('Non implémenté pour le moment.')));
                        },
                      ),
                  ],
                ));
          }),
    );
  }
}

class UpdatePassword extends StatefulWidget {
  @override
  _UpdatePasswordState createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  bool obscureOldPassword = true;
  bool obscureNewPassword = true;

  bool enabled = true;

  String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Changement de mot de passe')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              if (errorMessage != null)
                Text(errorMessage,
                    style: TextStyle(color: Theme.of(context).errorColor)),
              TextFormField(
                controller: oldPasswordController,
                validator: this.validator,
                enabled: this.enabled,
                obscureText: this.obscureOldPassword,
                decoration: InputDecoration(
                  labelText: 'Ancien mot de passe',
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          this.obscureOldPassword = !this.obscureOldPassword;
                        });
                      },
                      icon: const Icon(Icons.remove_red_eye)),
                ),
              ),
              TextFormField(
                controller: newPasswordController,
                validator: this.validator,
                enabled: this.enabled,
                obscureText: this.obscureNewPassword,
                decoration: InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          this.obscureNewPassword = !this.obscureNewPassword;
                        });
                      },
                      icon: const Icon(Icons.remove_red_eye)),
                ),
              ),
              SizedBox(height: 16.0),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: double.infinity),
                child: RaisedButton(
                  color: Theme.of(context).primaryColor,
                  child: Text('Sauver', style: TextStyle(color: Colors.white)),
                  onPressed: onSubmit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String validator(String value) {
    if (value.isEmpty || value.length < 3) {
      return 'Le champ doint contenir au moins 3 caractères.';
    }

    return null;
  }

  void onSubmit() async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    setState(() {
      enabled = false;
    });

    var apiInstance = ProfileApi();
    var profileUpdateRequest = ProfileUpdateRequest();

    profileUpdateRequest.oldPassword = oldPasswordController.text;
    profileUpdateRequest.password = newPasswordController.text;

    try {
      await apiInstance.profilePut(profileUpdateRequest);
      Navigator.pop(context, true);
    } catch (e) {
      print("Exception when calling AuthApi->login: $e\n");

      setState(() {
        enabled = true;
        errorMessage = getErrorMessageFromException(e);
      });

      return;
    }
  }
}
