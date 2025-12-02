class ApiConfig {
  // Groq LLM API Configuration (for feedback)
  static const String groqApiKey = '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';
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1';
  static const String groqModel = 'llama3-8b-8192';
  
  // Cerebras AI Configuration (for solutions) - Using OpenRouter instead
  static const String cerebrasApiKey = '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';
  static const String cerebrasBaseUrl = 'https://openrouter.ai/api/v1';
  static const String cerebrasModel = 'openai/gpt-oss-20b:free';
  
  // Judge0 API Configuration
  static const String judge0ApiKey = '74b4d2d829mshe9b4c90979a0e0cp1e0591jsnfafadaf6536e';
  static const String judge0BaseUrl = 'https://judge0-ce.p.rapidapi.com';
  static const String judge0Host = 'judge0-ce.p.rapidapi.com';
  
  // API Headers
  static Map<String, String> get groqHeaders => {
    'Authorization': 'Bearer $groqApiKey',
    'Content-Type': 'application/json',
  };
  
  static Map<String, String> get cerebrasHeaders => {
    'Authorization': 'Bearer $cerebrasApiKey',
    'Content-Type': 'application/json',
  };
  
  static Map<String, String> get judge0Headers => {
    'X-RapidAPI-Key': judge0ApiKey,
    'X-RapidAPI-Host': judge0Host,
    'Content-Type': 'application/json',
  };
  
  // Validation methods
  static bool get isGroqConfigured => groqApiKey.isNotEmpty;
  static bool get isCerebrasConfigured => cerebrasApiKey.isNotEmpty;
  static bool get isJudge0Configured => judge0ApiKey.isNotEmpty;
  static bool get isFullyConfigured => isGroqConfigured && isCerebrasConfigured && isJudge0Configured;
}
