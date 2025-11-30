import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RateAppService {
  final InAppReview _inAppReview = InAppReview.instance;
  final SharedPreferences _prefs;
  
  static const String _kActionCountKey = 'rate_app_action_count';
  static const int _kActionThreshold = 5; // Request review every 5 significant actions

  RateAppService(this._prefs);

  Future<void> trackEvent() async {
    int currentCount = _prefs.getInt(_kActionCountKey) ?? 0;
    currentCount++;
    await _prefs.setInt(_kActionCountKey, currentCount);

    if (currentCount >= _kActionThreshold) {
      await _requestReview();
      await _prefs.setInt(_kActionCountKey, 0); // Reset counter
    }
  }

  Future<void> _requestReview() async {
    if (await _inAppReview.isAvailable()) {
      await _inAppReview.requestReview();
    }
  }
}
