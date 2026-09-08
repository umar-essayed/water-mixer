// lib/services/stripe_service.dart - النسخة الكاملة

import 'package:cloud_firestore/cloud_firestore.dart';

/// 💳 خدمة Stripe المتكاملة مع Firebase
// class StripeService {
//   // مفاتيح Stripe
//   static const String publishableKey = 'pk_live_YOUR_KEY_HERE';
//
//   static final StripeService _instance = StripeService._internal();
//
//   factory StripeService() => _instance;
//
//   StripeService._internal();
//
//   // التهيئة
//   static Future<void> init() async {
//     Stripe.publishableKey = publishableKey;
//     await Stripe.instance.applySettings();
//   }
//
//   // ========== الاشتراكات ==========
//   static const subscriptions = {
//     'premium_monthly': {
//       'name': 'Premium شهري',
//       'price': 4.99,
//       'duration': 'شهر واحد',
//     },
//     'premium_yearly': {
//       'name': 'Premium سنوي',
//       'price': 39.99,
//       'duration': 'سنة واحدة',
//     },
//     'support': {
//       'name': 'خطة الدعم',
//       'price': 0.99,
//       'duration': 'لمرة واحدة',
//     },
//   };
//
//   // ========== الدفع الكامل ==========
//   static Future<bool> makePayment({
//     required String subscriptionId,
//     required String email,
//     required String userId,
//   }) async {
//     try {
//       final subscription = subscriptions[subscriptionId];
//       if (subscription == null) {
//         throw 'الاشتراك غير موجود';
//       }
//
//       // 1️⃣ عرض نافذة الدفع
//       await Stripe.instance.presentPaymentSheet();
//
//       // 2️⃣ استدعاء Cloud Function
//       final result = await FirebaseFunctions.instance
//           .httpsCallable('handlePayment')
//           .call({
//             'subscriptionId': subscriptionId,
//             'email': email,
//           });
//
//       if (result.data['success'] == true) {
//         print('✅ تم الدفع وتسجيل الاشتراك بنجاح');
//         return true;
//       } else {
//         throw 'فشل التسجيل';
//       }
//
//     } catch (e) {
//       print('❌ خطأ: $e');
//       return false;
//     }
//   }
//
//   // ========== التحقق من الاشتراك النشط ==========
//   static Future<bool> isSubscriptionActive(String userId) async {
//     try {
//       final result = await FirebaseFunctions.instance
//           .httpsCallable('checkSubscription')
//           .call();
//
//       return result.data['isActive'] == true;
//
//     } catch (e) {
//       print('خطأ: $e');
//       return false;
//     }
//   }
//
//   // ========== الحصول على معلومات الاشتراك ==========
//   static Future<Map?> getSubscriptionInfo(String userId) async {
//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection('subscriptions')
//           .doc(userId)
//           .get();
//
//       if (doc.exists) {
//         return doc.data();
//       }
//       return null;
//
//     } catch (e) {
//       print('خطأ: $e');
//       return null;
//     }
//   }
//
//   // ========== إلغاء الاشتراك ==========
//   static Future<bool> cancelSubscription(String userId) async {
//     try {
//       final result = await FirebaseFunctions.instance
//           .httpsCallable('cancelSubscription')
//           .call();
//
//       return result.data['success'] == true;
//
//     } catch (e) {
//       print('خطأ: $e');
//       return false;
//     }
//   }
// }
