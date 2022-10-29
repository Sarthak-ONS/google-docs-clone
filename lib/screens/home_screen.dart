import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/custom_colors.dart';
import 'package:google_docs_clone/models/document_model.dart';
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

  void navigateToDucment(BuildContext context, String documentId) {
    Routemaster.of(context).push('/document/$documentId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Google DOCS Clone',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        elevation: 0,
        backgroundColor: AppColors.primayBlueColor,
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
      body: FutureBuilder(
        future: ref
            .watch(documentSerivceProvider)
            .getDocuments(token: ref.watch(userProvider)!.token),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data == null) {
            return const Center(
              child: Text('Please add a Document'),
            );
          }

          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(10.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                mainAxisSpacing: 8,
                childAspectRatio: 16 / 9,
                crossAxisSpacing: 8,
              ),
              itemCount: snapshot.data!.data!.length,
              itemBuilder: (context, index) {
                DocumentModel document = snapshot.data!.data[index];

                Color customColor =
                    AppColors.colorsList[index % AppColors.colorsList.length];
                return InkWell(
                  splashColor: Colors.white,
                  onTap: () => navigateToDucment(context, document.id),
                  child: Container(
                    decoration: BoxDecoration(
                      color: customColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(
                        color: customColor.withOpacity(1),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        document.title,
                        style: const TextStyle(
                          color: AppColors.primaryFontColor,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
