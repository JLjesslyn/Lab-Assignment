import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ImageGenerationService {
  // Replace with your real API key
  static const String apiKey = 'HF_API_KEY';

  // Example Hugging Face inference endpoint
  static const String apiUrl =
      'https://router.huggingface.co/hf-inference/models/stabilityai/stable-diffusion-xl-base-1.0';

  static Future<Uint8List> generateImage(String prompt) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'inputs': prompt,
        'parameters': {
          'width': 512,
          'height': 768,
          'num_inference_steps': 30,
          'guidance_scale': 7.5,
        },
        'options': {'wait_for_model': true},
      }),
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception(
        'Failed to generate image. Status code: ${response.statusCode}\nBody: ${response.body}',
      );
    }
  }
}