// lib/domain/services/ads_and_coins_manager.dart

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';

/// 🎬 نظام إدارة الإعلانات والعملات
class AdsAndCoinsManager {
  static const String REWARDED_AD_UNIT_ANDROID =
      'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyyyyyy'; // استبدل برقمك
  static const String REWARDED_AD_UNIT_IOS =
      'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyyyyyy'; // استبدل برقمك

  static const String INTERSTITIAL_AD_UNIT_ANDROID =
      'ca-app-pub-xxxxxxxxxxxxxxxx/zzzzzzzzzzzzzz';
  static const String INTERSTITIAL_AD_UNIT_IOS =
      'ca-app-pub-xxxxxxxxxxxxxxxx/zzzzzzzzzzzzzz';

  static const String BANNER_AD_UNIT_ANDROID =
      'ca-app-pub-xxxxxxxxxxxxxxxx/wwwwwwwwwwwwww';
  static const String BANNER_AD_UNIT_IOS =
      'ca-app-pub-xxxxxxxxxxxxxxxx/wwwwwwwwwwwwww';

  // ========== متغيرات الحالة ==========
  late RewardedAd? _rewardedAd;
  late InterstitialAd? _interstitialAd;
  late BannerAd? _bannerAd;

  DateTime? _lastAdTime;
  final int _adCooldownMinutes = 3;

  int _coinsEarned = 0;
  int _totalCoins = 0;

  bool _isAdLoading = false;
  bool _adShowingInProgress = false;

  // ========== Callbacks ==========
  Function(int coinsEarned)? onAdReward;
  Function(String adType)? onAdDismissed;
  Function()? onAdClicked;

  /// التحقق من إمكانية عرض إعلان
  bool canShowAd() {
    if (_adShowingInProgress) return false;
    if (_lastAdTime == null) return true;

    final timeSinceLastAd = DateTime.now().difference(_lastAdTime!).inMinutes;
    return timeSinceLastAd >= _adCooldownMinutes;
  }

  /// عرض إعلان مكافأة
  // Future<void> showRewardedAd({
  //   required Function(int coinsEarned) onRewardEarned,
  // }) async {
  //   if (_isAdLoading || _adShowingInProgress) return;
  //   if (!canShowAd()) {
  //     print('⏳ يجب الانتظار ${_adCooldownMinutes} دقائق قبل الإعلان التالي');
  //     return;
  //   }
  //
  //   _adShowingInProgress = true;
  //   _isAdLoading = true;
  //
  //   try {
  //     _rewardedAd = await _loadRewardedAd();
  //
  //     if (_rewardedAd == null) {
  //       _adShowingInProgress = false;
  //       print('❌ فشل تحميل الإعلان');
  //       return;
  //     }
  //
  //     _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
  //       onAdShowedFullScreenContent: (_) {
  //         print('📺 تم عرض الإعلان');
  //       },
  //       onAdDismissedFullScreenContent: (_) {
  //         print('❌ تم إغلاق الإعلان');
  //         _rewardedAd?.dispose();
  //         _rewardedAd = null;
  //         _lastAdTime = DateTime.now();
  //         _adShowingInProgress = false;
  //         onAdDismissed?.call('rewarded');
  //       },
  //       onAdFailedToShowFullScreenContent: (ad, error) {
  //         print('❌ فشل عرض الإعلان: ${error.message}');
  //         ad.dispose();
  //         _rewardedAd = null;
  //         _adShowingInProgress = false;
  //       },
  //     );
  //
  //     await _rewardedAd!.show(
  //       onUserEarnedReward: (ad, reward) {
  //         int coinsEarned = reward.amount.toInt();
  //         _coinsEarned = coinsEarned;
  //         _totalCoins += coinsEarned;
  //         print('🎉 حصلت على $coinsEarned عملة!');
  //         onRewardEarned(coinsEarned);
  //         onAdReward?.call(coinsEarned);
  //       },
  //     );
  //   } catch (e) {
  //     print('❌ خطأ في عرض الإعلان: $e');
  //     _adShowingInProgress = false;
  //   } finally {
  //     _isAdLoading = false;
  //   }
  // }

  /// عرض إعلان كامل الشاشة
  // Future<void> showInterstitialAd() async {
  //   if (_isAdLoading || _adShowingInProgress) return;
  //   if (!canShowAd()) {
  //     print('⏳ يجب الانتظار ${_adCooldownMinutes} دقائق قبل الإعلان التالي');
  //     return;
  //   }
  //
  //   _adShowingInProgress = true;
  //   _isAdLoading = true;
  //
  //   try {
  //     _interstitialAd = await _loadInterstitialAd();
  //
  //     if (_interstitialAd == null) {
  //       _adShowingInProgress = false;
  //       print('❌ فشل تحميل الإعلان');
  //       return;
  //     }
  //
  //     _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
  //       onAdShowedFullScreenContent: (_) {
  //         print('📺 تم عرض الإعلان');
  //       },
  //       onAdDismissedFullScreenContent: (_) {
  //         print('❌ تم إغلاق الإعلان');
  //         _interstitialAd?.dispose();
  //         _interstitialAd = null;
  //         _lastAdTime = DateTime.now();
  //         _adShowingInProgress = false;
  //         onAdDismissed?.call('interstitial');
  //       },
  //       onAdFailedToShowFullScreenContent: (ad, error) {
  //         print('❌ فشل عرض الإعلان: ${error.message}');
  //         ad.dispose();
  //         _interstitialAd = null;
  //         _adShowingInProgress = false;
  //       },
  //     );
  //
  //     await _interstitialAd!.show();
  //   } catch (e) {
  //     print('❌ خطأ في عرض الإعلان: $e');
  //     _adShowingInProgress = false;
  //   } finally {
  //     _isAdLoading = false;
  //   }
  // }

  // /// تحميل إعلان مكافأة
  // Future<RewardedAd?> _loadRewardedAd() async {
  //   try {
  //     final adUnitId = _getRewardedAdUnitId();
  //
  //     return await RewardedAd.load(
  //       adUnitId: adUnitId,
  //       request: const AdRequest(),
  //       rewardedAdLoadCallback: RewardedAdLoadCallback(
  //         onAdLoaded: (ad) {
  //           print('✅ تم تحميل إعلان المكافأة');
  //         },
  //         onAdFailedToLoad: (error) {
  //           print('❌ فشل تحميل الإعلان: ${error.message}');
  //         },
  //       ),
  //     );
  //   } catch (e) {
  //     print('❌ خطأ في تحميل الإعلان: $e');
  //     return null;
  //   }
  // }

  // /// تحميل إعلان كامل الشاشة
  // Future<InterstitialAd?> _loadInterstitialAd() async {
  //   try {
  //     final adUnitId = _getInterstitialAdUnitId();
  //
  //     return await InterstitialAd.load(
  //       adUnitId: adUnitId,
  //       request: const AdRequest(),
  //       adLoadCallback: InterstitialAdLoadCallback(
  //         onAdLoaded: (ad) {
  //           print('✅ تم تحميل الإعلان الكامل');
  //         },
  //         onAdFailedToLoad: (error) {
  //           print('❌ فشل تحميل الإعلان: ${error.message}');
  //         },
  //       ),
  //     );
  //   } catch (e) {
  //     print('❌ خطأ في تحميل الإعلان: $e');
  //     return null;
  //   }
  // }

  /// تحميل إعلان الشريط (Banner)
  Future<BannerAd?> loadBannerAd() async {
    try {
      final adUnitId = _getBannerAdUnitId();

      final bannerAd = BannerAd(
        adUnitId: adUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            print('✅ تم تحميل إعلان الشريط');
          },
          onAdFailedToLoad: (ad, error) {
            print('❌ فشل تحميل الإعلان: ${error.message}');
            ad.dispose();
          },
        ),
      );

      await bannerAd.load();
      _bannerAd = bannerAd;
      return bannerAd;
    } catch (e) {
      print('❌ خطأ في تحميل الإعلان: $e');
      return null;
    }
  }

  /// الحصول على معرف وحدة الإعلان المكافأة
  String _getRewardedAdUnitId() {
    // اختبار: استخدم test ad unit ids من Google
    // return Platform.isAndroid
    //     ? 'ca-app-pub-3940256099942544/5224354917' // Test ID
    //     : 'ca-app-pub-3940256099942544/1712485313'; // Test ID for iOS

    return REWARDED_AD_UNIT_ANDROID; // استبدل برقمك الفعلي
  }

  /// الحصول على معرف وحدة الإعلان الكامل
  String _getInterstitialAdUnitId() {
    return INTERSTITIAL_AD_UNIT_ANDROID;
  }

  /// الحصول على معرف وحدة إعلان الشريط
  String _getBannerAdUnitId() {
    return BANNER_AD_UNIT_ANDROID;
  }

  // ========== العملات ==========

  /// إضافة عملات
  void addCoins(int amount) {
    _totalCoins += amount;
    print('💰 تم إضافة $amount عملة (المجموع: $_totalCoins)');
  }

  /// خصم عملات
  bool spendCoins(int amount) {
    if (_totalCoins >= amount) {
      _totalCoins -= amount;
      print('💸 تم صرف $amount عملة (المتبقي: $_totalCoins)');
      return true;
    }
    print('❌ لا توجد عملات كافية');
    return false;
  }

  /// الحصول على عدد العملات
  int getCoins() => _totalCoins;

  /// تعيين عدد العملات
  void setCoins(int amount) {
    _totalCoins = amount;
  }

  /// الحصول على آخر عملات تم كسبها
  int getLastAdReward() => _coinsEarned;

  // ========== التنظيف ==========

  /// التخلص من الموارد
  void dispose() {
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
    _bannerAd?.dispose();
  }
}

/// 💰 نظام الاقتصاد (Economic System)
class EconomicSystem {
  static const int COIN_PER_PERFECT = 500;
  static const int COIN_PER_LEVEL = 100;
  static const int COIN_PER_AD_WATCH = 50;
  static const int DAILY_LOGIN_BONUS = 100;

  int _totalCoins = 0;
  DateTime? _lastDailyBonus;

  /// حساب العملات من النتيجة
  int calculateCoinsFromScore(int score, bool isPerfect, bool isPremium) {
    int coins = (score / 100).toInt(); // 1 عملة لكل 100 نقطة

    if (isPerfect) {
      coins += COIN_PER_PERFECT;
    }

    // علاوة Premium
    if (isPremium) {
      coins = (coins * 1.5).toInt();
    }

    return coins;
  }

  /// الحصول على مكافأة تسجيل الدخول اليومية
  int getDailyLoginBonus() {
    if (_lastDailyBonus == null ||
        DateTime.now().difference(_lastDailyBonus!).inHours >= 24) {
      _lastDailyBonus = DateTime.now();
      return DAILY_LOGIN_BONUS;
    }
    return 0;
  }

  /// حساب قيمة التذكرة
  int calculateTickets(int userRank, int totalScore) {
    if (userRank <= 10) {
      return totalScore ~/ 50; // أفضل 10: تذكرة كل 50 نقطة
    } else if (userRank <= 100) {
      return totalScore ~/ 100; // أفضل 100: تذكرة كل 100 نقطة
    } else {
      return totalScore ~/ 200; // الباقي: تذكرة كل 200 نقطة
    }
  }

  /// الحصول على إجمالي العملات
  int getTotalCoins() => _totalCoins;

  /// تعيين العملات
  void setTotalCoins(int amount) {
    _totalCoins = amount;
  }

  /// إضافة عملات
  void addCoins(int amount) {
    _totalCoins += amount;
  }

  /// خصم عملات
  bool deductCoins(int amount) {
    if (_totalCoins >= amount) {
      _totalCoins -= amount;
      return true;
    }
    return false;
  }
}
