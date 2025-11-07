class POIModel {
  final String id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final QuestModel? quest;
  final String? videoUrl;
  final String? audioText;
  final double geofenceRadius; // Радиус в метрах для геофенсинга

  POIModel({
    required this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    this.quest,
    this.videoUrl,
    this.audioText,
    this.geofenceRadius = 100.0, // По умолчанию 100 метров
  });
}

class QuestModel {
  final String title;
  final List<QuestionModel> questions;

  QuestModel({
    required this.title,
    required this.questions,
  });
}

class QuestionModel {
  final String text;
  final List<String> options;
  final String correctAnswer;

  QuestionModel({
    required this.text,
    required this.options,
    required this.correctAnswer,
  });
}

