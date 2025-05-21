class AppConstants {
  static const String appName = 'The Dream';

  // API Constants
  static const int apiTimeout = 30000; // 30 seconds
  static const int maxRetries = 3;

  // Pagination
  static const int defaultPageSize = 10;

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  // Categories
  static const List<String> postCategories = ['공지', '자유', 'QnA', '기타'];
}
