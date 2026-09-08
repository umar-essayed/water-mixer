// lib/presentation/pages/admin_panel/admin_dashboard.dart

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 🛠️ لوحة تحكم الأدمن الشاملة
class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛠️ لوحة تحكم الأدمن'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '📊 الإحصائيات'),
            Tab(text: '🎮 المستويات'),
            Tab(text: '💰 الإيرادات'),
            Tab(text: '👥 المستخدمون'),
            Tab(text: '🎟️ السحب'),
            Tab(text: '⚙️ الإعدادات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AdminStatisticsTab(),
          AdminLevelsTab(),
          AdminRevenueTab(),
          AdminUsersTab(),
          AdminDrawTab(),
          AdminSettingsTab(),
        ],
      ),
    );
  }
}

// ========== التبويب 1: الإحصائيات ==========

class AdminStatisticsTab extends ConsumerWidget {
  const AdminStatisticsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 📈 بطاقات الإحصائيات الرئيسية
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              StatCard(
                title: 'إجمالي المستخدمين',
                value: '25,450',
                icon: Icons.people,
                color: Colors.blue,
                change: '+12% هذا الشهر',
              ),
              StatCard(
                title: 'مستخدمون نشطون',
                value: '8,230',
                icon: Icons.trending_up,
                color: Colors.green,
                change: '+5% اليوم',
              ),
              StatCard(
                title: 'الإيرادات الشهرية',
                value: '\$45,230',
                icon: Icons.monetization_on,
                color: Colors.amber,
                change: '+18% عن الشهر السابق',
              ),
              StatCard(
                title: 'معدل التحويل',
                value: '4.2%',
                icon: Icons.percent,
                color: Colors.purple,
                change: '+0.5% هذا الشهر',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 📊 الرسوم البيانية
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الإيرادات اليومية (آخر 30 يوم)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Text('📊 رسم بياني يتم استبدال ملخص بـ charts package'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 📋 المعلومات التفصيلية
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تفاصيل الأداء',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow('إجمالي مشاهدات الإعلانات', '1,245,320'),
                  _buildStatRow('إعلانات المكافآت المكتملة', '458,920'),
                  _buildStatRow('الاشتراكات النشطة', '3,450'),
                  _buildStatRow('معدل الاحتفاظ (D1)', '42.5%'),
                  _buildStatRow('معدل الاحتفاظ (D7)', '18.3%'),
                  _buildStatRow('متوسط جلسة اللعب', '22 دقيقة'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ========== التبويب 2: إدارة المستويات ==========

class AdminLevelsTab extends ConsumerStatefulWidget {
  const AdminLevelsTab({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminLevelsTab> createState() => _AdminLevelsTabState();
}

class _AdminLevelsTabState extends ConsumerState<AdminLevelsTab> {
  late TextEditingController _levelController;
  late TextEditingController _pointsController;

  @override
  void initState() {
    super.initState();
    _levelController = TextEditingController();
    _pointsController = TextEditingController();
  }

  @override
  void dispose() {
    _levelController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 📝 تحديث نقاط المستوى
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تحديث نقاط المستوى',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _levelController,
                    decoration: InputDecoration(
                      labelText: 'رقم المستوى',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pointsController,
                    decoration: InputDecoration(
                      labelText: 'النقاط الأساسية',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.stars),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _updateLevelPoints(),
                    icon: const Icon(Icons.save),
                    label: const Text('حفظ التغييرات'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 📋 قائمة المستويات
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'المستويات الموجودة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('levels')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final levels = snapshot.data!.docs;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: levels.length,
                        itemBuilder: (context, index) {
                          final level = levels[index];
                          return ListTile(
                            title: Text('المستوى ${level['levelNumber']}'),
                            subtitle: Text(
                              'النقاط: ${level['basePoints']}',
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: const Text('تعديل'),
                                  onTap: () => _editLevel(level),
                                ),
                                PopupMenuItem(
                                  child: const Text('حذف'),
                                  onTap: () => _deleteLevel(level.id),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateLevelPoints() {
    final levelNumber = int.tryParse(_levelController.text);
    final points = int.tryParse(_pointsController.text);

    if (levelNumber == null || points == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ الرجاء إدخال أرقام صحيحة')),
      );
      return;
    }

    FirebaseFirestore.instance
        .collection('levels')
        .doc('level_$levelNumber')
        .set({'basePoints': points}, SetOptions(merge: true))
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم تحديث المستوى بنجاح')),
      );
      _levelController.clear();
      _pointsController.clear();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ خطأ: $error')),
      );
    });
  }

  void _editLevel(DocumentSnapshot level) {
    _levelController.text = level['levelNumber'].toString();
    _pointsController.text = level['basePoints'].toString();
  }

  void _deleteLevel(String levelId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل تريد حذف هذا المستوى؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('levels')
                  .doc(levelId)
                  .delete();
              Navigator.pop(context);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ========== التبويب 3: إدارة الإيرادات ==========

class AdminRevenueTab extends ConsumerWidget {
  const AdminRevenueTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 💰 تحديث مكافآت الإعلانات
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تحديث مكافآت الإعلانات',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRewardField('إعلان المكافآت (Rewarded)', '50'),
                  _buildRewardField('الإعلانات الكاملة (Interstitial)', '0'),
                  _buildRewardField('مكافأة تسجيل الدخول اليومي', '100'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _updateAdRewards(),
                    icon: const Icon(Icons.save),
                    label: const Text('حفظ التغييرات'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 💳 إدارة أسعار الاشتراك
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'أسعار الاشتراك',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSubscriptionField('Premium شهري', '\$4.99'),
                  _buildSubscriptionField('Premium سنوي', '\$39.99'),
                  _buildSubscriptionField('خطة الدعم', '\$0.99'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _updateSubscriptionPrices(),
                    icon: const Icon(Icons.save),
                    label: const Text('حفظ التغييرات'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 📊 الإيرادات الشهرية
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ملخص الإيرادات',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRevenueRow('إيرادات الإعلانات', '\$12,450'),
                  _buildRevenueRow('إيرادات الاشتراكات', '\$28,300'),
                  _buildRevenueRow('المتجر داخل التطبيق', '\$4,480'),
                  const Divider(height: 24),
                  _buildRevenueRow('الإجمالي', '\$45,230', bold: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardField(String label, String defaultValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          prefixIcon: const Icon(Icons.card_giftcard),
        ),
        keyboardType: TextInputType.number,
        controller: TextEditingController(text: defaultValue),
      ),
    );
  }

  Widget _buildSubscriptionField(String label, String defaultValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          prefixIcon: const Icon(Icons.credit_card),
        ),
        controller: TextEditingController(text: defaultValue),
      ),
    );
  }

  Widget _buildRevenueRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }

  void _updateAdRewards() {}
  void _updateSubscriptionPrices() {}
}

// ========== التبويب 4: إدارة المستخدمين ==========

class AdminUsersTab extends ConsumerStatefulWidget {
  const AdminUsersTab({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends ConsumerState<AdminUsersTab> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔍 شريط البحث
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'ابحث عن مستخدم',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),

        // 👥 قائمة المستخدمين
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .orderBy('lastPlayedAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var users = snapshot.data!.docs;

              // تصفية البحث
              if (_searchController.text.isNotEmpty) {
                users = users
                    .where((user) =>
                        user['displayName']
                            .toString()
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase()) ||
                        user['email']
                            .toString()
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase()))
                    .toList();
              }

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return UserCard(
                    userId: user.id,
                    userName: user['displayName'] ?? 'Unknown',
                    email: user['email'] ?? 'N/A',
                    score: user['totalScore'] ?? 0,
                    isPremium: user['isPremium'] ?? false,
                    isBanned: user['banned'] ?? false,
                    onBan: () => _banUser(user.id),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _banUser(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حظر المستخدم'),
        content: const Text('اكتب سبب الحظر:'),
        actions: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'السبب',
            ),
            onChanged: (reason) {
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .update({
                'banned': true,
                'banReason': reason,
                'bannedAt': FieldValue.serverTimestamp(),
              });
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }
}

// ========== التبويب 5: إدارة السحب ==========

class AdminDrawTab extends ConsumerStatefulWidget {
  const AdminDrawTab({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminDrawTab> createState() => _AdminDrawTabState();
}

class _AdminDrawTabState extends ConsumerState<AdminDrawTab> {
  late TextEditingController _winnerCountController;

  @override
  void initState() {
    super.initState();
    _winnerCountController = TextEditingController(text: '5');
  }

  @override
  void dispose() {
    _winnerCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 🎟️ إجراء السحب
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'إجراء السحب',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'عدد الفائزين:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _winnerCountController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: const Icon(Icons.group),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _selectWinners(),
                    icon: const Icon(Icons.casino),
                    label: const Text('اختيار الفائزين'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 🏆 الفائزون السابقون
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الفائزون السابقون',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('draws')
                        .orderBy('drawnAt', descending: true)
                        .limit(5)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final draws = snapshot.data!.docs;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: draws.length,
                        itemBuilder: (context, index) {
                          final draw = draws[index];
                          return ListTile(
                            title: Text('سحب #${index + 1}'),
                            subtitle: Text(
                              'عدد الفائزين: ${(draw['winners'] as List).length}',
                            ),
                            trailing: const Icon(Icons.check_circle,
                                color: Colors.green),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectWinners() {
    final count = int.tryParse(_winnerCountController.text) ?? 5;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد السحب'),
        content: Text('هل تريد اختيار $count فائزين؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              // استدعاء Cloud Function
              FirebaseFunctions.instance
                  .httpsCallable('selectWinners')
                  .call({'count': count})
                  .then((result) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ تم اختيار $count فائزين بنجاح'),
                  ),
                );
                Navigator.pop(context);
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ خطأ: $error')),
                );
              });
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}

// ========== التبويب 6: الإعدادات ==========

class AdminSettingsTab extends ConsumerWidget {
  const AdminSettingsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ⚙️ إعدادات عامة
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الإعدادات العامة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('تفعيل الإعلانات'),
                    subtitle: const Text('السماح بعرض الإعلانات للمستخدمين'),
                    value: true,
                    onChanged: (value) {},
                  ),
                  SwitchListTile(
                    title: const Text('وضع الصيانة'),
                    subtitle: const Text('إيقاف التطبيق مؤقتاً للصيانة'),
                    value: false,
                    onChanged: (value) {},
                  ),
                  SwitchListTile(
                    title: const Text('تفعيل Multiplayer'),
                    subtitle: const Text('السماح باللعب الجماعي'),
                    value: false,
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 🔔 الإخطارات
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'إرسال إخطار عام',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'العنوان',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'المحتوى',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.send),
                    label: const Text('إرسال الإخطار'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 📊 البيانات والإحصائيات
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'البيانات',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('تحديث التصنيفات'),
                    subtitle: const Text('إعادة حساب ترتيب المستخدمين'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () => _updateLeaderboards(),
                  ),
                  ListTile(
                    title: const Text('تنظيف البيانات القديمة'),
                    subtitle: const Text('حذف البيانات المحفوظة مؤقتاً'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {},
                  ),
                  ListTile(
                    title: const Text('حفظ النسخة الاحتياطية'),
                    subtitle: const Text('تصدير جميع بيانات المستخدمين'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateLeaderboards() {}
}

// ========== عناصر مساعدة ==========

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String change;

  const StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.change,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              change,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final String userId;
  final String userName;
  final String email;
  final int score;
  final bool isPremium;
  final bool isBanned;
  final VoidCallback onBan;

  const UserCard({
    required this.userId,
    required this.userName,
    required this.email,
    required this.score,
    required this.isPremium,
    required this.isBanned,
    required this.onBan,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(userName[0]),
        ),
        title: Text(userName),
        subtitle: Text(email),
        trailing: Wrap(
          children: [
            if (isPremium)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Chip(
                  label: Text('Premium'),
                  backgroundColor: Colors.amber,
                ),
              ),
            if (isBanned)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Chip(
                  label: Text('محظور'),
                  backgroundColor: Colors.red,
                ),
              ),
          ],
        ),
        onTap: () => _showUserDetails(context),
      ),
    );
  }

  void _showUserDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(userName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('البريد الإلكتروني: $email'),
            Text('النقاط: $score'),
            Text('Premium: ${isPremium ? 'نعم' : 'لا'}'),
            Text('محظور: ${isBanned ? 'نعم' : 'لا'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          if (!isBanned)
            TextButton(
              onPressed: () {
                onBan();
                Navigator.pop(context);
              },
              child: const Text('حظر', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }
}

// ========== استيراد الحزم المطلوبة ==========
/*

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_firestore/firebase_firestore.dart';

*/
