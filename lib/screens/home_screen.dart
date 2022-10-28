import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/models/document_model.dart';
import 'package:google_docs_clone/models/error_model.dart';
import 'package:google_docs_clone/services/auth_service.dart';
import 'package:google_docs_clone/services/document_service.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void signout(WidgetRef ref) {
    ref.read(authServiceProvider).signout();
    ref.read(userProvider.notifier).update((state) => null);
  }

  void createDocument(BuildContext context, WidgetRef ref) async {
    String token = ref.read(userProvider)!.token;

    final navigator = Routemaster.of(context);

    final snackbar = ScaffoldMessenger.of(context);

    final errorModel =
        await ref.read(documentSerivceProvider).createDocument(token: token);
    if (errorModel.data != null) {
      navigator.push('/document/${errorModel.data.id}');
    } else {
      snackbar.showSnackBar(SnackBar(content: Text(errorModel.error!)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google DOCS Clone'),
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            onPressed: () => createDocument(context, ref),
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () => signout(ref),
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: FutureBuilder<ErrorModel>(
        future: ref
            .watch(documentSerivceProvider)
            .getDocuments(token: ref.watch(userProvider)!.token),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Center(
            child: Container(
              width: 600,
              margin: const EdgeInsets.only(top: 10),
              child: ListView.builder(
                itemCount: snapshot.data!.data.length,
                itemBuilder: (context, index) {
                  DocumentModel document = snapshot.data!.data[index];

                  return Card(
                    child: Text(document.title),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
