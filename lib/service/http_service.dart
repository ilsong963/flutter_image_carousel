import 'package:http/http.dart' as http;

class HttpService {
  final String baseUrl = "https://jsonplaceholder.typicode.com";

  getHttpClients() {
    return http.Client();
  }

}