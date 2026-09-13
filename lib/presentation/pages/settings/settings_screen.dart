// lib/presentation/pages/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:water_mixer_new/core/local_storage/game_storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool sound = true;
  bool haptic = true;

  @override
  void initState() {
    super.initState();
    sound = GameStorage.isSoundEnabled();
    haptic = GameStorage.isHapticEnabled();
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('إعادة تعيين التقدم', style: TextStyle(color: Colors.white)),
        content: const Text(
          'هل أنت متأكد من رغبتك في مسح كافة النجوم والمستويات المكتملة وبدء اللعبة من جديد؟',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              await GameStorage.resetAllData();
              if (mounted) {
                Navigator.pop(ctx);
                setState(() {
                  sound = GameStorage.isSoundEnabled();
                  haptic = GameStorage.isHapticEnabled();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تمت إعادة تعيين التقدم بنجاح')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('نعم، إعادة ضبط'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('الإعدادات', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up, color: Colors.amber),
                  title: const Text('المؤثرات الصوتية', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('أصوات صب الماء واكتمال الأنابيب', style: TextStyle(color: Colors.white60)),
                  value: sound,
                  activeColor: Colors.amber,
                  onChanged: (val) async {
                    await GameStorage.setSoundEnabled(val);
                    setState(() => sound = val);
                  },
                ),
                const Divider(color: Colors.white12),
                SwitchListTile(
                  secondary: const Icon(Icons.vibration, color: Colors.cyanAccent),
                  title: const Text('الاهتزاز التفاعلي (Haptic)', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('اهتزاز خفيف مريح عند الصب والتفاعل', style: TextStyle(color: Colors.white60)),
                  value: haptic,
                  activeColor: Colors.cyanAccent,
                  onChanged: (val) async {
                    await GameStorage.setHapticEnabled(val);
                    setState(() => haptic = val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline, color: Colors.greenAccent),
                  title: const Text('كيفية اللعب وقواعد الألغاز', style: TextStyle(color: Colors.white)),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF1E293B),
                        title: const Text('قواعد اللعبة', style: TextStyle(color: Colors.white)),
                        content: const SingleChildScrollView(
                          child: Text(
                            '• الهدف: فرز الألوان بحيث يحتوي كل أنبوب على لون واحد موحد.\n\n'
                            '• اضغط على أنبوب لتحديده، ثم اضغط على أنبوب آخر للصب.\n\n'
                            '• لا يمكن الصب إلا إذا كان لون السائل العلوي متطابقاً، أو إذا كان الأنبوب الهدف فارغاً.\n\n'
                            '• السوائل المجهولة (?) ينكشف لونها بعد صب السائل الذي يعلوها.\n\n'
                            '• الأنابيب المقفلة تُفتح عند إكمال أي أنبوب آخر.\n\n'
                            '• أنابيب القنابل تتطلب فرزها قبل انتهاء عداد الحركات!',
                            style: TextStyle(color: Colors.white70, height: 1.5),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('حسناً'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(color: Colors.white12),
                ListTile(
                  leading: const Icon(Icons.restore, color: Colors.redAccent),
                  title: const Text('إعادة تعيين التقدم', style: TextStyle(color: Colors.redAccent)),
                  onTap: _confirmReset,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
