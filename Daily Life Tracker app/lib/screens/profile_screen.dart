// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: [https://y0ussef.com/](https://y0ussef.com/)
// - Whatsapp: [https://wa.me/Y0ussefmahmoud](https://wa.me/Y0ussefmahmoud)
// - Email: info@Youssef.com

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/backup_provider.dart';
import '../widgets/backup_restore_card.dart';
import '../services/localization_service.dart';
import '../utils/constants.dart';
import '../utils/responsive_breakpoints.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    await profileProvider.loadUserData();
    _nameController.text = profileProvider.userName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).profile),
            Text(
              'v${AppStrings.appVersion}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: Consumer2<ProfileProvider, SettingsProvider>(
        builder: (context, profileProvider, settingsProvider, child) {
          final l10n = AppLocalizations.of(context);
          return LayoutBuilder(
            builder: (context, constraints) {
              final padding = ResponsiveBreakpoints.getScreenPadding(context);
              final isMobile = ResponsiveBreakpoints.isMobile(context);
              
              return SingleChildScrollView(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Profile Header Section
                  _buildProfileHeader(profileProvider, l10n, isMobile),
                  
                  SizedBox(height: isMobile ? 24 : 32),
                  
                  // User Info Section
                  _buildUserInfoSection(profileProvider, l10n),
                  
                  SizedBox(height: isMobile ? 24 : 32),
                  
                  // App Settings Section
                  _buildAppSettingsSection(settingsProvider, l10n),
                  
                  SizedBox(height: isMobile ? 24 : 32),
                  
                  // Backup & Restore Section
                  _buildBackupRestoreSection(),
                  
                  SizedBox(height: isMobile ? 24 : 32),
                  
                  // About Section
                  _buildAboutSection(l10n),
                ],
              ),
            );
          },
        );
        },
      ),
    );
  }

  Widget _buildProfileHeader(ProfileProvider profileProvider, AppLocalizations l10n, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryColor, AppColors.primaryColor.withAlpha(204)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withAlpha(77),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Image
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: isMobile ? 60 : 80,
                  backgroundColor: Colors.white,
                  backgroundImage: profileProvider.userImage != null
                      ? FileImage(profileProvider.userImage!)
                      : null,
                  child: profileProvider.userImage == null
                      ? Icon(
                          Icons.person,
                          size: isMobile ? 60 : 80,
                          color: AppColors.primaryColor,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(77),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: isMobile ? 16 : 24),
          
          // User Name
          if (_isEditing)
            TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveBreakpoints.getFontSize(context, 24),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: l10n.locale.languageCode == 'ar' ? 'اكتب اسمك' : 'Enter your name',
                hintStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white70),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            )
          else
            Text(
              profileProvider.userName.isEmpty 
                  ? (l10n.locale.languageCode == 'ar' ? 'مستخدم جديد' : 'New User') 
                  : profileProvider.userName,
              style: TextStyle(
                fontSize: ResponsiveBreakpoints.getFontSize(context, 24),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection(ProfileProvider profileProvider, AppLocalizations l10n) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.locale.languageCode == 'ar' ? 'معلومات المستخدم' : 'User Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(l10n.userName, profileProvider.userName.isEmpty 
                ? (l10n.locale.languageCode == 'ar' ? 'غير محدد' : 'Not set') 
                : profileProvider.userName),
            _buildInfoRow(l10n.locale.languageCode == 'ar' ? 'البريد الإلكتروني' : 'Email', 'user@example.com'),
            _buildInfoRow(l10n.locale.languageCode == 'ar' ? 'تاريخ الانضمام' : 'Join Date', _formatDate(profileProvider.joinDate)),
            _buildInfoRow(l10n.level, '${l10n.level} ${profileProvider.level}'),
            _buildInfoRow(l10n.points, '${profileProvider.points} ${l10n.points}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsSection(SettingsProvider settingsProvider, AppLocalizations l10n) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingsTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Theme Toggle
            _buildSettingTile(
              l10n.darkMode,
              l10n.locale.languageCode == 'ar' ? 'تغيير مظهر التطبيق' : 'Change app theme',
              settingsProvider.isDarkMode,
              (value) => settingsProvider.toggleDarkMode(),
              Icons.dark_mode,
            ),
            
            // Language Settings
            _buildLanguageTile(settingsProvider, l10n),
            
            // Notifications
            _buildSettingTile(
              l10n.notifications,
              l10n.locale.languageCode == 'ar' ? 'تفعيل الإشعارات' : 'Enable notifications',
              settingsProvider.profileNotificationsEnabled,
              (value) => settingsProvider.toggleNotifications(),
              Icons.notifications,
            ),
            
            // Sound Effects
            _buildSettingTile(
              l10n.sound,
              l10n.locale.languageCode == 'ar' ? 'تفعيل الأصوات' : 'Enable sounds',
              settingsProvider.soundEnabled,
              (value) => settingsProvider.toggleSound(),
              Icons.volume_up,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupRestoreSection() {
    return ChangeNotifierProvider(
      create: (_) => BackupProvider(),
      child: const BackupRestoreCard(),
    );
  }

  Widget _buildSettingTile(String title, String subtitle, bool value, Function(bool) onChanged, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildLanguageTile(SettingsProvider settingsProvider, AppLocalizations l10n) {
    return ListTile(
      leading: const Icon(Icons.language, color: AppColors.primaryColor),
      title: Text(l10n.language),
      subtitle: Text(settingsProvider.currentLanguage == 'ar' ? l10n.arabic : l10n.english),
      trailing: DropdownButton<String>(
        value: settingsProvider.currentLanguage,
        onChanged: (String? newValue) {
          if (newValue != null) {
            settingsProvider.changeLanguage(newValue);
          }
        },
        items: [
          DropdownMenuItem(value: 'ar', child: Text(l10n.arabic)),
          DropdownMenuItem(value: 'en', child: Text(l10n.english)),
        ],
      ),
    );
  }

  Widget _buildAboutSection(AppLocalizations l10n) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.about,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(l10n.version, AppStrings.appVersion),
            _buildInfoRow(l10n.developer, AppStrings.developerName),
            _buildInfoRow(l10n.lastUpdate, AppStrings.lastUpdate),
            _buildInfoRow(l10n.locale.languageCode == 'ar' ? 'حالة البناء' : 'Build Status', '🟢 ${l10n.locale.languageCode == 'ar' ? 'مستقر' : 'Stable'}'),
            
            const SizedBox(height: 16),
            
            // Dynamic Version Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryColor.withAlpha(77),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.version,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.locale.languageCode == 'ar'
                        ? 'تم تطوير هذا التطبيق بواسطة ${AppStrings.developerName}\nالإصدار الحالي: ${AppStrings.appVersion}\nآخر تحديث: ${AppStrings.lastUpdate}'
                        : 'This app was developed by ${AppStrings.developerName}\nCurrent version: ${AppStrings.appVersion}\nLast update: ${AppStrings.lastUpdate}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showUpdateDialog,
                    icon: const Icon(Icons.update),
                    label: Text(l10n.locale.languageCode == 'ar' ? 'التحقق من التحديثات' : 'Check for updates'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showFeedbackDialog,
                    icon: const Icon(Icons.feedback),
                    label: const Text('إرسال ملاحظات'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleEdit() async {
    if (_isEditing) {
      // Save changes
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      await profileProvider.updateUserName(_nameController.text);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ التغييرات'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    }
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _pickImage() async {
    // TODO: Implement image picker
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('سيتم إضافة اختيار الصور قريباً'),
          backgroundColor: AppColors.infoColor,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.system_update,
              color: AppColors.primaryColor,
            ),
            const SizedBox(width: 8),
            const Text('التحقق من التحديثات'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('أنت تستخدم أحدث إصدار من التطبيق.'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.successColor.withAlpha(26),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.successColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'محدث: ${AppStrings.appVersion}',
                    style: TextStyle(
                      color: AppColors.successColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'المطور: ${AppStrings.developerName}\nتاريخ التحديث: ${AppStrings.lastUpdate}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.feedback,
              color: AppColors.secondaryColor,
            ),
            const SizedBox(width: 8),
            const Text('إرسال ملاحظات'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('شكراً لاستخدامك تطبيق ${AppStrings.appName}!'),
            const SizedBox(height: 12),
            Text(
              'يمكنك إرسال ملاحظاتك واقتراحاتك إلى المطور:\n\n📧 المطور: ${AppStrings.developerName}\n📱 الإصدار: ${AppStrings.appVersion}\n📅 تاريخ التحديث: ${AppStrings.lastUpdate}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.infoColor.withAlpha(26),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: AppColors.infoColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'نقدر ملاحظاتك!',
                    style: TextStyle(
                      color: AppColors.infoColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }
}
