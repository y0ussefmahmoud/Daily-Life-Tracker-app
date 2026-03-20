import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class GymScreen extends StatefulWidget {
  const GymScreen({super.key});

  @override
  State<GymScreen> createState() => _GymScreenState();
}

class _GymScreenState extends State<GymScreen> {
  final List<Map<String, dynamic>> _exercises = [
    {'name': 'ضغط', 'icon': Icons.fitness_center, 'sets': 0, 'target': 4},
    {'name': 'سكوات', 'icon': Icons.accessibility_new, 'sets': 0, 'target': 4},
    {'name': 'بلانك', 'icon': Icons.accessibility, 'sets': 0, 'target': 3},
    {'name': 'قفز', 'icon': Icons.directions_run, 'sets': 0, 'target': 3},
    {'name': 'تمارين بطن', 'icon': Icons.sports_gymnastics, 'sets': 0, 'target': 3},
  ];

  void _incrementSets(int index) {
    setState(() {
      if (_exercises[index]['sets'] < _exercises[index]['target']) {
        _exercises[index]['sets']++;
      }
    });
  }

  void _resetExercise(int index) {
    setState(() {
      _exercises[index]['sets'] = 0;
    });
  }

  void _resetAll() {
    setState(() {
      for (var exercise in _exercises) {
        exercise['sets'] = 0;
      }
    });
  }

  int get totalCompleted {
    return _exercises.fold(0, (sum, exercise) => sum + exercise['sets'] as int);
  }

  int get totalTarget {
    return _exercises.fold(0, (sum, exercise) => sum + exercise['target'] as int);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('الجيم والرياضة'),
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
            // Summary Card
            Container(
              padding: const EdgeInsets.all(20),
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
                  const Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'تدريب اليوم',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$totalCompleted / $totalTarget مجموعات',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: totalTarget > 0 ? totalCompleted / totalTarget : 0.0,
                    backgroundColor: Colors.white.withAlpha(77),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Exercise List
            Expanded(
              child: ListView.builder(
                itemCount: _exercises.length,
                itemBuilder: (context, index) {
                  final exercise = _exercises[index];
                  final progress = exercise['sets'] / exercise['target'];
                  final isCompleted = exercise['sets'] >= exercise['target'];
                  
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
                          // Exercise Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isCompleted ? AppColors.successColor : AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  exercise['icon'],
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exercise['name'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isCompleted ? AppColors.successColor : AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${exercise['sets']} / ${exercise['target']} مجموعات',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isCompleted ? AppColors.successColor : AppColors.gray600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isCompleted)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.successColor,
                                  size: 28,
                                ),
                            ],
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
                          const SizedBox(height: 16),
                          
                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: isCompleted ? null : () => _incrementSets(index),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'أضف مجموعة',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () => _resetExercise(index),
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
