import 'package:flutter/material.dart';
import '../constants/strings.dart';
import '../constants/app_colors.dart';
import '../models/poi_model.dart';

class QuestWidget extends StatefulWidget {
  final QuestModel quest;

  const QuestWidget({super.key, required this.quest});

  @override
  State<QuestWidget> createState() => _QuestWidgetState();
}

class _QuestWidgetState extends State<QuestWidget> {
  int _currentQuestionIndex = -1;
  bool _isQuestActive = false;
  bool _isQuestCompleted = false;
  bool _isQuestFailed = false;
  String? _selectedAnswer;

  void _startQuest() {
    setState(() {
      _isQuestActive = true;
      _currentQuestionIndex = 0;
      _isQuestCompleted = false;
      _isQuestFailed = false;
    });
  }

  void _handleAnswer(String selectedAnswer, String correctAnswer) {
    setState(() {
      _selectedAnswer = selectedAnswer;
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (selectedAnswer == correctAnswer) {
        if (_currentQuestionIndex < widget.quest.questions.length - 1) {
          setState(() {
            _currentQuestionIndex++;
            _selectedAnswer = null;
          });
        } else {
          setState(() {
            _isQuestCompleted = true;
            _isQuestActive = false;
          });
        }
      } else {
        setState(() {
          _isQuestFailed = true;
          _isQuestActive = false;
        });
      }
    });
  }

  void _retryQuest() {
    setState(() {
      _currentQuestionIndex = -1;
      _isQuestActive = false;
      _isQuestCompleted = false;
      _isQuestFailed = false;
      _selectedAnswer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isQuestActive && !_isQuestCompleted && !_isQuestFailed)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startQuest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: AppColors.bgColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppStrings.startQuest,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (_isQuestActive && _currentQuestionIndex >= 0)
            _buildQuestion(),
          if (_isQuestCompleted) _buildSuccessMessage(),
          if (_isQuestFailed) _buildFailureMessage(),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    final question = widget.quest.questions[_currentQuestionIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...question.options.map((option) {
          final isSelected = _selectedAnswer == option;
          final isCorrect = option == question.correctAnswer;
          Color? backgroundColor;
          if (_selectedAnswer != null) {
            if (isCorrect) {
              backgroundColor = AppColors.success;
            } else if (isSelected) {
              backgroundColor = AppColors.error;
            } else {
              backgroundColor = Colors.white.withOpacity(0.1);
            }
          } else {
            backgroundColor = Colors.white.withOpacity(0.1);
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton(
              onPressed: _selectedAnswer == null
                  ? () => _handleAnswer(option, question.correctAnswer)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 0),
              ),
              child: Text(
                option,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        Text(
          AppStrings.questSuccess,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.questCompleted,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _retryQuest,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              foregroundColor: AppColors.bgColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              AppStrings.questRetry,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFailureMessage() {
    return Column(
      children: [
        Text(
          AppStrings.questFailed,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Квест өтелмеді. Қайта байқап көріңіз!',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _retryQuest,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              foregroundColor: AppColors.bgColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              AppStrings.questRetry,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

