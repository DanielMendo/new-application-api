class AppConfig {
  static const bool isProduction = false;

  static String get baseUrl {
    return isProduction
        ? 'https://bloogol.com/api'
        : 'http://192.168.1.70:8000/api';
  }

  static String get baseUrlWeb {
    return isProduction ? 'https://bloogol.com' : 'http://192.168.1.70:8000';
  }

  static String get baseStorageUrl {
    return isProduction
        ? 'https://bloogol.com/storage'
        : 'http://192.168.1.70:8000/storage';
  }
}
