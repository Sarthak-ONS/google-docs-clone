import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/models/document_model.dart';
import 'package:google_docs_clone/models/error_model.dart';
import 'package:http/http.dart';

import '../constants.dart';

final documentSerivceProvider =
    Provider(((ref) => DocumentService(client: Client())));

class DocumentService {
  final Client _client;

  DocumentService({required Client client}) : _client = client;

  Future<ErrorModel> createDocument({required String token}) async {
    ErrorModel error =
        ErrorModel(error: 'Some Unexpected Error has Occured', data: null);

    try {
      final headerMap = {
        "Content-Type": "Application/json; charset=UTF-8",
        'x-auth-token': token
      };
      var res = await _client.post(
        Uri.parse(host + '/doc/create'),
        headers: headerMap,
        body: json.encode({
          'createdAt': DateTime.now().microsecondsSinceEpoch,
        }),
      );
      switch (res.statusCode) {
        case 200:
          error =
              ErrorModel(error: null, data: DocumentModel.fromJson(res.body));
          break;
        default:
          error = ErrorModel(
            error: res.body,
            data: null,
          );
      }
    } catch (e) {
      error = ErrorModel(
        error: e.toString(),
        data: null,
      );
    }

    return error;
  }

  Future<ErrorModel> getDocuments({required String token}) async {
    ErrorModel error =
        ErrorModel(error: 'Some Unexpected Error has Occured', data: null);

    try {
      final headerMap = {
        "Content-Type": "Application/json; charset=UTF-8",
        'x-auth-token': token
      };
      var res = await _client.get(
        Uri.parse(host + '/docs/me'),
        headers: headerMap,
      );
      switch (res.statusCode) {
        case 200:
          List<DocumentModel> documents = [];
          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            documents.add(
                DocumentModel.fromJson(jsonEncode(jsonDecode(res.body)[i])));
          }
          print(documents);
          error = ErrorModel(error: null, data: documents);
          break;
        default:
          error = ErrorModel(
            error: res.body,
            data: null,
          );
      }
    } catch (e) {
      error = ErrorModel(
        error: e.toString(),
        data: null,
      );
    }

    return error;
  }

  Future<void> updateDocumentTitle({
    required String token,
    required String id,
    required String title,
  }) async {
    try {
      final headerMap = {
        "Content-Type": "Application/json; charset=UTF-8",
        'x-auth-token': token
      };
      var res = await _client.post(
        Uri.parse(host + '/doc/title'),
        headers: headerMap,
        body: json.encode({
          'id': id,
          'title': title,
        }),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<ErrorModel> getDocumentById(
      {required String token, required String documentId}) async {
    ErrorModel error =
        ErrorModel(error: 'Some Unexpected Error has Occured', data: null);

    try {
      final headerMap = {
        "Content-Type": "Application/json; charset=UTF-8",
        'x-auth-token': token
      };
      var res = await _client.get(
        Uri.parse(host + '/docs/$documentId'),
        headers: headerMap,
      );
      switch (res.statusCode) {
        case 200:
          error = ErrorModel(
            error: null,
            data: DocumentModel.fromJson(res.body),
          );
          break;
        default:
          throw 'This document does not exists, Please create a new One';
      }
    } catch (e) {
      error = ErrorModel(
        error: e.toString(),
        data: null,
      );
    }

    return error;
  }

  Future<ErrorModel> deleteDocumentbyID(
      {required String token, required String documentId}) async {
    ErrorModel error =
        ErrorModel(error: 'Some Unexpected Error has Occured', data: null);

    try {
      final headerMap = {
        "Content-Type": "Application/json; charset=UTF-8",
        'x-auth-token': token
      };
      var res = await _client.get(
        Uri.parse(host + '/docs/delete/$documentId'),
        headers: headerMap,
      );
      switch (res.statusCode) {
        case 200:
          error = ErrorModel(
            error: null,
            data: DocumentModel.fromJson(res.body),
          );
          break;
        default:
          throw 'This document does not exists, Please create a new One';
      }
    } catch (e) {
      error = ErrorModel(
        error: e.toString(),
        data: null,
      );
    }

    return error;
  }
}
