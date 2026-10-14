import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'test_tts_controller.dart';

class TetsTtsPage extends StatelessWidget {
  TetsTtsPage({super.key});

  final controller = Get.find<TestTtsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("TTS Bahasa Indonesia")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Dropdown suara Indo
            Obx(() {
              if (controller.voices.isEmpty) {
                return Text("Loading suara Indonesia...");
              }
              return DropdownButton<Map>(
                isExpanded: true,
                value: controller.selectedVoice.value,
                items: controller.voices.map((v) {
                  return DropdownMenuItem<Map>(
                    value: v,
                    child: Text("${v['name']}"),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) controller.setVoice(val);
                },
              );
            }),
            SizedBox(height: 20),

            // Dummy teks Indo
            Text("Contoh teks Indonesia"),
            SizedBox(height: 10),

            Obx(() => ElevatedButton(
              onPressed: controller.isPlaying.value
                  ? controller.stop
                  : () => controller.speak("""Semut Kecil dan Belalang yang Malas
Di padang rumput yang luas, hiduplah seekor Semut Kecil yang sangat rajin bernama Kiki dan seekor Belalang yang suka bermalas-malasan bernama Lala.

Saat musim panas tiba, Kiki sibuk sekali. Ia setiap hari berjalan membawa butiran makanan kecil, mengumpulkannya di sarang untuk persediaan musim dingin. "Ayo, Kiki, istirahat sebentar! Kenapa kamu harus bekerja keras di hari secerah ini?" seru Lala, sambil rebahan santai dan memetik gitar daunnya.

"Aku harus mengumpulkan makanan sekarang, Lala," jawab Kiki dengan napas terengah-engah. "Musim dingin akan segera datang, dan saat itu tidak ada makanan di luar."

"Ah, musim dingin masih lama! Santai saja," balas Lala sambil tertawa dan kembali bernyanyi. Lala menghabiskan hari-harinya dengan bermain dan bersenang-senang, tidak peduli dengan pekerjaan Kiki.

Beberapa minggu kemudian, udara mulai terasa dingin. Daun-daun berguguran. Musim Dingin benar-benar datang.

Lala mulai kedinginan dan kelaparan. Ia tidak punya makanan sama sekali. Dengan tubuh menggigil, ia berjalan ke sarang Kiki.

"Kiki, temanku," kata Lala pelan. "Aku kedinginan dan lapar. Aku tidak punya makanan. Bisakah aku meminta sedikit persediaanmu?"

Kiki, yang sedang duduk hangat di antara tumpukan makanan, merasa iba. "Aku sudah bilang padamu, Lala, kita harus bersiap. Tapi baiklah, aku akan membaginya. Lain kali, kamu harus belajar untuk bekerja keras dan merencanakan masa depan."

Lala sangat berterima kasih. Sejak hari itu, Lala belajar dari Kiki. Saat musim panas berikutnya datang, Lala tidak hanya bernyanyi, tetapi juga ikut membantu Kiki mengumpulkan makanan. Mereka bekerja bersama-sama, dan mereka pun menjadi sahabat baik.

Pesan moral: Kerja keras dan persiapan itu penting. Selain itu, menolong teman yang kesusahan adalah perbuatan baik."""),
              child: Text(controller.isPlaying.value ? "Stop" : "Speak"),
            )),
          ],
        ),
      ),
    );
  }
}
