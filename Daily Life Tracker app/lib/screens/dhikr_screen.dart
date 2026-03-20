import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DhikrScreen extends StatefulWidget {
  const DhikrScreen({super.key});

  @override
  State<DhikrScreen> createState() => _DhikrScreenState();
}

class _DhikrScreenState extends State<DhikrScreen> {
  final List<Map<String, dynamic>> _dhikrList = [
    {'text': 'سبحان الله', 'count': 0, 'target': 33},
    {'text': 'الحمد لله', 'count': 0, 'target': 33},
    {'text': 'الله أكبر', 'count': 0, 'target': 33},
    {'text': 'لا إله إلا الله', 'count': 0, 'target': 10},
    {'text': 'اللهم صل على محمد', 'count': 0, 'target': 10},
    {'text': 'أستغفر الله', 'count': 0, 'target': 100},
  ];

  void _incrementCount(int index) {
    setState(() {
      if (_dhikrList[index]['count'] < _dhikrList[index]['target']) {
        _dhikrList[index]['count']++;
      }
    });
  }

  void _resetCount(int index) {
    setState(() {
      _dhikrList[index]['count'] = 0;
    });
  }

  void _resetAll() {
    setState(() {
      for (var item in _dhikrList) {
        item['count'] = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('الأذكار'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _resetAll,
            icon: const Icon(Icons.refresh),
            tooltip: 'إعادة تعيين الكل',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.primaryColor.withAlpha(204)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_stories,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'أذكار اليوم',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Dhikr List
            Expanded(
              child: ListView.builder(
                itemCount: _dhikrList.length,
                itemBuilder: (context, index) {
                  final dhikr = _dhikrList[index];
                  final progress = dhikr['count'] / dhikr['target'];
                  final isCompleted = dhikr['count'] >= dhikr['target'];
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCompleted ? AppColors.successColor : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Dhikr Text
                          Text(
                            dhikr['text'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isCompleted ? AppColors.successColor : AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          
                          // Progress Bar
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.gray300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isCompleted ? AppColors.successColor : AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Count and Target
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${dhikr['count']} / ${dhikr['target']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isCompleted ? AppColors.successColor : AppColors.textPrimary,
                                ),
                              ),
                              if (isCompleted)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.successColor,
                                  size: 20,
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: isCompleted ? null : () => _incrementCount(index),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'تسبيح',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () => _resetCount(index),
                                icon: const Icon(Icons.refresh),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.gray200,
                                  foregroundColor: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
