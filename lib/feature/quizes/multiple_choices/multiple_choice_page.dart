import 'package:epic_story_app/feature/quizes/multiple_choices/multiple_choice_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

class MultipleChoicePage extends StatefulWidget {
  const MultipleChoicePage({super.key});

  @override
  State<MultipleChoicePage> createState() => _MultipleChoicePageState();
}

class _MultipleChoicePageState extends State<MultipleChoicePage> {
  final MultipleChoiceController _controller =
      Get.find<MultipleChoiceController>();

  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown
      ],
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = Colors.grey.shade800;
    final Color panelColor = Colors.grey.shade200;
    final Color cardColor = Colors.grey.shade100;
    final Color shadowColor = Colors.black.withOpacity(0.12);

    final String question = _controller.quizChoice.question ?? '';
    final List<String> options = _controller.quizChoice.choices ?? <String>[];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Multiple Choice Quiz'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: panelColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor, width: 2),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 18,
                      offset: const Offset(10, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 2),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 12,
                            offset: const Offset(6, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        question,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (options.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No quiz data available.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ...options
                          .asMap()
                          .entries
                          .map((MapEntry<int, String> entry) {
                        final bool isSelected = entry.key == _selectedIndex;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _OptionTile(
                            label: entry.value,
                            isSelected: isSelected,
                            borderColor: borderColor,
                            shadowColor: shadowColor,
                            cardColor: cardColor,
                            leadingLabel: _indexToLetter(entry.key),
                            onTap: () =>
                                setState(() => _selectedIndex = entry.key),
                          ),
                        );
                      }),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cardColor,
                          foregroundColor: Colors.black,
                          elevation: 6,
                          shadowColor: shadowColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: borderColor, width: 2),
                          ),
                        ),
                        onPressed: _onCheckAnswers,
                        child: const Text('Check Answers'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onCheckAnswers() {
    if (_selectedIndex == null) {
      _showMessage('Please select an option first.');
      return;
    }

    final int? correctIndex = _controller.quizChoice.correctedIndex;
    final bool isCorrect =
        correctIndex != null && correctIndex == _selectedIndex;
    final String message = isCorrect
        ? 'Correct answer!'
        : 'Incorrect. Correct option is ${correctIndex != null ? _indexToLetter(correctIndex) : '-'}.';

    _showMessage(message);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _indexToLetter(int index) => String.fromCharCode(65 + index);
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.isSelected,
    required this.borderColor,
    required this.shadowColor,
    required this.cardColor,
    required this.leadingLabel,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color borderColor;
  final Color shadowColor;
  final Color cardColor;
  final String leadingLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.black : borderColor,
              width: 2,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: shadowColor,
                blurRadius: 12,
                offset: const Offset(6, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          child: Row(
            children: <Widget>[
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.black : Colors.white,
                  border: Border.all(color: borderColor, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  leadingLabel,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
