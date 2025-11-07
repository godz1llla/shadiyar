import '../models/poi_model.dart';

class LocalData {
  static List<POIModel> get poiList => [
        POIModel(
          id: 'korkyt-ata',
          title: 'Қорқыт Ата кешені',
          description:
              'Түркі әлемінің қасиетті орталығы. Қорқыт Ата - түркі халықтарының атақты философы, кобызшысы және данасы. Осы жерде оның ескерткіші мен мұражайы орналасқан.',
          latitude: 44.8528,
          longitude: 65.5092,
          imageUrl: 'https://via.placeholder.com/600x400/FF9500/121212?text=Қорқыт+Ата',
          videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
          audioText:
              'Қорқыт Ата - түркі халықтарының атақты философы және кобызшысы. Ол қобызды ойлап тапқан және мәңгілікті іздеген. Осы қасиетті орында сіз оның мұрасын көре аласыз.',
          geofenceRadius: 100.0,
          quest: QuestModel(
            title: 'Қорқыт Ата аңыздары',
            questions: [
              QuestionModel(
                text: 'Қорқыт Ата қандай музыкалық аспап ойлап тапқан?',
                options: ['Домбыра', 'Қобыз', 'Жетіген'],
                correctAnswer: 'Қобыз',
              ),
              QuestionModel(
                text: 'Қорқыт Ата не іздеп жүрді?',
                options: ['Байлық', 'Даңқ', 'Мәңгілік'],
                correctAnswer: 'Мәңгілік',
              ),
            ],
          ),
        ),
        POIModel(
          id: 'syganak',
          title: 'Сығанақ қалашығы',
          description:
              'Қыпшақ хандығының бұрынғы астанасы. Орта ғасырлардағы маңызды сауда орталығы. Қазіргі уақытта археологиялық ескерткіш.',
          latitude: 44.9167,
          longitude: 65.4833,
          imageUrl: 'https://via.placeholder.com/600x400/FF9500/121212?text=Сығанақ',
          videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
          audioText:
              'Сығанақ - Қыпшақ хандығының бұрынғы астанасы. Орта ғасырлардағы маңызды сауда орталығы. Қазіргі уақытта археологиялық ескерткіш ретінде сақталған.',
          geofenceRadius: 100.0,
          quest: QuestModel(
            title: 'Сығанақ сырлары',
            questions: [
              QuestionModel(
                text: 'Сығанақ қандай хандықтың астанасы болған?',
                options: ['Алтын Орда', 'Қазақ хандығы', 'Шағатай ұлысы'],
                correctAnswer: 'Қазақ хандығы',
              ),
            ],
          ),
        ),
      ];

  static Map<String, dynamic> get userProfile => {
        'name': 'User_Nomad',
        'level': 12,
        'rank': 'Зерттеуші',
        'placesVisited': 28,
        'questsCompleted': 15,
      };

  static List<Map<String, dynamic>> get friendsList => [
        {
          'rank': 1,
          'name': 'Aidos_Sultan',
          'level': 25,
          'rankTitle': 'Аңыз',
        },
        {
          'rank': 12,
          'name': 'User_Nomad',
          'level': 12,
          'rankTitle': 'Зерттеуші',
        },
        {
          'rank': 13,
          'name': 'Explorer22',
          'level': 11,
          'rankTitle': 'Саяхатшы',
        },
      ];

  static List<Map<String, dynamic>> get marketItems => [
        {
          'title': 'Аралға джип-тур',
          'description': 'Шытырман оқиға',
          'price': 5000,
          'currency': 'Алтын',
        },
        {
          'title': 'Қобыз ойнау сабағы',
          'description': 'Мәдениет',
          'price': 1500,
          'currency': 'Алтын',
        },
      ];

  static String getAiResponse(String userMessage) {
    // Эмуляция ответов AI на казахском
    final lowerMessage = userMessage.toLowerCase();
    if (lowerMessage.contains('күн') || lowerMessage.contains('бір күн')) {
      return 'Бір күн ішінде Қызылордада мынаны көруге болады:\n\n1. **Қорқыт Ата кешені** - түркі әлемінің қасиетті орталығы\n2. Этно-ауылда түскі ас\n3. Қамбаш көліне саяхат';
    } else if (lowerMessage.contains('тарих') || lowerMessage.contains('тарихи')) {
      return 'Қызылорда облысы бай тарихи мұраға ие. Мұнда Сығанақ қалашығы, Қорқыт Ата кешені және басқа да көптеген тарихи орындар бар.';
    } else if (lowerMessage.contains('қорқыт')) {
      return 'Қорқыт Ата - түркі халықтарының атақты философы және кобызшысы. Ол қобызды ойлап тапқан және мәңгілікті іздеген.';
    } else {
      return 'Жақсы сұрақ! Мен сізге Қызылорда облысының тарихы, мәдениеті және қызықты орындары туралы ақпарат бере аламын. Не туралы білгіңіз келеді?';
    }
  }
}

