// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: [https://y0ussef.com/](https://y0ussef.com/)
// - Whatsapp: [https://wa.me/Y0ussefmahmoud](https://wa.me/Y0ussefmahmoud)
// - Email: info@Youssef.com

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LocalizationService {
  static LocalizationService? _instance;
  static LocalizationService get instance => _instance ??= LocalizationService._();
  
  LocalizationService._();

  Map<String, String>? _arTranslations;
  Map<String, String>? _enTranslations;

  Future<void> load() async {
    try {
      final arJson = await rootBundle.loadString('lib/l10n/app_ar.arb');
      final enJson = await rootBundle.loadString('lib/l10n/app_en.arb');
      
      final arDynamic = json.decode(arJson) as Map<String, dynamic>;
      final enDynamic = json.decode(enJson) as Map<String, dynamic>;
      
      _arTranslations = arDynamic.map((key, value) => MapEntry(key, value.toString()));
      _enTranslations = enDynamic.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      debugPrint('Error loading translations: $e');
    }
  }

  String translate(String key, Locale locale) {
    final translations = locale.languageCode == 'ar' ? _arTranslations : _enTranslations;
    return translations?[key] ?? key;
  }

  static String of(BuildContext context, String key) {
    final locale = Localizations.localeOf(context);
    return instance.translate(key, locale);
  }
}

class AppLocalizations {
  final Locale locale;
  final Map<String, String> _translations;

  AppLocalizations(this.locale, this._translations);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String get appName => _translations['appName'] ?? 'Daily Life Tracker';
  String get home => _translations['home'] ?? 'Home';
  String get tasks => _translations['tasks'] ?? 'Tasks';
  String get projects => _translations['projects'] ?? 'Projects';
  String get statistics => _translations['statistics'] ?? 'Statistics';
  String get achievements => _translations['achievements'] ?? 'Achievements';
  String get prayers => _translations['prayers'] ?? 'Prayers';
  String get dhikr => _translations['dhikr'] ?? 'Dhikr';
  String get gym => _translations['gym'] ?? 'Gym';
  String get food => _translations['food'] ?? 'Food';
  String get water => _translations['water'] ?? 'Water';
  String get settings => _translations['settings'] ?? 'Settings';
  String get profile => _translations['profile'] ?? 'Profile';
  String get editProfile => _translations['editProfile'] ?? 'Edit Profile';
  String get userName => _translations['userName'] ?? 'User Name';
  String get save => _translations['save'] ?? 'Save';
  String get cancel => _translations['cancel'] ?? 'Cancel';
  String get success => _translations['success'] ?? 'Success';
  String get error => _translations['error'] ?? 'Error';
  String get loading => _translations['loading'] ?? 'Loading...';
  String get noData => _translations['noData'] ?? 'No data available';
  String get addTask => _translations['addTask'] ?? 'Add Task';
  String get taskTitle => _translations['taskTitle'] ?? 'Task Title';
  String get taskDescription => _translations['taskDescription'] ?? 'Task Description';
  String get priority => _translations['priority'] ?? 'Priority';
  String get high => _translations['high'] ?? 'High';
  String get medium => _translations['medium'] ?? 'Medium';
  String get low => _translations['low'] ?? 'Low';
  String get status => _translations['status'] ?? 'Status';
  String get todo => _translations['todo'] ?? 'To Do';
  String get inProgress => _translations['inProgress'] ?? 'In Progress';
  String get done => _translations['done'] ?? 'Done';
  String get blocked => _translations['blocked'] ?? 'Blocked';
  String get delete => _translations['delete'] ?? 'Delete';
  String get edit => _translations['edit'] ?? 'Edit';
  String get complete => _translations['complete'] ?? 'Complete';
  String get incomplete => _translations['incomplete'] ?? 'Incomplete';
  String get addProject => _translations['addProject'] ?? 'Add Project';
  String get projectName => _translations['projectName'] ?? 'Project Name';
  String get projectDescription => _translations['projectDescription'] ?? 'Project Description';
  String get active => _translations['active'] ?? 'Active';
  String get paused => _translations['paused'] ?? 'Paused';
  String get completed => _translations['completed'] ?? 'Completed';
  String get statisticsTitle => _translations['statisticsTitle'] ?? 'Statistics';
  String get totalTasks => _translations['totalTasks'] ?? 'Total Tasks';
  String get completedTasks => _translations['completedTasks'] ?? 'Completed Tasks';
  String get activeProjects => _translations['activeProjects'] ?? 'Active Projects';
  String get achievementsTitle => _translations['achievementsTitle'] ?? 'Achievements';
  String get badges => _translations['badges'] ?? 'Badges';
  String get points => _translations['points'] ?? 'Points';
  String get level => _translations['level'] ?? 'Level';
  String get prayersTitle => _translations['prayersTitle'] ?? 'Daily Prayers';
  String get fajr => _translations['fajr'] ?? 'Fajr';
  String get dhuhr => _translations['dhuhr'] ?? 'Dhuhr';
  String get asr => _translations['asr'] ?? 'Asr';
  String get maghrib => _translations['maghrib'] ?? 'Maghrib';
  String get isha => _translations['isha'] ?? 'Isha';
  String get prayed => _translations['prayed'] ?? 'Prayed';
  String get notPrayed => _translations['notPrayed'] ?? 'Not Prayed';
  String get dhikrTitle => _translations['dhikrTitle'] ?? 'Dhikr';
  String get morningDhikr => _translations['morningDhikr'] ?? 'Morning Dhikr';
  String get eveningDhikr => _translations['eveningDhikr'] ?? 'Evening Dhikr';
  String get read => _translations['read'] ?? 'Read';
  String get notRead => _translations['notRead'] ?? 'Not Read';
  String get gymTitle => _translations['gymTitle'] ?? 'Gym Exercises';
  String get addExercise => _translations['addExercise'] ?? 'Add Exercise';
  String get exerciseName => _translations['exerciseName'] ?? 'Exercise Name';
  String get sets => _translations['sets'] ?? 'Sets';
  String get reps => _translations['reps'] ?? 'Reps';
  String get weight => _translations['weight'] ?? 'Weight';
  String get duration => _translations['duration'] ?? 'Duration';
  String get foodTitle => _translations['foodTitle'] ?? 'Food Tracking';
  String get addMeal => _translations['addMeal'] ?? 'Add Meal';
  String get mealName => _translations['mealName'] ?? 'Meal Name';
  String get calories => _translations['calories'] ?? 'Calories';
  String get protein => _translations['protein'] ?? 'Protein';
  String get carbs => _translations['carbs'] ?? 'Carbs';
  String get fat => _translations['fat'] ?? 'Fat';
  String get waterTitle => _translations['waterTitle'] ?? 'Water Tracking';
  String get drinkWater => _translations['drinkWater'] ?? 'Drink Water';
  String get waterGoal => _translations['waterGoal'] ?? 'Water Goal';
  String get currentWater => _translations['currentWater'] ?? 'Current Water';
  String get ml => _translations['ml'] ?? 'ml';
  String get settingsTitle => _translations['settingsTitle'] ?? 'Settings';
  String get notifications => _translations['notifications'] ?? 'Notifications';
  String get sound => _translations['sound'] ?? 'Sound';
  String get vibration => _translations['vibration'] ?? 'Vibration';
  String get language => _translations['language'] ?? 'Language';
  String get theme => _translations['theme'] ?? 'Theme';
  String get lightMode => _translations['lightMode'] ?? 'Light';
  String get darkMode => _translations['darkMode'] ?? 'Dark';
  String get arabic => _translations['arabic'] ?? 'العربية';
  String get english => _translations['english'] ?? 'English';
  String get about => _translations['about'] ?? 'About';
  String get version => _translations['version'] ?? 'Version';
  String get buildNumber => _translations['buildNumber'] ?? 'Build Number';
  String get developer => _translations['developer'] ?? 'Developer';
  String get lastUpdate => _translations['lastUpdate'] ?? 'Last Update';
  String get help => _translations['help'] ?? 'Help';
  String get feedback => _translations['feedback'] ?? 'Feedback';
  String get rateApp => _translations['rateApp'] ?? 'Rate App';
  String get shareApp => _translations['shareApp'] ?? 'Share App';
  String get logout => _translations['logout'] ?? 'Logout';
  String get confirmDelete => _translations['confirmDelete'] ?? 'Confirm Delete';
  String get deleteConfirmation => _translations['deleteConfirmation'] ?? 'Are you sure you want to delete this item?';
  String get yes => _translations['yes'] ?? 'Yes';
  String get no => _translations['no'] ?? 'No';
  String get ok => _translations['ok'] ?? 'OK';
  String get retry => _translations['retry'] ?? 'Retry';
  String get refresh => _translations['refresh'] ?? 'Refresh';
  String get search => _translations['search'] ?? 'Search';
  String get filter => _translations['filter'] ?? 'Filter';
  String get sort => _translations['sort'] ?? 'Sort';
  String get date => _translations['date'] ?? 'Date';
  String get time => _translations['time'] ?? 'Time';
  String get today => _translations['today'] ?? 'Today';
  String get yesterday => _translations['yesterday'] ?? 'Yesterday';
  String get tomorrow => _translations['tomorrow'] ?? 'Tomorrow';
  String get week => _translations['week'] ?? 'Week';
  String get month => _translations['month'] ?? 'Month';
  String get year => _translations['year'] ?? 'Year';
  String get daily => _translations['daily'] ?? 'Daily';
  String get weekly => _translations['weekly'] ?? 'Weekly';
  String get monthly => _translations['monthly'] ?? 'Monthly';
  String get yearly => _translations['yearly'] ?? 'Yearly';
  String get progress => _translations['progress'] ?? 'Progress';
  String get percentage => _translations['percentage'] ?? 'Percentage';
  String get target => _translations['target'] ?? 'Target';
  String get achieved => _translations['achieved'] ?? 'Achieved';
  String get remaining => _translations['remaining'] ?? 'Remaining';
  String get streak => _translations['streak'] ?? 'Streak';
  String get days => _translations['days'] ?? 'Days';
  String get hours => _translations['hours'] ?? 'Hours';
  String get minutes => _translations['minutes'] ?? 'Minutes';
  String get seconds => _translations['seconds'] ?? 'Seconds';
  String get viewAll => _translations['viewAll'] ?? 'View All';
  String get welcome => _translations['welcome'] ?? 'Welcome!';
  String get tasksToday => _translations['tasksToday'] ?? 'You have {count} tasks today';
  String get all => _translations['all'] ?? 'All';
  String get searchTasks => _translations['searchTasks'] ?? 'Search tasks...';
  String get noTasksFound => _translations['noTasksFound'] ?? 'No tasks found';
  String get addNewTask => _translations['addNewTask'] ?? 'Add new task';
  String get taskDetails => _translations['taskDetails'] ?? 'Task details';
  String get editTask => _translations['editTask'] ?? 'Edit task';
  String get deleteTask => _translations['deleteTask'] ?? 'Delete task';
  String get markAsComplete => _translations['markAsComplete'] ?? 'Mark as complete';
  String get markAsIncomplete => _translations['markAsIncomplete'] ?? 'Mark as incomplete';
  String get taskPriority => _translations['taskPriority'] ?? 'Task priority';
  String get taskCategory => _translations['taskCategory'] ?? 'Task category';
  String get taskDueDate => _translations['taskDueDate'] ?? 'Due date';
  String get taskNotes => _translations['taskNotes'] ?? 'Task notes';
  String get selectCategory => _translations['selectCategory'] ?? 'Select category';
  String get selectPriority => _translations['selectPriority'] ?? 'Select priority';
  String get selectDate => _translations['selectDate'] ?? 'Select date';
  String get noTasksForToday => _translations['noTasksForToday'] ?? 'No tasks for today';
  String get pendingTasks => _translations['pendingTasks'] ?? 'Pending tasks';
  String get highPriority => _translations['highPriority'] ?? 'High priority';
  String get mediumPriority => _translations['mediumPriority'] ?? 'Medium priority';
  String get lowPriority => _translations['lowPriority'] ?? 'Low priority';
  String get work => _translations['work'] ?? 'Work';
  String get personal => _translations['personal'] ?? 'Personal';
  String get study => _translations['study'] ?? 'Study';
  String get health => _translations['health'] ?? 'Health';
  String get sport => _translations['sport'] ?? 'Sport';
  String get other => _translations['other'] ?? 'Other';
  String get searchProjects => _translations['searchProjects'] ?? 'Search projects...';
  String get addNewProject => _translations['addNewProject'] ?? 'Add new project';
  String get projectDetails => _translations['projectDetails'] ?? 'Project details';
  String get editProject => _translations['editProject'] ?? 'Edit project';
  String get deleteProject => _translations['deleteProject'] ?? 'Delete project';
  String get projectStatus => _translations['projectStatus'] ?? 'Project status';
  String get projectCategory => _translations['projectCategory'] ?? 'Project category';
  String get projectProgress => _translations['projectProgress'] ?? 'Project progress';
  String get projectDeadline => _translations['projectDeadline'] ?? 'Due date';
  String get projectStartDate => _translations['projectStartDate'] ?? 'Start date';
  String get projectEndDate => _translations['projectEndDate'] ?? 'End date';
  String get projectWeeklyHours => _translations['projectWeeklyHours'] ?? 'Weekly hours';
  String get projectTotalHours => _translations['projectTotalHours'] ?? 'Total hours';
  String get selectStatus => _translations['selectStatus'] ?? 'Select status';
  String get selectSortBy => _translations['selectSortBy'] ?? 'Sort by';
  String get sortByName => _translations['sortByName'] ?? 'Name';
  String get sortByProgress => _translations['sortByProgress'] ?? 'Progress';
  String get sortByDate => _translations['sortByDate'] ?? 'Date';
  String get noProjectsFound => _translations['noProjectsFound'] ?? 'No projects found';
  String get noProjectsForStatus => _translations['noProjectsForStatus'] ?? 'No projects with this status';
  String get projectTechStack => _translations['projectTechStack'] ?? 'Tech stack';
  String get projectWeeklyFocus => _translations['projectWeeklyFocus'] ?? 'Weekly focus';
  String get projectPriority => _translations['projectPriority'] ?? 'Project priority';
  String get selectProjectCategory => _translations['selectProjectCategory'] ?? 'Select project category';
  String get selectProjectPriority => _translations['selectProjectPriority'] ?? 'Select project priority';
  String get general => _translations['general'] ?? 'General';
  String get development => _translations['development'] ?? 'Development';
  String get design => _translations['design'] ?? 'Design';
  String get marketing => _translations['marketing'] ?? 'Marketing';
  String get research => _translations['research'] ?? 'Research';
  String get resetAll => _translations['resetAll'] ?? 'Reset All';
  String get dailyDhikr => _translations['dailyDhikr'] ?? 'Daily Dhikr';
  String get dhikrCount => _translations['dhikrCount'] ?? 'Dhikr Count';
  String get targetCount => _translations['targetCount'] ?? 'Target';
  String get exercisePushup => _translations['exercisePushup'] ?? 'Push-ups';
  String get exerciseSquat => _translations['exerciseSquat'] ?? 'Squats';
  String get exercisePlank => _translations['exercisePlank'] ?? 'Plank';
  String get exerciseJump => _translations['exerciseJump'] ?? 'Jumping';
  String get exerciseAbs => _translations['exerciseAbs'] ?? 'Abs';
  String get exerciseSets => _translations['exerciseSets'] ?? 'Sets';
  String get totalExercises => _translations['totalExercises'] ?? 'Total Exercises';
  String get completedExercises => _translations['completedExercises'] ?? 'Completed Exercises';
  String get gymSummary => _translations['gymSummary'] ?? 'Gym Summary';
  String get mealBreakfast => _translations['mealBreakfast'] ?? 'Breakfast';
  String get mealLunch => _translations['mealLunch'] ?? 'Lunch';
  String get mealDinner => _translations['mealDinner'] ?? 'Dinner';
  String get mealSnack => _translations['mealSnack'] ?? 'Snack';
  String get allDay => _translations['allDay'] ?? 'All Day';
  String get waterIntake => _translations['waterIntake'] ?? 'Water Intake';
  String get totalWater => _translations['totalWater'] ?? 'Total Water';
  String get completedMeals => _translations['completedMeals'] ?? 'Completed Meals';
  String get foodSummary => _translations['foodSummary'] ?? 'Food Summary';
  String get errorOccurred => _translations['errorOccurred'] ?? 'An error occurred:';
  String get retryButton => _translations['retryButton'] ?? 'Retry';
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return locale.languageCode == 'ar' || locale.languageCode == 'en';
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    await LocalizationService.instance.load();
    
    String jsonContent;
    if (locale.languageCode == 'ar') {
      jsonContent = await rootBundle.loadString('lib/l10n/app_ar.arb');
    } else {
      jsonContent = await rootBundle.loadString('lib/l10n/app_en.arb');
    }
    
    final dynamicTranslations = json.decode(jsonContent) as Map<String, dynamic>;
    final translations = dynamicTranslations.map((key, value) => MapEntry(key, value.toString()));
    return AppLocalizations(locale, translations);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
