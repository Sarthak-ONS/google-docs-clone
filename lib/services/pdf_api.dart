import 'dart:io';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';

class PdfApi {
  static Future generatePdf(String text, {required String docTitle}) async {
    final pdf = Document();
    pdf.addPage(
      Page(
        build: ((context) => Text(text)),
      ),
    );

    return saveDocument(name: '$docTitle.pdf', pdf: pdf);
  }

  static Future<File> saveDocument(
      {required String name, required Document pdf}) async {
    final bytes = await pdf.save();

    // final dir = await getApplicationDocumentsDirectory();

    final file = File(name);

    await file.writeAsBytes(bytes);

    await OpenFile.open(file.path);

    return file;
  }
}
