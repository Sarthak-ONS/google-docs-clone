import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/constants.dart';
import 'package:google_docs_clone/custom_colors.dart';
import 'package:google_docs_clone/models/document_model.dart';
import 'package:google_docs_clone/services/auth_service.dart';
import 'package:google_docs_clone/services/document_service.dart';
import 'package:google_docs_clone/services/socket_service.dart';
import 'package:routemaster/routemaster.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/error_model.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  TextEditingController titleController =
      TextEditingController(text: 'Untitled Document');
  quill.QuillController? _controller;
  ErrorModel? errorModel;
  SocketService socketService = SocketService();

  @override
  void initState() {
    super.initState();
    socketService.joinRoom(widget.id);
    fetchDocumentData();

    socketService.changeListener((data) {
      _controller?.compose(
        quill.Delta.fromJson(data['delta']),
        _controller?.selection ?? const TextSelection.collapsed(offset: 0),
        quill.ChangeSource.REMOTE,
      );
    });

    Timer.periodic(const Duration(seconds: 2), (timer) {
      socketService.autoSave(<String, dynamic>{
        'delta': _controller!.document.toDelta(),
        'room': widget.id,
      });
    });
  }

  void fetchDocumentData() async {
    errorModel = await ref.read(documentSerivceProvider).getDocumentById(
          token: ref.read(userProvider)!.token,
          documentId: widget.id,
        );

    if (errorModel!.data != null) {
      titleController.text = (errorModel!.data as DocumentModel).title;
      _controller = quill.QuillController(
        document: errorModel!.data.content.isEmpty
            ? quill.Document()
            : quill.Document.fromDelta(
                quill.Delta.fromJson(errorModel!.data.content),
              ),
        selection: const TextSelection.collapsed(offset: 0),
      );
      setState(() {});
    }

    _controller!.document.changes.listen((event) {
      if (event.item3 == quill.ChangeSource.LOCAL) {
        Map<String, dynamic> map = {
          'delta': event.item2,
          'room': widget.id,
        };
        socketService.typing(map);
      }
    });
  }

  bool isHoverOnDownloadButton = false;

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
  }

  void deleteDocument() async {
    ref.read(documentSerivceProvider).deleteDocumentbyID(
          token: ref.read(userProvider)!.token,
          documentId: widget.id,
        );
    socketService.closeRoom();
    Routemaster.of(context).push('/');
  }

  void updateTitle(WidgetRef ref, String title) {
    ref.read(documentSerivceProvider).updateDocumentTitle(
          token: ref.read(userProvider)!.token,
          id: widget.id,
          title: title,
        );
  }

  Future<void> _createPDF() async {
    print(_controller!.plainTextEditingValue.text);
    PdfDocument document = PdfDocument();
    //Add a page and draw text
    document.pages.add().graphics.drawString(
        _controller!.plainTextEditingValue.text,
        PdfStandardFont(PdfFontFamily.helvetica, 20),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
        bounds: Rect.fromLTWH(20, 60, 150, 30));
    //Save the document
    List<int> bytes = await document.save();
    //Dispose the document
    document.dispose();
    AnchorElement(
        href:
            "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}")
      ..setAttribute("download", "${titleController.text}.pdf")
      ..click();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Scaffold(
          body: Center(
        child: CircularProgressIndicator(),
      ));
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  actionsPadding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  title: const Text(
                    'Alert',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Are you really sure you want to delete this document?',
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 16,
                        ),
                      )
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                            fontSize: 16, color: AppColors.primayBlueColor),
                      ),
                    ),
                    TextButton(
                      onPressed: () => deleteDocument(),
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontSize: 16, color: Colors.redAccent),
                      ),
                    )
                  ],
                ),
              );
            },
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.red,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              onPressed: () => _createPDF(),
              onHover: (value) {
                setState(() {
                  isHoverOnDownloadButton = !isHoverOnDownloadButton;
                });
              },
              icon: Icon(
                Icons.download,
                size: 16,
                color: isHoverOnDownloadButton
                    ? Colors.white
                    : AppColors.primayBlueColor,
              ),
              label: Text(
                'Download',
                style: TextStyle(
                  color: isHoverOnDownloadButton
                      ? Colors.white
                      : AppColors.primayBlueColor,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: isHoverOnDownloadButton
                    ? AppColors.primayBlueColor
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    color: AppColors.primayBlueColor,
                  ),
                  borderRadius: BorderRadius.circular(7.0),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(
                        ClipboardData(text: '$host/#/document/${widget.id}'))
                    .then(
                  (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Link copied!',
                        ),
                      ),
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.lock,
                size: 16,
              ),
              label: const Text('Share'),
              style: ElevatedButton.styleFrom(
                primary: AppColors.primayBlueColor,
              ),
            ),
          ),

          // Download as PDF Button
        ],
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Routemaster.of(context).replace('/');
                },
                child: Image.asset(
                  'assets/images/docs-logo.png',
                  height: 40,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 180,
                child: TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.primayBlueColor,
                      ),
                    ),
                    contentPadding: EdgeInsets.only(left: 10),
                  ),
                  onSubmitted: (value) => updateTitle(ref, value),
                ),
              ),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
                width: 0.1,
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            quill.QuillToolbar.basic(controller: _controller!),
            const SizedBox(height: 10),
            Expanded(
              child: SizedBox(
                width: 750,
                child: Card(
                  color: Colors.white,
                  elevation: 100,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: quill.QuillEditor.basic(
                      controller: _controller!,
                      readOnly: false,
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
