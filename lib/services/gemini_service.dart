import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String?> getTripPlan(String prompt) async {
  final url = Uri.parse('https://travel-api-1088581851074.us-central1.run.app'); 

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'prompt': prompt}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['response'];
  } else {
    print('API Error: ${response.statusCode}');
    return null;
  }
}
