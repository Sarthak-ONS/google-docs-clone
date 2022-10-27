import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  Future settoken(String token) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString("token", token);
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future getToken() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? token = preferences.getString("token");
      return token;
    } catch (e) {
      print(e);
    }
    return null;
  }
}
