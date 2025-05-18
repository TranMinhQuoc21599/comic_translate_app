class AppConfig {
  static const String appName = 'Comic Translate';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'https://api.comictranslate.com'; // Example URL

  // Feature Flags
  static const bool enableNSFWDetection = true;
  static const bool enableWatermark = true;

  // Limits
  static const int freeUserDailyLimit = 5;
  static const double premiumPrice = 5.0;

  // Supported File Types
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  // Supported Comic Sites
  static const List<String> supportedSites = ['webtoon.com', 'mangadex.org'];
}
