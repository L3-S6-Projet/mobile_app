import 'dart:convert';

import 'package:openapi/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

const RESPONSE_KEY = 'auth_response';

class Auth {
  static Auth _instance;

  static instance() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = Auth._internal(prefs);
    }

    return _instance;
  }

  SharedPreferences preferences;

  /* Real constructor */
  Auth._internal(SharedPreferences preferences) {
    this.preferences = preferences;
  }

  Future<bool> isLoggedIn() async {
    return this.preferences.containsKey(RESPONSE_KEY);
  }

  Future<void> logIn(response) async {
    final serialized = jsonEncode(response);
    this.preferences.setString(RESPONSE_KEY, serialized);
  }

  Future<SuccessfulLoginResponse> getResponse() async {
    final response = this.preferences.getString(RESPONSE_KEY);
    return jsonDecode(response);
  }
}
