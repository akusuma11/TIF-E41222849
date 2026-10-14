import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:epic_story_app/core/constants/api_key.dart';
import 'package:epic_story_app/data/models/remotes/gemini_response.dart';

Future<String> generate({required String prompt}) async {
  try {
    final Dio _dio = Dio();
    // generate response from gemini api
    final response = await _dio.post(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent",
      queryParameters: {
        "key": ApiKey.gemini,
      },
      data: json.encode(
        {
          "contents": [
            {
              "role": "user",
              "parts": [
                {"text": prompt}
              ]
            },
          ],
          "generationConfig": {
            "temperature": 1,
            "topK": 0,
            "topP": 0.95,
            "maxOutputTokens": 8192,
            "stopSequences": []
          },
          "safetySettings": [
            {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_NONE"},
            {
              "category": "HARM_CATEGORY_HATE_SPEECH",
              "threshold": "BLOCK_NONE"
            },
            {
              "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
              "threshold": "BLOCK_NONE"
            },
            {
              "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
              "threshold": "BLOCK_NONE"
            }
          ]
        },
      ),
      options: Options(
        headers: {'Content-Type': 'application/json'},
        validateStatus: (status) {
          return status == HttpStatus.ok ||
              status == HttpStatus.badRequest ||
              status == HttpStatus.internalServerError ||
              status == HttpStatus.notFound;
        },
      ),
    );

    // get payload from response
    final dynamic payload = response.data;

    // check response is successfully or not
    if (response.statusCode == HttpStatus.ok) {
      // get prompt result
      GeminiResponse geminiResponse = GeminiResponse.fromJson(payload);
      var geminiPayload =
          geminiResponse.candidates?[0].content?.parts?[0].text ?? '{}';

      return geminiPayload;
    } else {
      return "error";
    }
  } on DioException catch (ex) {
    return "exception : ${ex.toString()}";
  }
}

void main() async {
  var prompt = """
Teks:
"Aku ada sepeda mainan. Ayah bisa mengendarai sepeda besar. Aku berharap bisa mengendarai sepeda dan ikut ayah bekerja. Ini motor. Pakai motor bisa melaju lebih cepat dari sepeda. Ada mobil di jalan juga. Motor dapat mengejar mobil. Aku tidak sabar sampai aku cukup umur untuk mengendarai mobil. Aku akan bisa pergi ke tempat yang aku inginkan. Apa itu di sebelah? Ada bis besar."

Instruksi:
Buat hanya 1 soal.
Soal harus berdasarkan isi teks.
Sediakan 4 pilihan jawaban (A, B, C, D).
Hanya 1 jawaban yang benar.
Gunakan format JSON berikut dan pastikan JSON valid.
Jangan tambahkan penjelasan apa pun di luar JSON.

Format output:
{
"question": "Pertanyaan berdasarkan teks",
"choices": [
"Pilihan A",
"Pilihan B",
"Pilihan C",
"Pilihan D"
],
"correctedIndex": 0
}
""";
  var response = await generate(prompt: prompt);
  print("$response");
}
