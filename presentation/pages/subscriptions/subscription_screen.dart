// lib/presentation/pages/subscription_screen.dart

import 'package:flutter/material.dart';
import 'package:water_mixer_puzzle/services/stripe_service.dart';

/// 💳 شاشة الاشتراكات
class SubscriptionScreen extends StatefulWidget {
  final String userId;
  final String email;

  const SubscriptionScreen({
    required this.userId,
    required this.email,
    Key? key,
  }) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💳 الاشتراكات المتاحة'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // العنوان
          const Text(
            'اختر خطتك المفضلة',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // الخطة 1: Premium شهري
          _buildSubscriptionCard(
            title: 'Premium شهري',
            price: '\$4.99',
            duration: 'شهر واحد',
            benefits: [
              '✅ بدون إعلانات',
              '✅ طاقة غير محدودة',
              '✅ 2x نقاط المكافآت',
              '✅ دعم الأولوية',
            ],
            color: Colors.blue,
            onTap: () => _handleSubscription('premium_monthly'),
          ),

          const SizedBox(height: 16),

          // الخطة 2: Premium سنوي (الأفضل)
          _buildSubscriptionCard(
            title: 'Premium سنوي ⭐',
            price: '\$39.99',
            duration: 'سنة واحدة',
            benefits: [
              '✅ بدون إعلانات',
              '✅ طاقة غير محدودة',
              '✅ 3x نقاط المكافآت',
              '✅ 5000 عملة مجاني',
              '✅ دعم الأولوية',
            ],
            color: Colors.green,
            onTap: () => _handleSubscription('premium_yearly'),
            isBest: true,
          ),

          const SizedBox(height: 16),

          // الخطة 3: خطة الدعم
          _buildSubscriptionCard(
            title: 'خطة الدعم',
            price: '\$0.99',
            duration: 'لمرة واحدة',
            benefits: [
              '✅ 1000 عملة',
              '✅ دعم مباشر من الفريق',
            ],
            color: Colors.orange,
            onTap: () => _handleSubscription('support'),
          ),

          const SizedBox(height: 30),

          // شروط الاستخدام
          Text(
            'بالضغط على اي خطة، توافق على شروط الاستخدام',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard({
    required String title,
    required String price,
    required String duration,
    required List<String> benefits,
    required Color color,
    required VoidCallback onTap,
    bool isBest = false,
  }) {
    return Card(
      elevation: isBest ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: isBest
            ? BorderSide(color: color, width: 3)
            : BorderSide.none,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: isBest
              ? LinearGradient(
                  colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                )
              : null,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان والسعر
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      duration,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // الفوائد
            ...benefits
                .map((benefit) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        benefit,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ))
                .toList(),

            const SizedBox(height: 16),

            // الزر
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'اشترك الآن',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubscription(String subscriptionId) async {
    setState(() => _isLoading = true);

    // try {
    //   final success = await StripeService.showPaymentSheet(
    //     subscriptionId: subscriptionId,
    //     email: widget.email,
    //     userId: widget.userId,
    //     customerName: 'Customer',
    //   );
    //
    //   if (success) {
    //     _showSuccessDialog();
    //   } else {
    //     _showErrorDialog('فشل الدفع. حاول مرة أخرى.');
    //   }
    // } catch (e) {
    //   _showErrorDialog('خطأ: $e');
    // } finally {
    //   setState(() => _isLoading = false);
    // }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✅ تم الدفع بنجاح!'),
        content: const Text('شكراً على اشتراكك. استمتع بجميع المميزات!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // إغلاق Dialog
              Navigator.pop(context); // الرجوع للشاشة السابقة
            },
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('❌ خطأ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}
