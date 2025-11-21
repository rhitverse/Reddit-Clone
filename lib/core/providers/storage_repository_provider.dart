import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/providers/failure.dart';
import 'package:reddit_clone/core/providers/type_defs.dart';

// Cloudinary Config
const String cloudName = "dova6pnyl"; // apna cloud name
const String uploadPreset = "flutter_unsigned"; // jo preset banaya

final storageRepositoryProvider = Provider((ref) => StorageRepository());

class StorageRepository {
  FutureEither<String> storeFile({
    required String path, // Cloudinary folder
    required String id, // ignore (Cloudinary auto ID de deta hai)
    required File? file,
    required Uint8List? webFile,
  }) async {
    try {
      final url = "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

      var request = http.MultipartRequest('POST', Uri.parse(url))
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = path;

      if (webFile != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            webFile,
            filename: '${DateTime.now().millisecondsSinceEpoch}.png',
          ),
        );
      } else if (file != null) {
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
      } else {
        return left(Failure("No file provided"));
      }

      var response = await request.send();
      var res = await http.Response.fromStream(response);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return right(data['secure_url']);
      } else {
        return left(Failure("Upload failed: ${res.body}"));
      }
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
