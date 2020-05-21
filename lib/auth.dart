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

  Future<void> logIn(SuccessfulLoginResponse response) async {
    final map = serializeResponse(response);
    final serialized = jsonEncode(map);
    this.preferences.setString(RESPONSE_KEY, serialized);
  }

  // NOTE : the built-in serializer does not serialize the user object, it only copies it
  Map<String, dynamic> serializeResponse(SuccessfulLoginResponse response) {
    Map<String, dynamic> json = {};
    if (response.status != null) json['status'] = response.status;
    if (response.token != null) json['token'] = response.token;
    if (response.user != null)
      json['user'] = serializeUserResponse(response.user);
    return json;
  }

  Map<String, dynamic> serializeUserResponse(SuccessfulLoginResponseUser user) {
    Map<String, dynamic> json = {};
    if (user.id != null) json['id'] = user.id;
    if (user.firstName != null) json['first_name'] = user.firstName;
    if (user.lastName != null) json['last_name'] = user.lastName;
    if (user.kind != null) json['kind'] = user.kind.value;
    return json;
  }

  Future<SuccessfulLoginResponse> getResponse() async {
    final response = this.preferences.getString(RESPONSE_KEY);
    final map = jsonDecode(response);
    return SuccessfulLoginResponse.fromJson(map);
  }

  Future<void> logout() async {
    await this.preferences.remove(RESPONSE_KEY);
  }
}
