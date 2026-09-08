// lib/config/firebase_config.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

/// 🔥 Firebase Configuration Singleton
class FirebaseConfig {
  static FirebaseConfig? _instance;
  
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  late FirebaseAnalytics _analytics;
  late FirebaseStorage _storage;
  late FirebaseFunctions _functions;
  late FirebaseRemoteConfig _remoteConfig;

  FirebaseConfig._internal();

  /// الحصول على instance
  static FirebaseConfig get instance {
    _instance ??= FirebaseConfig._internal();
    return _instance!;
  }

  /// تهيئة Firebase
  static Future<void> initialize() async {
    // ملاحظة: يتم استدعاء Firebase.initializeApp() في main.dart
    _instance = FirebaseConfig._internal();
    await _instance!._setupServices();
  }

  /// إعداد الخدمات
  Future<void> _setupServices() async {
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _analytics = FirebaseAnalytics.instance;
    _storage = FirebaseStorage.instance;
    _functions = FirebaseFunctions.instance;
    _remoteConfig = FirebaseRemoteConfig.instance;

    // ⚙️ إعدادات Firestore
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: 40 * 1024 * 1024, // 40 MB
      sslEnabled: true,
    );

    // ⚙️ إعدادات Remote Config
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    // جلب القيم الافتراضية
    await _remoteConfig.setDefaults({
      'ad_frequency': 3, // إعلان كل 3 دقائق
      'rewarded_ad_coins': 50,
      'daily_login_coins': 100,
      'coin_multiplier_premium': 1.5,
      'max_energy': 5,
      'energy_recharge_minutes': 60,
      'max_moves_multiplier': 1.5,
    });

    await _setupFirestoreIndexes();
  }

  /// إعداد مؤشرات Firestore
  Future<void> _setupFirestoreIndexes() async {
    // يتم إنشاء المؤشرات يدويًا في Firebase Console
    // أو عبر firebase/firestore.indexes.json
  }

  // ========== GETTERS ==========

  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseAnalytics get analytics => _analytics;
  FirebaseStorage get storage => _storage;
  FirebaseFunctions get functions => _functions;
  FirebaseRemoteConfig get remoteConfig => _remoteConfig;

  // ========== AUTH METHODS ==========

  /// تسجيل مستخدم جديد
  Future<UserCredential?> registerWithEmail(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      _logError('Register Error', e.message ?? 'Unknown error');
      rethrow;
    }
  }

  /// تسجيل الدخول
  Future<UserCredential?> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      _logError('Sign In Error', e.message ?? 'Unknown error');
      rethrow;
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      _logError('Sign Out Error', e.toString());
      rethrow;
    }
  }

  // ========== USER METHODS ==========

  /// الحصول على المستخدم الحالي
  User? getCurrentUser() => _auth.currentUser;

  /// تحديث بيانات المستخدم
  Future<void> updateUserProfile(String displayName, String? photoURL) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      await _auth.currentUser?.updatePhotoURL(photoURL);
      await _auth.currentUser?.reload();
    } catch (e) {
      _logError('Update Profile Error', e.toString());
      rethrow;
    }
  }

  // ========== FIRESTORE METHODS ==========

  /// حفظ نتيجة اللعبة
  Future<void> saveGameResult({
    required String userId,
    required int levelNumber,
    required int score,
    required int moves,
    required int timeSpent,
    required bool isPerfect,
  }) async {
    try {
      await _firestore.collection('gameResults').add({
        'userId': userId,
        'levelNumber': levelNumber,
        'score': score,
        'moves': moves,
        'timeSpent': timeSpent,
        'isPerfect': isPerfect,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logError('Save Game Result Error', e.toString());
      rethrow;
    }
  }

  /// الحصول على التصنيفات الشهرية
  Future<QuerySnapshot> getMonthlyLeaderboard({
    int limit = 100,
    int month = 0, // 0 للشهر الحالي
    int year = 0, // 0 للسنة الحالية
  }) async {
    final now = DateTime.now();
    final targetMonth = month > 0 ? month : now.month;
    final targetYear = year > 0 ? year : now.year;

    try {
      return await _firestore
          .collection('leaderboard')
          .where('month', isEqualTo: targetMonth)
          .where('year', isEqualTo: targetYear)
          .orderBy('totalScore', descending: true)
          .limit(limit)
          .get();
    } catch (e) {
      _logError('Get Leaderboard Error', e.toString());
      rethrow;
    }
  }

  /// التحقق من النقاط على الخادم (Cloud Function)
  Future<Map<String, dynamic>> validateScore({
    required int score,
    required int levelNumber,
    required int timeSpent,
  }) async {
    try {
      final callable = _functions.httpsCallable('validateScore');
      final result = await callable.call({
        'score': score,
        'levelNumber': levelNumber,
        'timeSpent': timeSpent,
        'clientTimestamp': DateTime.now().millisecondsSinceEpoch,
      });
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      _logError('Validate Score Error', e.toString());
      rethrow;
    }
  }

  // ========== ADMIN METHODS ==========

  /// تحديث نقاط المستوى (Admin)
  Future<void> updateLevelPoints(int levelNumber, int points) async {
    try {
      await _firestore
          .collection('levels')
          .doc('level_$levelNumber')
          .set({'basePoints': points}, SetOptions(merge: true));
    } catch (e) {
      _logError('Update Level Points Error', e.toString());
      rethrow;
    }
  }

  /// تحديث مكافأة الإعلان (Admin)
  Future<void> updateAdReward(String rewardType, int amount) async {
    try {
      await _firestore
          .collection('config')
          .doc('adRewards')
          .set({rewardType: amount}, SetOptions(merge: true));
    } catch (e) {
      _logError('Update Ad Reward Error', e.toString());
      rethrow;
    }
  }

  /// حظر مستخدم (Admin)
  Future<void> banUser(String userId, String reason) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'banned': true,
        'banReason': reason,
        'bannedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      _logError('Ban User Error', e.toString());
      rethrow;
    }
  }

  // ========== ANALYTICS ==========

  /// تسجيل بداية المستوى
  void logLevelStart(int levelNumber, String difficulty) {
    _analytics.logEvent(
      name: 'level_started',
      parameters: {
        'level_number': levelNumber,
        'difficulty': difficulty,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// تسجيل إكمال المستوى
  void logLevelComplete(int levelNumber, int score, int moves) {
    _analytics.logEvent(
      name: 'level_completed',
      parameters: {
        'level_number': levelNumber,
        'score': score,
        'moves': moves,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// تسجيل مشاهدة إعلان
  void logAdWatched(String adType) {
    _analytics.logEvent(
      name: 'ad_watched',
      parameters: {
        'ad_type': adType,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// تسجيل شراء اشتراك
  void logSubscriptionPurchase(String planId, double price) {
    _analytics.logEvent(
      name: 'subscription_purchased',
      parameters: {
        'plan_id': planId,
        'price': price,
        'currency': 'USD',
      },
    );
  }

  // ========== UTILITY METHODS ==========

  /// تسجيل الأخطاء
  void _logError(String title, String message) {
    print('❌ $title: $message');
    _analytics.logEvent(
      name: 'error_occurred',
      parameters: {
        'title': title,
        'message': message,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// الحصول على قيمة من Remote Config
  dynamic getRemoteValue(String key) {
    try {
      return _remoteConfig.getValue(key).asString();
    } catch (e) {
      _logError('Get Remote Config Error', e.toString());
      return null;
    }
  }

  /// تحديث Remote Config
  Future<bool> fetchRemoteConfig() async {
    try {
      await _remoteConfig.fetch();
      await _remoteConfig.activate();
      return true;
    } catch (e) {
      _logError('Fetch Remote Config Error', e.toString());
      return false;
    }
  }
}

// ========== USAGE EXAMPLE ==========
/*

// في main.dart
await FirebaseConfig.initialize();

// الوصول إلى Firebase Services
final auth = FirebaseConfig.instance.auth;
final firestore = FirebaseConfig.instance.firestore;
final analytics = FirebaseConfig.instance.analytics;

// حفظ نتيجة اللعبة
await FirebaseConfig.instance.saveGameResult(
  userId: 'user123',
  levelNumber: 5,
  score: 850,
  moves: 25,
  timeSpent: 120,
  isPerfect: true,
);

// الحصول على التصنيفات
final leaderboard = await FirebaseConfig.instance.getMonthlyLeaderboard();

// تسجيل الأحداث
FirebaseConfig.instance.logLevelComplete(5, 850, 25);

*/
