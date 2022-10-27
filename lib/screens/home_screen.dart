import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/services/auth_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text(ref.watch(userProvider)!.email),
            Text(ref.watch(userProvider)!.name),
            SelectableText((ref.watch(userProvider)!.uid)),
          ],
        ),
      ),
    );
  }
}
