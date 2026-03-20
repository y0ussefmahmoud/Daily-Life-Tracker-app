// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';
import '../providers/water_provider.dart';
import '../providers/achievements_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/profile_provider.dart';
import '../utils/constants.dart';

class SimpleHomeScreen extends StatelessWidget {
  const SimpleHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Life Tracker'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildFeatureCard(
              context,
              'المهام',
              Icons.task,
              AppColors.primaryColor,
              () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('المهام - قيد التطوير')),
              ),
            ),
            _buildFeatureCard(
              context,
              'المشاريع',
              Icons.work,
              AppColors.warningColor,
              () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('المشاريع - قيد التطوير')),
              ),
            ),
            _buildFeatureCard(
              context,
              'المياه',
              Icons.water_drop,
              AppColors.infoColor,
              () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Water Tracker - Coming Soon!')),
              ),
            ),
            _buildFeatureCard(
              context,
              'الإحصائيات',
              Icons.bar_chart,
              AppColors.successColor,
              () => Scaffold(
                appBar: AppBar(title: const Text('الإحصائيات')),
                body: const Center(child: Text('إحصائيات قيد التطوير')),
              ),
            ),
            _buildFeatureCard(
              context,
              'الملف الشخصي',
              Icons.person,
              AppColors.gray600,
              () => Scaffold(
                appBar: AppBar(title: const Text('الملف الشخصي')),
                body: const Center(child: Text('الملف الشخصي قيد التطوير')),
              ),
            ),
            _buildFeatureCard(
              context,
              'نسخ احتياطي',
              Icons.backup,
              AppColors.infoColor,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('قريباً: النسخ الاحتياطي')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
