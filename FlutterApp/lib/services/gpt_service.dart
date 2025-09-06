import 'package:dio/dio.dart';

class OpenAIService {
  final String apiKey;
  final Dio dio;

  OpenAIService({required this.apiKey})
      : dio = Dio(
          BaseOptions(
            baseUrl: 'https://api.openai.com/v1',
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
          ),
        );

  Future<String> getChatCompletionWithImage(String imageUrl) async {
    try {
      print('API Key: $apiKey');
      final response = await dio.post(
        '/chat/completions',
        data: {
          "model": "gpt-4o",
          "messages": [
            {
              "role": "system",
              "content":
                  "You are a food patry/refridgerator scanning assistant, and you only reply with JSON of the food items you see."
            },
            {
              "role": "user",
              "content": [
                {
                  "type": "text",
                  "text":
                      "What food items are in this image? Respond what you see only as a JSON array where each object has the following properties: name, amount, unit. do not respond with anything else, only the array of {name:}"
                },
                {
                  "type": "image_url",
                  "image_url": {"url": imageUrl, "detail": "high"},
                },
              ],
            }
          ],
          "response_format": {"type": "json_object"},
          "max_tokens": 300,
        },
      );
      if (response.statusCode == 200) {
        final data = response.data;
        return data['choices'][0]['message']['content'];
      } else {
        print('Failed response: ${response.data}');
        throw Exception('Failed to get response from OpenAI');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // The server responded with a non-2xx status code
        print(
            'Dio error! Status: ${e.response?.statusCode}, Data: ${e.response?.data}');
      } else {
        // An error occurred before the server responded
        print('Dio error! Message: ${e.message}');
      }
      throw Exception('Failed to get response from OpenAI: ${e.message}');
    }
  }
}
