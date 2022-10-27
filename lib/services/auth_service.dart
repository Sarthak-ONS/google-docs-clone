import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/constants.dart';
import 'package:google_docs_clone/models/error_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

import 'package:google_docs_clone/models/user_model.dart';

final authServiceProvider = Provider(
  (ref) => AuthService(googleSignIn: GoogleSignIn(), client: Client()),
);

final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthService {
  final GoogleSignIn _googleSignIn;
  final Client _client;

  AuthService({required GoogleSignIn googleSignIn, required Client client})
      : _googleSignIn = googleSignIn,
        _client = client;

  Future<ErrorModel> signInWithGoogle() async {
    ErrorModel error = ErrorModel(
      error: "Some unexpected Error Occured",
      data: null,
    );
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

        var res = await _client.post(Uri.parse(host + '/api/signup'),
            headers: headerMap, body: userAcc.toJson());

        switch (res.statusCode) {
          case 200:
            final newUser = userAcc.copyWith(
              uid: jsonDecode(res.body)['_id'],
            );
            error = ErrorModel(error: null, data: newUser);
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
}
