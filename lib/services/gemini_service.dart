import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyAKApoolhZAtijBZiodAS4SR2d-1_My13k';
  
  // Список моделей для попытки в порядке приоритета
  static const List<String> _models = [
    'gemini-pro',
    'gemini-1.5-flash',
    'gemini-1.5-pro',
  ];
  
  static GenerativeModel _getModel(String modelName) {
    return GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
    );
  }

  static const String _systemPrompt = '''
Сіз "Тірі Тарих" қолданбасының AI-көмекшісісіз. Бұл қолданба Қызылорда облысының тарихи орындары туралы мәліметтер беретін интерактивті гид.

Қолданбада бар тарихи орындар:
1. Қорқыт Ата кешені - Түркі әлемінің қасиетті орталығы. Қорқыт Ата - түркі халықтарының атақты философы, кобызшысы және данасы. Ол қобызды ойлап тапқан және мәңгілікті іздеген.
2. Сығанақ қалашығы - Қыпшақ хандығының бұрынғы астанасы. Орта ғасырлардағы маңызды сауда орталығы.

Сіздің міндеттеріңіз:
- Қызылорда облысының тарихи орындары туралы ақпарат беру
- Қорқыт Ата кешені, Сығанақ қалашығы және басқа тарихи орындар туралы сұрақтарға жауап беру
- Туризмге байланысты кеңес беру
- Бір күн ішінде не көруге болатынын ұсыну
- Тарихи орындар туралы қызықты фактілер айту
- Қазақ тілінде ғана жауап беру

Ескерту: Барлық жауаптар қазақ тілінде, мейірімді, анық және информативті болуы керек.
''';

  static Future<String> getResponse(String userMessage) async {
    String? lastError;
    
    // Пробуем каждую модель по очереди
    for (final modelName in _models) {
      try {
        final model = _getModel(modelName);
        final prompt = '''
$_systemPrompt

Пайдаланушы сұрағы: $userMessage

Жауап:
''';

        final content = [Content.text(prompt)];
        final response = await model.generateContent(
          content,
          generationConfig: GenerationConfig(
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 1024,
          ),
        );

        if (response.text != null && response.text!.isNotEmpty) {
          return response.text!;
        } else {
          // Проверяем, есть ли блокировки
          if (response.candidates.isNotEmpty) {
            final candidate = response.candidates.first;
            if (candidate.finishReason == FinishReason.recitation) {
              return 'Жауап қауіпсіздік себептерімен блокталды. Басқа сұрақ қойып көріңіз.';
            } else if (candidate.finishReason == FinishReason.maxTokens) {
              return 'Жауап тым ұзын болды. Сұрағыңызды қысқартып көріңіз.';
            }
          }
          // Если ответ пустой, пробуем следующую модель
          continue;
        }
      } catch (e) {
        lastError = e.toString();
        final errorMessage = e.toString().toLowerCase();
        
        // Если модель не поддерживается, пробуем следующую
        if (errorMessage.contains('not found') || 
            errorMessage.contains('not supported') ||
            errorMessage.contains('not available')) {
          print('Модель $modelName не поддерживается, пробуем следующую...');
          continue;
        }
        
        // Для других ошибок тоже пробуем следующую модель
        print('Gemini API Error with model $modelName: $e');
        
        // Но если это не ошибка модели, а другая (API key, network и т.д.), 
        // то остальные модели тоже не помогут
        if (errorMessage.contains('api key') || 
            errorMessage.contains('unauthorized') ||
            errorMessage.contains('network') ||
            errorMessage.contains('connection')) {
          break;
        }
        
        continue;
      }
    }
    
    // Если все модели не сработали, возвращаем детальную ошибку
    final errorMessage = lastError?.toLowerCase() ?? '';
    
    if (errorMessage.contains('api key') || errorMessage.contains('unauthorized')) {
      return 'API кілті дұрыс емес немесе жарамсыз. Жүйе басқарушысына хабарласыңыз.';
    } else if (errorMessage.contains('network') || errorMessage.contains('connection')) {
      return 'Интернет байланысы жоқ. Интернетті тексеріп, қайта байқап көріңіз.';
    } else if (errorMessage.contains('quota') || errorMessage.contains('limit')) {
      return 'API лимиті асып кетті. Кейінірек қайта байқап көріңіз.';
    } else if (errorMessage.contains('timeout')) {
      return 'Жауап күту уақыты асып кетті. Қайта байқап көріңіз.';
    } else {
      print('Все модели Gemini не сработали. Последняя ошибка: $lastError');
      return 'API қолжетімсіз. Барлық модельдер тексерілді, бірақ ешқайсысы жұмыс істемеді. Интернет байланысын тексеріп, кейінірек қайта байқап көріңіз.';
    }
  }

  static Future<String> getResponseWithContext(
    String userMessage,
    String context,
  ) async {
    String? lastError;
    
    for (final modelName in _models) {
      try {
        final model = _getModel(modelName);
        final prompt = '''
$_systemPrompt

Қолданушы қазір мына орында: $context

Пайдаланушы сұрағы: $userMessage

Жауап:
''';

        final content = [Content.text(prompt)];
        final response = await model.generateContent(
          content,
          generationConfig: GenerationConfig(
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 1024,
          ),
        );

        if (response.text != null && response.text!.isNotEmpty) {
          return response.text!;
        } else {
          if (response.candidates.isNotEmpty) {
            final candidate = response.candidates.first;
            if (candidate.finishReason == FinishReason.recitation) {
              return 'Жауап қауіпсіздік себептерімен блокталды. Басқа сұрақ қойып көріңіз.';
            }
          }
          continue;
        }
      } catch (e) {
        lastError = e.toString();
        final errorMessage = e.toString().toLowerCase();
        
        if (errorMessage.contains('not found') || 
            errorMessage.contains('not supported') ||
            errorMessage.contains('not available')) {
          continue;
        }
        
        if (errorMessage.contains('api key') || 
            errorMessage.contains('unauthorized') ||
            errorMessage.contains('network') ||
            errorMessage.contains('connection')) {
          break;
        }
        
        continue;
      }
    }
    
    final errorMessage = lastError?.toLowerCase() ?? '';
    
    if (errorMessage.contains('api key') || errorMessage.contains('unauthorized')) {
      return 'API кілті дұрыс емес немесе жарамсыз. Жүйе басқарушысына хабарласыңыз.';
    } else if (errorMessage.contains('network') || errorMessage.contains('connection')) {
      return 'Интернет байланысы жоқ. Интернетті тексеріп, қайта байқап көріңіз.';
    } else if (errorMessage.contains('quota') || errorMessage.contains('limit')) {
      return 'API лимиті асып кетті. Кейінірек қайта байқап көріңіз.';
    } else {
      return 'API қолжетімсіз. Интернет байланысын тексеріп, кейінірек қайта байқап көріңіз.';
    }
  }
}
