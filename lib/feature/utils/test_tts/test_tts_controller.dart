import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';
import 'package:google_speech/google_speech.dart';

class TestTtsController extends GetxController {
  final FlutterTts flutterTts = FlutterTts();

  var isPlaying = false.obs;
  var voices = <Map>[].obs;
  var selectedVoice = Rxn<Map>();

  @override
  void onInit() {
    super.onInit();
    _initTts();
  }

  void _initTts() async {
    flutterTts.setLanguage("id-ID");
    flutterTts.setPitch(1.0);
    flutterTts.setSpeechRate(0.5);

    // Ambil semua suara → filter hanya id-ID
    var v = await flutterTts.getVoices;
    var filtered = List<Map>.from(v).where((e) => e["locale"] == "id-ID").toList();

    voices.assignAll(filtered);
    if (voices.isNotEmpty) {
      selectedVoice.value = voices.first;
      await setVoice(voices.first);
    }

    // Listener event TTS
    flutterTts.setStartHandler(() {
      isPlaying.value = true;
    });

    flutterTts.setCompletionHandler(() {
      isPlaying.value = false;
    });

    flutterTts.setCancelHandler(() {
      isPlaying.value = false;
    });
  }

  Future<void> setVoice(Map voice) async {
    selectedVoice.value = voice;
    await flutterTts.setVoice({
      "name": voice["name"],
      "locale": voice["locale"],
    });
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    await flutterTts.speak(text);
  }

  Future<void> stop() async {
    await flutterTts.stop();
    isPlaying.value = false;
  }

  Future<void> speakWithGoogleTTS(String text) async {

    // final serviceAccount = ServiceAccount.fromString(
    //     '${(await rootBundle.loadString('assets/test_service_account.json'))}');
    //
    // final speechToText = EndlessStreamingService.viaServiceAccount(serviceAccount);
    //
    // final responseStream = speechToText.endlessStream;
    //
    // speechToText.endlessStreamingRecognize(
    //     StreamingRecognitionConfig(config: config, interimResults: true),
    //     _audioStream!);
    //
    // responseStream.listen((data) {...});
  }
}
