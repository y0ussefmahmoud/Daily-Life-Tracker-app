// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: [https://y0ussef.com/](https://y0ussef.com/)
// - Whatsapp: [https://wa.me/Y0ussefmahmoud](https://wa.me/Y0ussefmahmoud)
// - Email: info@Youssef.com

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/backup_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Widget for manual backup and restore operations.
/// Provides export and restore functionality with loading states and error feedback.
class BackupRestoreCard extends StatelessWidget {
  const BackupRestoreCard({super.key});

  /// Handles export backup operation.
  Future<void> _handleExport(BuildContext context, BackupProvider provider) async {
    try {
      await provider.exportData();
      
      if (provider.lastExportedData != null && context.mounted) {
        await SharePlus.instance.share(
          ShareParams(
            text: provider.lastExportedData!,
            subject: 'Daily Life Tracker Backup',
          ),
        );
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup exported successfully')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  /// Handles restore backup operation.
  Future<void> _handleRestore(BuildContext context, BackupProvider provider) async {
    try {
      // Note: file_picker is disabled for Samsung A55 compatibility
      // This is a placeholder for future implementation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File picker not available in current version')),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BackupProvider>(
      builder: (context, provider, child) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.backup, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'Backup & Restore',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: provider.isExporting
                            ? null
                            : () => _handleExport(context, provider),
                        icon: provider.isExporting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.download),
                        label: Text(provider.isExporting ? 'Exporting...' : 'Export Backup'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: provider.isImporting
                            ? null
                            : () => _handleRestore(context, provider),
                        icon: provider.isImporting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.upload),
                        label: Text(provider.isImporting ? 'Restoring...' : 'Restore Backup'),
                      ),
                    ),
                  ],
                ),
                if (provider.error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.error!,
                            style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: provider.clearError,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
