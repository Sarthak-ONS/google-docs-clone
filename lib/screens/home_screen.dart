import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/custom_colors.dart';
import 'package:google_docs_clone/models/document_model.dart';
import 'package:google_docs_clone/services/auth_service.dart';
import 'package:google_docs_clone/services/document_service.dart';
import 'package:routemaster/routemaster.dart';
import 'package:intl/intl.dart';

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

  // Text(
  //         'Hi,  ${ref.watch(userProvider)!.name.toString()}, Welcome to DOCS',
  //         style: const TextStyle(
  //           fontWeight: FontWeight.w400,
  //           letterSpacing: 1,
  //         ),
  //       )

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xffCAD5E2),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton.extended(
          label: const Text('Create'),
          icon: const Icon(Icons.add),
          onPressed: () => createDocument(context, ref),
          backgroundColor: AppColors.primayBlueColor,
        ),
      ),
      appBar: AppBar(
        leading: Center(
          child: SizedBox(
            height: 40,
            child: Image.asset(
              'assets/images/docs-logo.png',
              scale: 0.5,
            ),
          ),
        ),
        centerTitle: true,
        title: RichText(
          text: TextSpan(
            text: 'Hi, ',
            style: const TextStyle(
                fontWeight: FontWeight.w400, color: Colors.white, fontSize: 16),
            children: [
              TextSpan(
                text: '${ref.watch(userProvider)!.name.toString()}, ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(
                text: 'Welcome to DOCS',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        elevation: 0,
        backgroundColor: AppColors.primayBlueColor,
        actions: [
          GestureDetector(
            onTap: () => createDocument(context, ref),
            child: Row(
              children: const [
                Icon(Icons.add),
                SizedBox(
                  width: 5,
                ),
                Text(
                  'Create',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 25,
          ),
          GestureDetector(
            onTap: () {
              showMenu(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                context: context,
                position: RelativeRect.fromLTRB(
                    double.infinity,
                    MediaQuery.of(context).viewInsets.top + 50,
                    0,
                    double.infinity),
                items: [
                  PopupMenuItem(
                    child: CircleAvatar(
                      child: ClipOval(
                        child: Image.network(
                          ref.watch(userProvider)!.profilePic,
                          height: 40,
                        ),
                      ),
                      //radius: 30,
                    ),
                  ),
                  PopupMenuItem(
                    child: Text(ref.watch(userProvider)!.name),
                  ),
                  PopupMenuItem(
                    child: Text(ref.watch(userProvider)!.email),
                  ),
                  PopupMenuItem(
                    child: TextButton(
                      onPressed: () => signout(ref),
                      child: const Center(child: Text('Sign Out')),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            side: const BorderSide(
                              color: AppColors.primayBlueColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            child: CircleAvatar(
              child: ClipOval(
                child: Image.network(
                  ref.watch(userProvider)!.profilePic,
                  height: 40,
                ),
              ),
              //radius: 30,
            ),
          ),
          const SizedBox(
            width: 25,
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            document.title,
                            style: const TextStyle(
                              color: AppColors.primaryFontColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            DateFormat().format(document.createdAt),
                            style: const TextStyle(
                              color: Colors.black54,
                              fontStyle: FontStyle.italic,
                              fontSize: 12
                            ),
                          )
                        ],
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
