import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  final List<Map<String, dynamic>> _meals = [
    {'name': 'الفطار', 'icon': Icons.breakfast_dining, 'completed': false, 'time': '7:00 ص'},
    {'name': 'الغداء', 'icon': Icons.lunch_dining, 'completed': false, 'time': '1:00 م'},
    {'name': 'العشاء', 'icon': Icons.dinner_dining, 'completed': false, 'time': '7:00 م'},
    {'name': 'وجبة خفيفة', 'icon': Icons.cookie, 'completed': false, 'time': '4:00 م'},
    {'name': 'شرب ماء', 'icon': Icons.water_drop, 'completed': false, 'time': 'طوال اليوم'},
  ];

  final List<Map<String, dynamic>> _waterIntake = [
    {'time': '7:00 ص', 'amount': 250, 'completed': false},
    {'time': '9:00 ص', 'amount': 250, 'completed': false},
    {'time': '11:00 ص', 'amount': 250, 'completed': false},
    {'time': '1:00 م', 'amount': 250, 'completed': false},
    {'time': '3:00 م', 'amount': 250, 'completed': false},
    {'time': '5:00 م', 'amount': 250, 'completed': false},
    {'time': '7:00 م', 'amount': 250, 'completed': false},
    {'time': '9:00 م', 'amount': 250, 'completed': false},
  ];

  void _toggleMeal(int index) {
    setState(() {
      _meals[index]['completed'] = !_meals[index]['completed'];
    });
  }

  void _toggleWater(int index) {
    setState(() {
      _waterIntake[index]['completed'] = !_waterIntake[index]['completed'];
    });
  }

  void _resetAll() {
    setState(() {
      for (var meal in _meals) {
        meal['completed'] = false;
      }
      for (var water in _waterIntake) {
        water['completed'] = false;
      }
    });
  }

  int get completedMeals {
    return _meals.where((meal) => meal['completed']).length;
  }

  int get completedWater {
    return _waterIntake.where((water) => water['completed']).length;
  }

  int get totalWaterIntake {
    return _waterIntake
        .where((water) => water['completed'])
        .fold(0, (sum, water) => sum + water['amount'] as int);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('تتبع الأكل'),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Icon(
                        Icons.restaurant,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$completedMeals / ${_meals.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'وجبات',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(
                        Icons.water_drop,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$totalWaterIntake مل',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$completedWater / ${_waterIntake.length} أكواب',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Tabs
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        indicatorColor: AppColors.primaryColor,
                        labelColor: AppColors.primaryColor,
                        unselectedLabelColor: AppColors.gray600,
                        tabs: const [
                          Tab(text: 'الوجبات'),
                          Tab(text: 'الماء'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Meals Tab
                          ListView.builder(
                            itemCount: _meals.length,
                            itemBuilder: (context, index) {
                              final meal = _meals[index];
                              final isCompleted = meal['completed'];
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isCompleted ? AppColors.successColor : AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      meal['icon'],
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  title: Text(
                                    meal['name'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isCompleted ? AppColors.successColor : AppColors.textPrimary,
                                    ),
                                  ),
                                  subtitle: Text(
                                    meal['time'],
                                    style: TextStyle(
                                      color: isCompleted ? AppColors.successColor : AppColors.gray600,
                                    ),
                                  ),
                                  trailing: Switch(
                                    value: isCompleted,
                                    onChanged: (value) => _toggleMeal(index),
                                    activeThumbColor: AppColors.successColor,
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          // Water Tab
                          ListView.builder(
                            itemCount: _waterIntake.length,
                            itemBuilder: (context, index) {
                              final water = _waterIntake[index];
                              final isCompleted = water['completed'];
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isCompleted ? AppColors.successColor : AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.water_drop,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  title: Text(
                                    '${water['amount']} مل',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isCompleted ? AppColors.successColor : AppColors.textPrimary,
                                    ),
                                  ),
                                  subtitle: Text(
                                    water['time'],
                                    style: TextStyle(
                                      color: isCompleted ? AppColors.successColor : AppColors.gray600,
                                    ),
                                  ),
                                  trailing: Switch(
                                    value: isCompleted,
                                    onChanged: (value) => _toggleWater(index),
                                    activeThumbColor: AppColors.successColor,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
