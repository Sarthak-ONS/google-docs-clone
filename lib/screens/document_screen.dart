import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/custom_colors.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String? id;

  const DocumentScreen({Key? key, required this.id}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  final TextEditingController _title =
      TextEditingController(text: 'Untitled Document');

  final quill.QuillController _controller = quill.QuillController.basic();

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                primary: AppColors.primayBlueColor,
              ),
              onPressed: () {},
              icon: const Icon(
                Icons.lock,
                size: 16,
              ),
              label: const Text('Share'),
            ),
          )
        ],
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
          child: Row(
            children: [
              Image.asset(
                'assets/images/docs-logo.png',
                height: 40,
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                width: 250,
                child: TextField(
                  controller: _title,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                      left: 10,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.primayBlueColor,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            decoration:
                BoxDecoration(border: Border.all(color: Colors.grey[400]!)),
          ),
        ),
      ),
      body: Column(
        children: [
          quill.QuillEditor.basic(
            controller: _controller,
            readOnly: false,
            keyboardAppearance: Brightness.light,
          )
        ],
      ),
    );
  }
}
