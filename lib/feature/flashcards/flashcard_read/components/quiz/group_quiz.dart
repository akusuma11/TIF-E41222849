import 'package:epic_story_app/domain/entities/quiz/quiz_group_entity.dart';
import 'package:epic_story_app/feature/flashcards/flashcard_read/components/quiz/components/ray_burst.dart';
import 'package:epic_story_app/feature/flashcards/flashcard_read/flashcard_quiz_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GroupQuiz extends StatelessWidget {
  const GroupQuiz({
    super.key,
    required this.quizController,
    required this.quizData,
  });

  final FlashcardQuizController quizController;
  final QuizGroupEntity quizData;

  @override
  Widget build(BuildContext context) {
    final groups = (quizData.groups ?? []).take(2).toList();
    final options = (quizData.options ?? []).take(8).toList();
    quizController.cleanupAssignments(
      options.where((o) => o.id != null).map((o) => o.id!).toSet(),
    );

    return Column(
      children: [
        Obx(() {
          // observe changes to trigger rebuilds
          quizController.assignedGroupByOption.length;
          quizController.isAnswerChecked.value;
          final isLocked = quizController.isAnswerCorrect.value ||
              quizController.flashcardReadController.retryQuestion.value == 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBFBFBF), width: 1.2),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10,
                    offset: Offset(0, 5)),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(groups.length, (index) {
                final group = groups[index];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 0 : 10,
                      right: index == groups.length - 1 ? 0 : 10,
                    ),
                    child: _GroupColumn(
                      group: group,
                      allOptions: options,
                      quizController: quizController,
                      isLocked: isLocked,
                    ),
                  ),
                );
              }),
            ),
          );
        }),
        const SizedBox(height: 24),
        Obx(() {
          final isLocked = quizController.isAnswerCorrect.value ||
              quizController.flashcardReadController.retryQuestion.value == 0;
          return _UnassignedOptionsRow(
            options: options,
            quizController: quizController,
            isLocked: isLocked,
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _GroupColumn extends StatelessWidget {
  const _GroupColumn({
    required this.group,
    required this.allOptions,
    required this.quizController,
    required this.isLocked,
  });

  final QuizGroupItemEntity group;
  final List<QuizGroupOptionEntity> allOptions;
  final FlashcardQuizController quizController;
  final bool isLocked;

  List<QuizGroupOptionEntity> _assignedOptions(String groupId) {
    return allOptions.where((option) {
      final optId = option.id;
      if (optId == null) return false;
      return quizController.assignedGroupByOption[optId] == groupId;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final groupId = group.id ?? '';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFFFF5BE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFBFBF), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Center(
              child: Text(
                group.title ?? '-',
                softWrap: true,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ..._buildDropSlots(groupId),
        ],
      ),
    );
  }

  List<Widget> _buildDropSlots(String groupId) {
    final assigned = _assignedOptions(groupId);
    const slotsCount = 4; // static max 4 slots per group
    return List.generate(slotsCount, (index) {
      final option = index < assigned.length ? assigned[index] : null;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _GroupDropSlot(
          groupId: groupId,
          option: option,
          quizController: quizController,
          isLocked: isLocked,
        ),
      );
    });
  }
}

class _GroupDropSlot extends StatefulWidget {
  const _GroupDropSlot({
    required this.groupId,
    required this.option,
    required this.quizController,
    required this.isLocked,
  });

  final String groupId;
  final QuizGroupOptionEntity? option;
  final FlashcardQuizController quizController;
  final bool isLocked;

  @override
  State<_GroupDropSlot> createState() => _GroupDropSlotState();
}

class _GroupDropSlotState extends State<_GroupDropSlot> {
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
    final isChecked = widget.quizController.isAnswerChecked.value;
    final isCorrect = widget.option != null &&
        widget.option!.correctGroupId != null &&
        widget.option!.correctGroupId == widget.groupId;

    Color borderColor = const Color(0xFF6B6B6B);
    Color fillColor = Colors.white;
    if (widget.option != null && isChecked) {
      borderColor = isCorrect ? Colors.green : Colors.red;
      fillColor = isCorrect ? const Color(0x102ECC71) : const Color(0x10F44336);
    }

    return DragTarget<QuizGroupOptionEntity>(
      onWillAccept: (incoming) {
        if (widget.isLocked) return false;
        if (incoming?.id == null) return false;
        final optId = incoming!.id!;
        final existing = widget.quizController.assignedGroupByOption[optId];
        if (existing == widget.groupId) return true;
        return widget.quizController.countForGroup(widget.groupId) < 4;
      },
      onAccept: (incoming) {
        if (widget.isLocked) return;
        final optId = incoming.id;
        if (optId == null) return;
        widget.quizController
            .assignOptionToGroup(optionId: optId, groupId: widget.groupId);
        _rayController.fire();
      },
      builder: (context, candidate, rejected) {
        final isHovering = candidate.isNotEmpty;
        return RayBurst(
          controller: _rayController,
          color: const Color(0xFF6B42B8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
            decoration: BoxDecoration(
              color: isHovering ? const Color(0x0F6B42B8) : fillColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isHovering ? const Color(0xFF6B42B8) : borderColor,
                width: 1.2,
              ),
            ),
            child: widget.option == null
                ? const Center(
                    child: Text(
                      'Taruh disini',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B6B6B),
                      ),
                    ),
                  )
                : Center(
                    child: _DraggableOptionCard(
                      option: widget.option!,
                      quizController: widget.quizController,
                      groupId: widget.groupId,
                      isLocked: widget.isLocked,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _DraggableOptionCard extends StatelessWidget {
  const _DraggableOptionCard({
    required this.option,
    required this.quizController,
    required this.groupId,
    required this.isLocked,
  });

  final QuizGroupOptionEntity option;
  final FlashcardQuizController quizController;
  final String groupId;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final isChecked = quizController.isAnswerChecked.value;
    final isCorrect =
        option.correctGroupId != null && option.correctGroupId == groupId;

    if (isLocked) {
      return _OptionChip(
        label: option.value ?? '-',
        isCorrect: isChecked ? isCorrect : null,
      );
    }

    return Draggable<QuizGroupOptionEntity>(
      data: option,
      feedback: _OptionChip(
        label: option.value ?? '-',
        isDragging: true,
      ),
      childWhenDragging: const SizedBox.shrink(),
      child: _OptionChip(
        label: option.value ?? '-',
        isCorrect: isChecked ? isCorrect : null,
      ),
    );
  }
}

class _UnassignedOptionsRow extends StatefulWidget {
  const _UnassignedOptionsRow({
    required this.options,
    required this.quizController,
    required this.isLocked,
  });

  final List<QuizGroupOptionEntity> options;
  final FlashcardQuizController quizController;
  final bool isLocked;

  @override
  State<_UnassignedOptionsRow> createState() => _UnassignedOptionsRowState();
}

class _UnassignedOptionsRowState extends State<_UnassignedOptionsRow> {
  final ScrollController _scrollController = ScrollController();
  late final RayBurstController _rayController;
  late final List<QuizGroupOptionEntity> _shuffledOptions;

  List<QuizGroupOptionEntity> _unassigned() {
    return _shuffledOptions.where((option) {
      final id = option.id;
      if (id == null) return true;
      return !widget.quizController.assignedGroupByOption.containsKey(id);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _rayController = RayBurstController();
    _shuffledOptions = List.from(widget.options)..shuffle();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _rayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      widget.quizController.assignedGroupByOption.length;
      return DragTarget<QuizGroupOptionEntity>(
        onWillAccept: (_) => !widget.isLocked,
        onAccept: (incoming) {
          if (widget.isLocked) return;
          final optId = incoming.id;
          if (optId == null) return;
          widget.quizController
              .assignOptionToGroup(optionId: optId, groupId: null);
          _rayController.fire();
        },
        builder: (context, candidate, rejected) {
          final items = _unassigned();
          return RayBurst(
            controller: _rayController,
            color: const Color(0xFF6B42B8),
            child: AnimatedContainer(
              width: double.infinity,
              duration: const Duration(milliseconds: 120),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Color(0xFFFFF5BE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD8D8D8)),
              ),
              height: 120,
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                trackVisibility: true,
                interactive: true,
                radius: const Radius.circular(8),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    children: items.map((option) {
                      final chip = _OptionChip(
                        label: option.value ?? '-',
                        isDragging: false,
                      );
                      if (widget.isLocked) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: chip,
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Draggable<QuizGroupOptionEntity>(
                          data: option,
                          feedback: _OptionChip(
                            label: option.value ?? '-',
                            isDragging: true,
                          ),
                          childWhenDragging: const SizedBox.shrink(),
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

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    this.isCorrect,
    this.isDragging = false,
  });

  final String label;
  final bool? isCorrect;
  final bool isDragging;

  @override
  Widget build(BuildContext context) {
    Color border = const Color(0xFF6B6B6B);
    Color bg = Colors.white;
    if (isCorrect != null) {
      border = isCorrect! ? Colors.green : Colors.red;
      bg = isCorrect! ? const Color(0x102ECC71) : const Color(0x10F44336);
    }

    return Material(
      elevation: isDragging ? 6 : 0,
      color: Colors.transparent,
      child: Container(
        height: 60,
        width: 105,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1.2),
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
        child: Center(
          child: FittedBox(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
