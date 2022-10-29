import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/custom_colors.dart';
import 'package:google_docs_clone/models/document_model.dart';
import 'package:google_docs_clone/models/error_model.dart';
import 'package:google_docs_clone/services/auth_service.dart';
import 'package:google_docs_clone/services/document_service.dart';
import 'package:google_docs_clone/services/socket_service.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String? id;

  const DocumentScreen({Key? key, required this.id}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  final TextEditingController _title =
      TextEditingController(text: 'Untitled Document');

  quill.QuillController? _quillcontroller;

  void updateTItle(WidgetRef ref, String title) {
    ref.read(documentSerivceProvider).updateDocumentTitle(
          token: ref.read(userProvider)!.token,
          id: widget.id!,
          title: title,
        );
  }

  ErrorModel? errorModel;

  void fetchDocData() async {
    errorModel = await ref.read(documentSerivceProvider).getDocumentById(
          token: ref.read(userProvider)!.token,
          documentId: widget.id!,
        );

    if (errorModel!.data != null) {
      _title.text = (errorModel!.data as DocumentModel).title;
      _quillcontroller = quill.QuillController(
        document: errorModel!.data.content.isEmpty
            ? quill.Document()
            : quill.Document.fromDelta(
                quill.Delta.fromJson(errorModel!.data.conent),
              ),
        selection: const TextSelection.collapsed(
          offset: 0,
        ),
      );
      setState(() {});
    }
  }

  SocketService socketService = SocketService();

  @override
  void initState() {
    socketService.joinRoom(widget.id!);
    socketService.changeListener((data) {
      _quillcontroller?.compose(delta, textSelection, source)
    });
    fetchDocData();
    super.initState();
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  if(  _quillcontroller==null)  {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(),),
    );
    }

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
                  onSubmitted: (value) => updateTItle(ref, value),
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
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            quill.QuillToolbar.basic(
              controller: _quillcontroller!,
              showDirection: true,
            ),
            Expanded(
              child: SizedBox(
                width: 750,
                child: Card(
                  color: Colors.white,
                  elevation: 15,
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: quill.QuillEditor.basic(
                      controller: _quillcontroller!,
                      readOnly: false,
                      keyboardAppearance: Brightness.dark,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
