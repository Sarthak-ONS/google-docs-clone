import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/constants.dart';
import 'package:google_docs_clone/models/error_model.dart';
import 'package:google_docs_clone/services/local_storage_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

import 'package:google_docs_clone/models/user_model.dart';

final authServiceProvider = Provider(
  (ref) => AuthService(
      googleSignIn: GoogleSignIn(),
      client: Client(),
      localStorageService: LocalStorageService()),
);

final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthService {
  final GoogleSignIn _googleSignIn;
  final Client _client;

  final LocalStorageService _localStorageService;

  AuthService(
      {required GoogleSignIn googleSignIn,
      required Client client,
      required LocalStorageService localStorageService})
      : _googleSignIn = googleSignIn,
        _localStorageService = localStorageService,
        _client = client;

  Future<ErrorModel> signInWithGoogle() async {
    ErrorModel error = ErrorModel(
      error: "Some unexpected Error Occured",
      data: null,
    );
    print("Starterd Signing in with Google");
    try {
      final user = await _googleSignIn.signIn();
      if (user != null) {
        final userAcc = UserModel(
          email: user.email,
          name: user.displayName!,
          profilePic: user.photoUrl!,
          uid: '',
          token: '',
        );

        final headerMap = {"Content-Type": "Application/json; charset=UTF-8"};

        var res = await _client.post(
          Uri.parse(host + '/api/signup'),
          headers: headerMap,
          body: userAcc.toJson(),
        );

        print(json.decode(res.body));
        switch (res.statusCode) {
          case 200:
            final newUser = userAcc.copyWith(
                uid: jsonDecode(res.body)['user']['_id'],
                token: jsonDecode(res.body)['token']);
            print(newUser.uid);
            error = ErrorModel(error: null, data: newUser);
            _localStorageService.settoken(newUser.token);
            break;
          default:
        }
      }
    } catch (e) {
      print(e);
      error = ErrorModel(error: e.toString(), data: null);
    }

    return error;
  }

  Future<ErrorModel> getUserData() async {
    ErrorModel error =
        ErrorModel(error: 'Some Unexpected Error has Occured', data: null);

    try {
      String? token = await _localStorageService.getToken();

      if (token != null) {
        final headerMap = {
          "Content-Type": "Application/json; charset=UTF-8",
          'x-auth-token': token
        };
        var res = await _client.get(
          Uri.parse(host + '/'),
          headers: headerMap,
        );

        switch (res.statusCode) {
          case 200:
            final newUser = UserModel.fromJson(
              json.encode(
                json.decode(res.body)['user'],
              ),
            ).copyWith(token: token);
            error = ErrorModel(error: null, data: newUser);
            _localStorageService.settoken(newUser.token);
            break;
          default:
        }
      }
    } catch (e) {
      error = ErrorModel(
        error: e.toString(),
        data: null,
      );
    }

    return error;
  }

  void signout() {
    _localStorageService.settoken("");
  }
}
