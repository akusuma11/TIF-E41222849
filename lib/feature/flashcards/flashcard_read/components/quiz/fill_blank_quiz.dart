import 'package:epic_story_app/domain/entities/quiz/quiz_fill_blank_entity.dart';
import 'package:epic_story_app/feature/flashcards/flashcard_read/flashcard_quiz_controller.dart';
import 'package:epic_story_app/feature/flashcards/flashcard_read/components/quiz/components/ray_burst.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FillBlankQuiz extends StatelessWidget {
  const FillBlankQuiz({
    super.key,
    required this.quizController,
    required this.quizData,
  });

  final FlashcardQuizController quizController;
  final QuizFillBlankEntity quizData;

  @override
  Widget build(BuildContext context) {
    final sentences = quizData.sentence ?? [];
    final options = quizData.options ?? [];

    // limit to 8 options to mirror mock scale
    final limitedOptions = options.take(8).toList();
    quizController.cleanupAssignments(
      limitedOptions.where((o) => o.id != null).map((o) => o.id!).toSet(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SentenceArea(
          sentences: sentences,
          quizController: quizController,
        ),
        const SizedBox(height: 40),
        Obx(() {
          final isLocked = quizController.isAnswerCorrect.value ||
              quizController.flashcardReadController.retryQuestion.value == 0;
          return _OptionsTray(
            options: limitedOptions,
            quizController: quizController,
            isLocked: isLocked,
          );
        }),
        const SizedBox(height: 14),
      ],
    );
  }
}

class _SentenceArea extends StatelessWidget {
  const _SentenceArea({
    required this.sentences,
    required this.quizController,
  });

  final List<QuizFillBlankSentenceEntity> sentences;
  final FlashcardQuizController quizController;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      runSpacing: 8,
      spacing: 8,
      children: sentences.map((part) {
        if (part.type == 'blank') {
          final blankId = part.id ?? '';
          return _BlankTarget(
            blankId: blankId,
            quizController: quizController,
          );
        }
        return Text(
          part.value ?? '',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            height: 1.35,
            color: Colors.black,
          ),
        );
      }).toList(),
    );
  }
}

class _BlankTarget extends StatefulWidget {
  const _BlankTarget({
    required this.blankId,
    required this.quizController,
  });

  final String blankId;
  final FlashcardQuizController quizController;

  @override
  State<_BlankTarget> createState() => _BlankTargetState();
}

class _BlankTargetState extends State<_BlankTarget>
    with SingleTickerProviderStateMixin {
  late final RayBurstController _rayController;

  @override
  void initState() {
    super.initState();
    _rayController = RayBurstController();
  }

  @override
  void dispose() {
    _rayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      widget.quizController.assignedBlankByOption.length;
      widget.quizController.isAnswerChecked.value;

      QuizFillBlankOptionEntity? assignedOption;
      widget.quizController.assignedBlankByOption.forEach((optId, bId) {
        if (bId == widget.blankId) {
          assignedOption = widget.quizController.flashcardReadController
              .currentCard.value?.quiz?.fillBlank?.options
              ?.firstWhereOrNull((opt) => opt.id == optId);
        }
      });

      final isChecked = widget.quizController.isAnswerChecked.value;
      final isCorrect = assignedOption != null &&
          assignedOption!.correctBlankId != null &&
          assignedOption!.correctBlankId == widget.blankId;
      final isLocked = widget.quizController.isAnswerCorrect.value ||
          widget.quizController.flashcardReadController.retryQuestion.value ==
              0;

      Color border = const Color(0xFF7D7D7D);
      Color bg = Colors.white;
      if (assignedOption != null && isChecked) {
        border = isCorrect ? Colors.green : Colors.red;
        bg = isCorrect ? const Color(0x102ECC71) : const Color(0x10F44336);
      }

      return DragTarget<QuizFillBlankOptionEntity>(
        onWillAccept: (_) => !isLocked,
        onAccept: (incoming) {
          if (isLocked) return;
          final optId = incoming.id;
          if (optId == null) return;
          widget.quizController
              .assignOptionToBlank(optionId: optId, blankId: widget.blankId);
          _rayController.fire();
        },
        builder: (context, candidate, rejected) {
          final hovering = candidate.isNotEmpty;
          return RayBurst(
            controller: _rayController,
            color: const Color(0xFF6B42B8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: hovering ? const Color(0x0F6B42B8) : bg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hovering ? const Color(0xFF6B42B8) : border,
                  width: 1.4,
                ),
              ),
              child: assignedOption == null
                  ? const SizedBox(width: 56, height: 20)
                  : (isLocked
                      ? _Chip(label: assignedOption!.value ?? '')
                      : RayDraggableChip<QuizFillBlankOptionEntity>(
                          data: assignedOption!,
                          color: const Color(0xFF6B42B8),
                          feedback: _Chip(
                            label: assignedOption!.value ?? '',
                            isDragging: true,
                          ),
                          childWhenDragging:
                              const SizedBox(width: 56, height: 20),
                          child: _Chip(label: assignedOption!.value ?? ''),
                        )),
            ),
          );
        },
      );
    });
  }
}

class _OptionsTray extends StatefulWidget {
  const _OptionsTray({
    required this.options,
    required this.quizController,
    required this.isLocked,
  });

  final List<QuizFillBlankOptionEntity> options;
  final FlashcardQuizController quizController;
  final bool isLocked;

  @override
  State<_OptionsTray> createState() => _OptionsTrayState();
}

class _OptionsTrayState extends State<_OptionsTray> {
  final ScrollController _scrollController = ScrollController();
  late final RayBurstController _rayController;
  late final List<QuizFillBlankOptionEntity> _shuffledOptions;

  List<QuizFillBlankOptionEntity> _unassigned() {
    return _shuffledOptions.where((opt) {
      final id = opt.id;
      if (id == null) return true;
      return !widget.quizController.assignedBlankByOption.containsKey(id);
    }).toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _rayController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _rayController = RayBurstController();
    _shuffledOptions = List.from(widget.options)..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      widget.quizController.assignedBlankByOption.length;
      final pool = _unassigned();
      return DragTarget<QuizFillBlankOptionEntity>(
        onWillAccept: (_) => !widget.isLocked,
        onAccept: (incoming) {
          if (widget.isLocked) return;
          final optId = incoming.id;
          if (optId == null) return;
          widget.quizController
              .assignOptionToBlank(optionId: optId, blankId: null);
          _rayController.fire();
        },
        builder: (context, candidate, rejected) {
          final hovering = candidate.isNotEmpty;
          return RayBurst(
            controller: _rayController,
            color: const Color(0xFF6B42B8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              height: 96,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                color: hovering ? const Color(0x0F6B42B8) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                trackVisibility: true,
                radius: const Radius.circular(8),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    children: pool.map((opt) {
                      final chip = _Chip(label: opt.value ?? '-');
                      if (widget.isLocked) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: chip,
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: RayDraggableChip<QuizFillBlankOptionEntity>(
                          data: opt,
                          color: const Color(0xFF6B42B8),
                          feedback:
                              _Chip(label: opt.value ?? '-', isDragging: true),
                          childWhenDragging:
                              const SizedBox(width: 64, height: 32),
                          child: chip,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    this.isDragging = false,
  });

  final String label;
  final bool isDragging;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: isDragging ? 6 : 0,
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF7D7D7D), width: 1.2),
          boxShadow: isDragging
              ? const [
                  BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 10,
                      offset: Offset(0, 4))
                ]
              : const [
                  BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 6,
                      offset: Offset(0, 3))
                ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
