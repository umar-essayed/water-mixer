// lib/config/routes/app_routes.dart
// نظام التوجيه الكامل - نسخة صحيحة 100% (بدون أخطاء)

import 'package:flutter/material.dart';

class AppRoutes {
  // المسارات
  static const String splash = '/';
  static const String menu = '/menu';
  static const String game = '/game';
  static const String levelSelection = '/level-selection';
  static const String leaderboard = '/leaderboard';
  static const String shop = '/shop';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String subscriptions = '/subscriptions';
  static const String adminDashboard = '/admin';
  static const String achievements = '/achievements';
  static const String statistics = '/statistics';

  static final RouteObserver<PageRoute> observer = RouteObserver<PageRoute>();

  // توليد المسارات - استخدام if-else بدل switch
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name ?? '/';
    final arguments = settings.arguments as Map<String, dynamic>?;

    // الشاشة الافتراضية
    Widget page = const ErrorScreen();

    if (routeName == '/') {
      page = const SplashScreen();
    } else if (routeName == '/menu') {
      page = const MenuScreen();
    } else if (routeName == '/game') {
      final levelNumber = arguments?['levelNumber'] as int? ?? 1;
      page = GameScreen(levelNumber: levelNumber);
    } else if (routeName == '/level-selection') {
      page = const LevelSelectionScreen();
    } else if (routeName == '/leaderboard') {
      page = const LeaderboardScreen();
    } else if (routeName == '/shop') {
      page = const ShopScreen();
    } else if (routeName == '/settings') {
      page = const SettingsScreen();
    } else if (routeName == '/profile') {
      page = const ProfileScreen();
    } else if (routeName == '/subscriptions') {
      final userId = arguments?['userId'] as String? ?? '';
      final email = arguments?['email'] as String? ?? '';
      page = SubscriptionScreen(userId: userId, email: email);
    } else if (routeName == '/admin') {
      page = const AdminDashboard();
    } else if (routeName == '/achievements') {
      page = const AchievementsScreen();
    } else if (routeName == '/statistics') {
      page = const StatisticsScreen();
    }

    return MaterialPageRoute(builder: (_) => page);
  }
}

// ============ شاشة الخطأ ============
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('خطأ')),
      body: const Center(child: Text('المسار غير موجود')),
    );
  }
}

// ============ شاشة البداية ============
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.menu);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '💧 Water Mixer',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// ============ شاشة القائمة الرئيسية ============
class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '💧 Water Mixer Puzzle',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 48),
              _buildButton(context, 'ابدأ اللعبة', Icons.play_arrow, AppRoutes.levelSelection),
              const SizedBox(height: 16),
              _buildButton(context, 'التصنيفات', Icons.leaderboard, AppRoutes.leaderboard),
              const SizedBox(height: 16),
              _buildButton(context, 'المتجر', Icons.shopping_cart, AppRoutes.shop),
              const SizedBox(height: 16),
              _buildButton(context, 'الإعدادات', Icons.settings, AppRoutes.settings),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String label, IconData icon, String route) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.pushNamed(context, route),
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[600],
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      ),
    );
  }
}

// ============ شاشة اللعبة ============
class GameScreen extends StatelessWidget {
  final int levelNumber;

  const GameScreen({required this.levelNumber, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: Text('المستوى $levelNumber'),
        backgroundColor: Colors.blue[600],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'لعبة المستوى $levelNumber',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Container(
              width: 300,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: const Center(child: Text('محتوى اللعبة هنا')),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('العودة'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ اختيار المستوى ============
class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختيار المستوى'),
        backgroundColor: Colors.blue[600],
      ),
      backgroundColor: Colors.blue[50],
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: 50,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.game,
                arguments: {'levelNumber': index + 1},
              );
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[400]!, Colors.blue[600]!],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============ التصنيفات ============
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التصنيفات'),
        backgroundColor: Colors.blue[600],
      ),
      backgroundColor: Colors.blue[50],
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[600],
                child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
              ),
              title: Text('اللاعب ${index + 1}'),
              trailing: Text('${1000 - (index * 100)} نقطة', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }
}

// ============ المتجر ============
class ShopScreen extends StatelessWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المتجر'),
        backgroundColor: Colors.blue[600],
      ),
      backgroundColor: Colors.blue[50],
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildCard('تلميح', 'مساعدة', '\$0.99', Colors.yellow, () {}),
          const SizedBox(height: 8),
          _buildCard('حركات', '+5 حركات', '\$1.99', Colors.orange, () {}),
          const SizedBox(height: 8),
          _buildCard(
            'Premium',
            'جميع المميزات',
            '\$4.99',
            Colors.purple,
                () => Navigator.pushNamed(context, AppRoutes.subscriptions),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String subtitle, String price, Color color, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.shopping_bag, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: ElevatedButton(onPressed: onTap, child: Text(price)),
      ),
    );
  }
}

// ============ الإعدادات ============
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool musicEnabled = true;
  bool soundEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        backgroundColor: Colors.blue[600],
      ),
      backgroundColor: Colors.blue[50],
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('🎵 الموسيقى'),
            value: musicEnabled,
            onChanged: (value) => setState(() => musicEnabled = value),
          ),
          SwitchListTile(
            title: const Text('🔊 المؤثرات الصوتية'),
            value: soundEnabled,
            onChanged: (value) => setState(() => soundEnabled = value),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('لوحة تحكم الأدمن'),
            onTap: () => Navigator.pushNamed(context, AppRoutes.adminDashboard),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('عن التطبيق'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Water Mixer Puzzle',
                applicationVersion: '1.0.0',
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============ الملف الشخصي ============
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: Colors.blue[600],
      ),
      backgroundColor: Colors.blue[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue[300],
              child: const Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text('لاعب جديد', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('النقاط: 0', style: TextStyle(fontSize: 16, color: Colors.blue[600])),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.subscriptions),
              icon: const Icon(Icons.star),
              label: const Text('Premium'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ الاشتراكات ============
class SubscriptionScreen extends StatelessWidget {
  final String userId;
  final String email;

  const SubscriptionScreen({required this.userId, required this.email, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الاشتراكات'),
        backgroundColor: Colors.blue[600],
      ),
      backgroundColor: Colors.blue[50],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPlan('Premium شهري', '\$4.99', () {}),
          const SizedBox(height: 16),
          _buildPlan('Premium سنوي', '\$39.99', () {}),
        ],
      ),
    );
  }

  Widget _buildPlan(String title, String price, VoidCallback onTap) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(price, style: TextStyle(fontSize: 24, color: Colors.blue[600])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
              child: const Text('اشترك الآن'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ لوحة تحكم الأدمن ============
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم الأدمن'),
        backgroundColor: Colors.red[600],
      ),
      backgroundColor: Colors.grey[100],
      body: _buildContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedTab,
        onTap: (index) => setState(() => selectedTab = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'إحصائيات'),
          BottomNavigationBarItem(icon: Icon(Icons.layers), label: 'مستويات'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'مستخدمون'),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (selectedTab == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStat('المستخدمين النشطين', '1,234'),
            const SizedBox(height: 16),
            _buildStat('الإيرادات', '\$5,678'),
          ],
        ),
      );
    } else if (selectedTab == 1) {
      return ListView(children: [
        ListTile(title: const Text('المستوى 1'), subtitle: const Text('سهل')),
        ListTile(title: const Text('المستوى 2'), subtitle: const Text('متوسط')),
      ]);
    } else {
      return ListView(children: [
        ListTile(title: const Text('اللاعب 1'), trailing: const Icon(Icons.check_circle)),
        ListTile(title: const Text('اللاعب 2'), trailing: const Icon(Icons.check_circle)),
      ]);
    }
  }

  Widget _buildStat(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(title), Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))],
        ),
      ),
    );
  }
}

// ============ الإنجازات ============
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإنجازات')),
      body: ListView(children: const [
        ListTile(title: Text('🎮 البداية الأولى'), subtitle: Text('أكمل اللعبة الأولى')),
        ListTile(title: Text('⭐ النجم الصاعد'), subtitle: Text('احصل على 3 نجوم')),
      ]),
    );
  }
}

// ============ الإحصائيات ============
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإحصائيات')),
      body: ListView(children: const [
        ListTile(title: Text('إجمالي النقاط'), trailing: Text('0')),
        ListTile(title: Text('المستويات المكتملة'), trailing: Text('0')),
        ListTile(title: Text('أفضل درجة'), trailing: Text('0')),
      ]),
    );
  }
}