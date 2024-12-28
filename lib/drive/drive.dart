import 'dart:convert';
import 'package:http/http.dart' as http;

class Drive{

  Future<void> listGoogleDriveFiles(String accessToken) async {
    final url = 'https://www.googleapis.com/drive/v3/files';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Drive Files: $data');
    } else {
      print('Error: ${response.statusCode}');
    }
  }
}