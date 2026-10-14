Explore quiz models and mappers

Searched for files matching `**/QuizChoice*`, no matches

Searched for files matching `**/QuizFillBlank*`, no matches

Searched for files matching `**/QuizGroup*`, no matches

Searched for files matching `**/quiz*remote*model*`, 6 matches

Searched for files matching `**/quiz*entity*`, 6 matches

Searched for files matching `**/quiz*mapper*`, 7 matches

Searched for files matching `**/gemini*response*`, 1 match

Searched for files matching `**/api_key*`, 1 match

Read [](file:///c%3A/dev/flutter-project/epic_story_app/lib/data/models/remotes/quiz/quiz_fill_blank_remote_model.dart)

Read [](file:///c%3A/dev/flutter-project/epic_story_app/lib/data/models/remotes/quiz/quiz_group_remote_model.dart)

Read [](file:///c%3A/dev/flutter-project/epic_story_app/lib/data/models/remotes/quiz/quiz_choice_remote_model.dart)

Read [](file:///c%3A/dev/flutter-project/epic_story_app/lib/data/models/mappers/quiz/quiz_fill_blank_mapper.dart)

Read [](file:///c%3A/dev/flutter-project/epic_story_app/lib/data/models/mappers/quiz/quiz_group_mapper.dart)

Read [](file:///c%3A/dev/flutter-project/epic_story_app/lib/data/models/mappers/quiz/quiz_choice_mapper.dart)

Read [](file:///c%3A/dev/flutter-project/epic_story_app/lib/domain/entities/quiz/quiz_choice_entity.dart)

Read [](file:///c%3A/dev/flutter-project/epic_story_app/lib/domain/entities/quiz/quiz_fill_blank_entity.dart)

Read [](file:///c%3A/dev/flutter-project/epic_story_app/lib/domain/entities/quiz/quiz_group_entity.dart)

Read [](file:///c%3A/dev/flutter-project/epic_story_app/lib/core/constants/api_key.dart)

Read [](file:///c%3A/dev/flutter-project/epic_story_app/lib/data/models/remotes/gemini_response.dart)

Read [](file:///c%3A/dev/flutter-project/epic_story_app/lib/data/datasources/remotes/quiz_remote_data_source.dart)

Read [](file:///c%3A/dev/flutter-project/epic_story_app/lib/data/models/mappers/quiz_fill_blank_mapper.dart)

Read [](file:///c%3A/dev/flutter-project/epic_story_app/lib/data/models/remotes/quiz/quiz_choice_remote_model.dart)

Read [](file:///c%3A/dev/flutter-project/epic_story_app/lib/data/models/remotes/quiz/quiz_fill_blank_remote_model.dart)

Read [](file:///c%3A/dev/flutter-project/epic_story_app/lib/data/models/remotes/quiz/quiz_group_remote_model.dart)

Read [](file:///c%3A/dev/flutter-project/epic_story_app/lib/data/models/remotes/gemini_response.dart#1-1), lines 1 to 120

Read [](file:///c%3A/dev/flutter-project/epic_story_app/lib/data/models/mappers/quiz/quiz_choice_mapper.dart)

Read [](file:///c%3A/dev/flutter-project/epic_story_app/lib/data/models/mappers/quiz/quiz_fill_blank_mapper.dart#1-1), lines 1 to 120

Read [](file:///c%3A/dev/flutter-project/epic_story_app/lib/data/models/mappers/quiz/quiz_group_mapper.dart)

## Analisis Fitur Generate Quiz

---

### 🔴 1. CRITICAL

#### 1.1 Tidak Ada Validasi Hasil Quiz Setelah Parsing

**Masalah:** Setelah Gemini mengembalikan JSON dan berhasil di-parse ke `RemoteModel`, tidak ada validasi apakah data quiz-nya **logis dan lengkap**. Semua field nullable, sehingga quiz kosong/rusak bisa lolos sampai ke UI.

**Dampak:**
- Quiz pilihan ganda tanpa `question`, tanpa `choices`, atau `correctedIndex` di luar range → crash atau UX rusak
- Fill blank dengan jumlah blank ≠ 4 atau option tanpa `correctBlankId` → quiz tidak bisa diselesaikan
- Group quiz dengan option mereferensi `correctGroupId` yang tidak ada di `groups` → jawaban selalu salah

**Rekomendasi:** Tambahkan validasi di controller setelah parsing, sebelum quiz dipakai:

```dart
// Tambahkan di masing-masing _tryToGenerate... method

// Contoh untuk multiple choice:
Future<QuizChoiceEntity?> _tryToGenerateMultipleChoiceQuiz({
  required String fullText,
}) async {
  try {
    final quizJson = await quizUsecase.generate(
      prompt: QuizPrompt.multipleChoicePrompt(text: fullText),
    );
    if (quizJson == null) return null;

    final parsed = jsonDecode(quizJson) as Map<String, dynamic>;
    if (parsed.containsKey('error')) return null; // ← dari _normalizeToJsonString

    var quizModel = QuizChoiceRemoteModel.fromJson(parsed);

    // === VALIDASI ===
    if (quizModel.question == null ||
        quizModel.choices == null ||
        quizModel.choices!.length != 4 ||
        quizModel.correctedIndex == null ||
        quizModel.correctedIndex! < 0 ||
        quizModel.correctedIndex! >= quizModel.choices!.length) {
      EpicLog.debug('_tryToGenerateMultipleChoiceQuiz - invalid quiz structure');
      return null;
    }

    var quizEntity = QuizChoiceMapper.remoteToEntity(quizModel);
    return quizEntity.copyWith(
      quizDataHelper: quizModel.toJson().toString(),
    );
  } catch (ex, s) {
    EpicLog.exception(ex, s, this, '_tryToGenerateMultipleChoiceQuiz');
  }
  return null;
}
```

```dart
// Validasi fill blank:
if (quizModel.sentence == null ||
    quizModel.options == null ||
    quizModel.options!.length != 4 ||
    quizModel.sentence!.where((s) => s.type == 'blank').length != 4 ||
    quizModel.options!.any((o) => o.value == null || o.correctBlankId == null)) {
  EpicLog.debug('_tryToGenerateFillBlankQuiz - invalid quiz structure');
  return null;
}
```

```dart
// Validasi group quiz:
final groupIds = quizModel.groups?.map((g) => g.id).toSet() ?? {};
if (quizModel.groups == null ||
    quizModel.groups!.length != 2 ||
    quizModel.options == null ||
    quizModel.options!.length != 8 ||
    quizModel.options!.any((o) => !groupIds.contains(o.correctGroupId))) {
  EpicLog.debug('_tryToGenerateGroupQuiz - invalid quiz structure');
  return null;
}
```

---

#### 1.2 `_normalizeToJsonString` Mengembalikan Error JSON yang Di-parse Seolah Valid

**Masalah:** Ketika normalisasi gagal, fungsi mengembalikan:
```dart
return json.encode({"error": "invalid_json", "raw": input.trim()});
```
Caller (`_tryToGenerateMultipleChoiceQuiz` dll) tidak mengecek apakah JSON ini mengandung `"error"`. `fromJson` tetap jalan — hasilnya model dengan semua field `null`.

**Dampak:** Quiz rusak masuk ke sistem tanpa terdeteksi.

**Rekomendasi:** Return `null` dari `generate()` jika normalisasi gagal:

```dart
// Di generate(), ganti:
return _normalizeToJsonString(geminiPayload);

// Menjadi:
final normalized = _normalizeToJsonString(geminiPayload);
if (normalized == null) {
  EpicLog.debug("QuizRemoteDataSource - generate - failed to normalize JSON");
  return null;
}
return normalized;
```

Dan ubah `_normalizeToJsonString` return `String?`:
```dart
String? _normalizeToJsonString(String input) {
  // ... existing logic ...
  
  // Pada baris terakhir, ganti return error JSON menjadi:
  EpicLog.debug("_normalizeToJsonString - failed to parse: ${input.substring(0, input.length.clamp(0, 200))}");
  return null;
}
```

---

### 🟡 2. IMPORTANT

#### 2.1 Handling Error 429 (Too Many Requests) Tidak Ada

**Masalah:** Kode hanya handle `503 (serviceUnavailable)` untuk model switching. Status `429 (tooManyRequests)` — yang jauh lebih umum pada Gemini pay-as-you-go — **langsung return null** tanpa retry atau fallback.

**Dampak:** Saat rate limited, quiz gagal generate padahal model lain mungkin masih available.

**Rekomendasi:**

```dart
final bool isHighDemand =
    response.statusCode == HttpStatus.serviceUnavailable;
final bool isRateLimited =
    response.statusCode == HttpStatus.tooManyRequests; // 429
final bool canSwitchModel = attempt < maxModelSwitches &&
    attempt + 1 < modelFallbackOrder.length;

if ((isHighDemand || isRateLimited) && canSwitchModel) {
  EpicLog.debug(
      "QuizRemoteDataSource - generate - model $modelName unavailable (${response.statusCode}), switching model");
  continue;
}
```

---

#### 2.2 Model Fallback List Berisi Model yang Mungkin Tidak Ada

**Masalah:** `gemini-flash-lite-latest` dan `gemini-3.1-flash-lite-preview` bukan nama model resmi Gemini. Kalau model tidak exist, API return `404` → langsung `return null`, padahal model berikutnya mungkin valid.

**Dampak:** Fallback chain berhenti di model invalid, model berikutnya tidak dicoba.

**Rekomendasi:** Tambahkan handling `404` untuk skip ke model berikutnya, dan gunakan model name yang valid:

```dart
const List<String> modelFallbackOrder = [
  'gemini-2.5-flash',
  'gemini-2.5-flash-lite',
  'gemini-2.0-flash-lite',   // model yang valid
  'gemini-1.5-flash',        // stable fallback
];

// Di loop, tambahkan:
final bool isModelNotFound = response.statusCode == HttpStatus.notFound;

if ((isHighDemand || isRateLimited || isModelNotFound) && canSwitchModel) {
  EpicLog.debug(
      "QuizRemoteDataSource - generate - model $modelName error (${response.statusCode}), switching");
  continue;
}
```

---

#### 2.3 Prompt Terlalu Boros — Khususnya Fill Blank dan Group

**Masalah:** Prompt fill blank = ~700 kata, group = ~600 kata. Banyak aturan yang **redundan** atau bisa disederhanakan. Pada pay-as-you-go, input tokens menambah biaya.

**Dampak:** Biaya API lebih tinggi per request. Semakin panjang prompt, semakin banyak input token yang dihitung.

**Rekomendasi — contoh fill blank yang lebih ringkas (~40% lebih pendek):**

```dart
static String fillBlankPrompt({required String text}) {
  return """
Materi:
"$text"

Buat 1 soal isian rumpang. Kalimat harus mandiri tanpa merujuk materi. Gunakan gaya buku pelajaran anak.

Aturan:
- Tepat 4 blank (b1-b4), jawaban 1-2 kata, unik, kata penting saja.
- Tepat 4 options (o1-o4), tiap option punya correctBlankId yang cocok.
- Sertakan explanation. Output JSON saja, tanpa teks lain.

Format:
{
  "quizType": 2,
  "sentence": [
    {"type": "text", "value": "..."},
    {"type": "blank", "id": "b1"},
    ...
  ],
  "options": [
    {"id": "o1", "value": "...", "correctBlankId": "b1"},
    ...
  ],
  "explanation": "..."
}
""";
}
```

---

#### 2.4 `responseMimeType` Tidak Diset → Gemini Bisa Wrap Output dengan Markdown

**Masalah:** Tanpa `responseMimeType: "application/json"` di `generationConfig`, Gemini sering membungkus JSON dengan ` ```json ... ``` `. Makanya `_normalizeToJsonString` perlu strip code fence.

**Dampak:** Extra processing yang tidak perlu + risiko gagal parse jika format fence berubah.

**Rekomendasi:** Tambahkan `responseMimeType` agar Gemini langsung return raw JSON:

```dart
"generationConfig": {
  "temperature": 1,
  "topK": 0,
  "topP": 0.95,
  "maxOutputTokens": 8192,
  "responseMimeType": "application/json", // ← tambah ini
  "stopSequences": []
},
```

> Note: Ini didukung di model `gemini-1.5-flash` ke atas. Dengan ini, `_normalizeToJsonString` masih jadi safety net tapi seharusnya jarang dibutuhkan.

---

#### 2.5 Dio Instance Dibuat Ulang Setiap `generate()` Call

**Masalah:** `final Dio dio = Dio(...)` ada di dalam method. Setiap generate quiz dipanggil (bisa 3-5x per flashcard set), Dio instance baru dibuat.

**Dampak:** Minor memory overhead, tapi lebih penting: tidak bisa share connection pool atau interceptor.

**Rekomendasi:** Jadikan field di class:

```dart
class QuizRemoteDataSource {
  final FirebaseService fireService = Get.find<FirebaseService>();
  
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 18),
    ),
  );

  // ... gunakan _dio di generate()
```

---

### 🟢 3. OPTIONAL IMPROVEMENT

#### 3.1 `generationConfig.temperature: 1` Terlalu Tinggi untuk Structured Output

**Masalah:** Temperature 1 mendorong kreativitas tinggi. Untuk structured JSON output, ini meningkatkan kemungkinan format yang menyimpang dari template.

**Dampak:** Kadang Gemini bisa menghasilkan JSON yang creative tapi malah salah struktur.

**Rekomendasi:** Turunkan ke `0.7` atau `0.8`:
```dart
"temperature": 0.7,
```

---

#### 3.2 `finishReason` Tidak Dicek

**Masalah:** Gemini bisa return status 200 tapi dengan `finishReason: "SAFETY"` atau `"MAX_TOKENS"` — artinya output terpotong atau diblokir. Saat ini kode langsung ambil `text` tanpa cek.

**Dampak:** JSON terpotong → parse gagal atau data tidak lengkap.

**Rekomendasi:**
```dart
if (response.statusCode == HttpStatus.ok) {
  GeminiResponse geminiResponse = GeminiResponse.fromJson(payload);
  
  final finishReason = geminiResponse.candidates?[0].finishReason;
  if (finishReason != null && finishReason != 'STOP') {
    EpicLog.debug(
        "QuizRemoteDataSource - generate - unexpected finishReason: $finishReason");
    // bisa return null atau tetap coba parse
  }
  
  var geminiPayload = geminiResponse.candidates?[0].content?.parts?[0].text ?? '{}';
  // ...
}
```

---

#### 3.3 Prompt Tidak Menentukan Bahasa Response

**Masalah:** Prompt ditulis dalam Bahasa Indonesia tapi tidak eksplisit minta response dalam bahasa tertentu. Gemini kadang campur bahasa.

**Rekomendasi:** Tambahkan di akhir setiap prompt:
```
- Gunakan Bahasa Indonesia untuk semua konten soal.
```

---

#### 3.4 Duplikat Mapper File

**Masalah:** Ada file quiz_fill_blank_mapper.dart di `mappers/` DAN `mappers/quiz/` — kemungkinan leftover.

**Rekomendasi:** Hapus duplikat jika tidak ada yang mengimport-nya.

---

### Ringkasan Prioritas

| # | Kategori | Item | Effort |
|---|---|---|---|
| 1.1 | 🔴 Critical | Validasi struktur quiz setelah parse | Medium |
| 1.2 | 🔴 Critical | `_normalizeToJsonString` return `null` bukan error JSON | Kecil |
| 2.1 | 🟡 Important | Handle 429 (rate limit) | Kecil |
| 2.2 | 🟡 Important | Validasi/fix model name + handle 404 | Kecil |
| 2.3 | 🟡 Important | Prompt lebih ringkas | Medium |
| 2.4 | 🟡 Important | Set `responseMimeType: "application/json"` | Kecil |
| 2.5 | 🟡 Important | Dio instance jadi class field | Kecil |
| 3.1 | 🟢 Optional | Turunkan temperature | Kecil |
| 3.2 | 🟢 Optional | Cek `finishReason` | Kecil |
| 3.3 | 🟢 Optional | Eksplisit bahasa di prompt | Kecil |
| 3.4 | 🟢 Optional | Hapus duplikat mapper | Kecil |