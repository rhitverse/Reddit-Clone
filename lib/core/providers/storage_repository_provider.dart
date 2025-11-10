import 'dart:convert';
import 'dart:io';
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
  }) async {
    try {
      if (file == null) return left(Failure("File is null"));

      final url = "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

      var request = http.MultipartRequest('POST', Uri.parse(url))
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] =
            path // Cloudinary folder
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

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
