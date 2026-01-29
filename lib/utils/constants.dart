import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Colors
  static const Color primaryColor = Color(0xFF4361EE);
  static const Color secondaryColor = Color(0xFF3A0CA3);
  static const Color successColor = Color(0xFF4CC9F0);
  static const Color warningColor = Color(0xFFF72585);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF101322);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textLight = Color(0xFFFFFFFF);
  
  // Card Colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1F2937);
  
  // Gray Shades
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
  
  // Section Colors
  static const Color morningOrange = Color(0xFFF97316);
  static const Color eveningIndigo = Color(0xFF818CF8);
  
  // Border Colors
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF374151);
  
  // Disabled Colors
  static const Color disabledLight = Color(0xFFD1D5DB);
  static const Color disabledDark = Color(0xFF4B5563);
}

class AppTypography {
  // Font Sizes
  static const double heading = 22.0;
  static const double title = 18.0;
  static const double titleLarge = 20.0;
  static const double body = 16.0;
  static const double caption = 14.0;
  static const double small = 12.0;
  static const double tiny = 10.0;
  
  // Font Weights
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight bold = FontWeight.w700;
  
  // English Numbers Style
  static final TextStyle englishNumbers = GoogleFonts.robotoMono(
    fontSize: small,
    fontWeight: regular,
  );
}

class AppSpacing {
  // Padding Values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppBorderRadius {
  // Border Radius Values
  static const double small = 2.0;
  static const double default_ = 4.0;
  static const double lg = 8.0;
  static const double large = 12.0;
  static const double xl = 12.0;
  static const double xxl = 16.0;
  static const double full = 9999.0;
}

class AppSizes {
  // Icon Sizes
  static const double iconSmall = 18.0;
  static const double iconDefault = 24.0;
  static const double iconNavigation = 28.0;
  static const double iconLarge = 32.0;
  
  // Screen Constraints
  static const double maxMobileWidth = 480.0;
  
  // Component Heights
  static const double buttonHeight = 48.0;
  static const double inputHeight = 48.0;
  static const double navigationHeight = 60.0;
  static const double fabSize = 56.0;
}

class AppStrings {
  // App Info
  static const String appName = 'متتبع الحياة اليومية';
  static const String appVersion = '1.0.0';
  
  // Navigation
  static const String home = 'الرئيسية';
  static const String stats = 'الإحصائيات';
  static const String weeklyStats = 'إحصائيات الأسبوع';
  static const String prayers = 'الصلوات';
  static const String quran = 'القرآن';
  static const String tasks = 'المهام';
  static const String health = 'الصحة';
  static const String projects = 'مشاريعي';
  
  // Common Actions
  static const String add = 'إضافة';
  static const String edit = 'تعديل';
  static const String delete = 'حذف';
  static const String save = 'حفظ';
  static const String cancel = 'إلغاء';
  static const String confirm = 'تأكيد';
  static const String done = 'تم';
  static const String skip = 'تخطي';
  
  // Project Strings
  static const String addProject = 'إضافة مشروع';
  static const String activeProjects = 'قيد التنفيذ';
  static const String pausedProjects = 'متوقف مؤقتاً';
  static const String resume = 'استئناف';
  static const String excellentProgress = 'تقدم ممتاز';
  static const String needsFocus = 'تحتاج تركيزاً';
  static const String weeklyHours = 'ساعة/أسبوع';
  static const String deadline = 'الموعد النهائي';
  static const String monthlyProgress = 'إجمالي إنجاز الشهر';
  static const String projectQuote = '"إن الله يحب إذا عمل أحدكم عملاً أن يتقنه"';
  
  // Stats Strings
  static const String overallProductivity = 'الإنتاجية الإجمالية';
  static const String excellentPerformance = 'أداء ممتاز هذا الأسبوع مقارنة بالسابق';
  static const String timeDistribution = 'توزيع الوقت';
  static const String weeklyAchievements = 'إنجازات الأسبوع';
  static const String work = 'العمل';
  static const String personalProjects = 'المشاريع الخاصة';
  static const String gym = 'النادي الرياضي';
  static const String hours = 'ساعة';
  static const String hoursPlural = 'ساعات';
  
  // Day Names
  static const String saturday = 'السبت';
  static const String sunday = 'الأحد';
  static const String monday = 'الإثنين';
  static const String tuesday = 'الثلاثاء';
  static const String wednesday = 'الأربعاء';
  static const String thursday = 'الخميس';
  static const String friday = 'الجمعة';
  
  // Prayer Times
  static const String fajr = 'الفجر';
  static const String dhuhr = 'الظهر';
  static const String asr = 'العصر';
  static const String maghrib = 'المغرب';
  static const String isha = 'العشاء';
  
  // Time Periods
  static const String morning = 'الصباح';
  static const String evening = 'المساء';
  static const String night = 'الليل';
  
  // Status Messages
  static const String loading = 'جاري التحميل...';
  static const String error = 'حدث خطأ';
  static const String success = 'تم بنجاح';
  static const String noData = 'لا توجد بيانات';
  static const String errorLoadingStats = 'فشل تحميل الإحصائيات';
  static const String errorLoadingReports = 'فشل تحميل التقارير';
  static const String errorNetworkConnection = 'تحقق من اتصال الإنترنت';
  static const String errorAuthentication = 'يرجى تسجيل الدخول مرة أخرى';
  
  // Validation Messages
  static const String required = 'هذا الحقل مطلوب';
  static const String invalidEmail = 'البريد الإلكتروني غير صحيح';
  static const String passwordTooShort = 'يجب أن تكون 6 أحرف على الأقل';
  static const String passwordsNotMatch = 'كلمات المرور غير متطابقة';
  static const String enterEmail = 'الرجاء إدخال البريد الإلكتروني';
  static const String enterPassword = 'الرجاء إدخال كلمة المرور';
  static const String invalidEmailFormat = 'بريد إلكتروني غير صحيح';
  
  // Auth Screen Strings
  static const String signIn = 'تسجيل الدخول';
  static const String signUp = 'إنشاء حساب';
  static const String signInSubtitle = 'استمر في تسجيل الدخول';
  static const String forgotPassword = 'نسيت كلمة المرور؟';
  static const String noAccount = 'ليس لديك حساب؟';
  static const String haveAccount = 'لديك حساب بالفعل؟';
  static const String registerNow = 'سجل الآن';
  static const String signInNow = 'تسجيل الدخول الآن';
  
  // Add Screen Strings
  static const String addNew = 'إضافة جديد';
  static const String addTask = 'إضافة مهمة';
  static const String taskName = 'اسم المهمة';
  static const String projectName = 'اسم المشروع';
  static const String category = 'التصنيف';
  static const String techStack = 'التقنيات المستخدمة';
  static const String reminderTime = 'وقت التذكير';
  static const String repeat = 'تكرار';
  static const String daily = 'يومياً';
  static const String saveTask = 'حفظ المهمة';
  static const String saveProject = 'حفظ المشروع';
  static const String heroMessage = 'ماذا ستنجز اليوم يا بطل؟';
  static const String heroSubtitle = 'خطط ليومك لتصل لأهدافك بشكل أسرع.';

  // Achievement Strings
  static const String achievements = 'الأوسمة والإنجازات';
  static const String currentLevel = 'المستوى الحالي';
  static const String xpPoints = 'نقطة XP';
  static const String xpRemaining = 'نقطة متبقية للمستوى القادم';
  static const String viewRoadmap = 'عرض خارطة الطريق';
  static const String earnedBadges = 'أوسمتك المحققة';
  static const String viewAll = 'عرض الكل';
  static const String weeklyLeaderboard = 'قائمة المتصدرين الأسبوعية';
  static const String locked = 'قريباً';
  static const String fastProgress = 'تقدم سريع!';

  // Badge Names
  static const String prayerBadge = 'المصلي الخاشع';
  static const String projectsBadge = 'قناص المشاريع';
  static const String ecoBadge = 'صديق البيئة';
  static const String nightOwlBadge = 'ساهر الليل';
  static const String monthHeroBadge = 'بطل الشهر';
  static const String gymBadge = 'وحش النادي';
  
  // Profile & Settings Strings
  static const String profile = 'الملف الشخصي والإعدادات';
  static const String editProfile = 'تعديل الملف الشخصي';
  static const String privacy = 'الخصوصية';
  static const String myAccount = 'حسابي';
  static const String notifications = 'التنبيهات';
  static const String appearance = 'المظهر';
  static const String support = 'الدعم';
  static const String prayerNotifications = 'تنبيهات أوقات الصلاة';
  static const String projectReminders = 'تذكير المشاريع';
  static const String waterTrackerNotifications = 'تنبيهات تتبع المياه';
  static const String darkMode = 'الوضع الليلي';
  static const String changeTheme = 'تغيير السمة';
  static const String aboutApp = 'عن التطبيق';
  static const String contactUs = 'تواصل معنا';
  static const String signOut = 'تسجيل الخروج';
  static const String badges = 'أوسمة';
  static const String streak = 'سلسلة إنجاز';
  static const String points = 'نقاط';
  static const String days = 'يوم';

  // Error Messages - General
  static const String errorUnexpected = 'حدث خطأ غير متوقع';
  static const String errorTryAgain = 'حاول مرة أخرى';
  static const String errorRetry = 'إعادة المحاولة';

  // Error Messages - Network
  static const String errorNoInternet = 'لا يوجد اتصال بالإنترنت';
  static const String errorTimeout = 'انتهت مهلة الاتصال';
  static const String errorServerUnreachable = 'لا يمكن الوصول إلى الخادم';

  // Error Messages - Authentication
  static const String errorInvalidCredentials = 'بيانات الدخول غير صحيحة';
  static const String errorUserNotFound = 'المستخدم غير موجود';
  static const String errorEmailAlreadyExists = 'البريد الإلكتروني مستخدم بالفعل';
  static const String errorWeakPassword = 'كلمة المرور ضعيفة جداً';
  static const String errorSessionExpired = 'انتهت صلاحية الجلسة';

  // Error Messages - Data Loading
  static const String errorLoadingTasks = 'فشل تحميل المهام';
  static const String errorLoadingProjects = 'فشل تحميل المشاريع';
  static const String errorLoadingProfile = 'فشل تحميل الملف الشخصي';
  static const String errorLoadingWater = 'فشل تحميل بيانات المياه';
  static const String errorLoadingAchievements = 'فشل تحميل الإنجازات';

  // Error Messages - Data Operations
  static const String errorSavingData = 'فشل حفظ البيانات';
  static const String errorUpdatingData = 'فشل تحديث البيانات';
  static const String errorDeletingData = 'فشل حذف البيانات';
  static const String errorCreatingTask = 'فشل إنشاء المهمة';
  static const String errorCreatingProject = 'فشل إنشاء المشروع';

  // Error Messages - Initialization
  static const String errorInitialization = 'فشل تهيئة التطبيق';
  static const String errorDatabaseConnection = 'فشل الاتصال بقاعدة البيانات';

  // Error Messages - Enhanced
  static const String errorCheckConnection = 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى';
  static const String errorOfflineMode = 'أنت غير متصل بالإنترنت';
  static const String errorRetrying = 'جاري إعادة المحاولة...';
}

class AppIcons {
  // Common Icons (using Material Icons names)
  static const IconData home = Icons.home;
  static const IconData prayers = Icons.mosque;
  static const IconData quran = Icons.menu_book;
  static const IconData tasks = Icons.work;
  static const IconData health = Icons.fitness_center;
  static const IconData settings = Icons.settings;
  static const IconData profile = Icons.person;
  static const IconData add = Icons.add;
  static const IconData edit = Icons.edit;
  static const IconData delete = Icons.delete;
  static const IconData save = Icons.save;
  static const IconData cancel = Icons.close;
  static const IconData check = Icons.check;
  static const IconData arrowBack = Icons.arrow_back;
  static const IconData arrowForward = Icons.arrow_forward;
  static const IconData menu = Icons.menu;
  static const IconData notifications = Icons.notifications;
  static const IconData search = Icons.search;
  static const IconData filter = Icons.filter_list;
  static const IconData calendar = Icons.calendar_today;
  static const IconData clock = Icons.access_time;
  static const IconData location = Icons.location_on;
  static const IconData phone = Icons.phone;
  static const IconData email = Icons.email;
  static const IconData password = Icons.lock;
  static const IconData visibility = Icons.visibility;
  static const IconData visibilityOff = Icons.visibility_off;
  static const IconData refresh = Icons.refresh;
  static const IconData download = Icons.download;
  static const IconData upload = Icons.upload;
  static const IconData share = Icons.share;
  static const IconData favorite = Icons.favorite;
  static const IconData favoriteBorder = Icons.favorite_border;
  static const IconData bookmark = Icons.bookmark;
  static const IconData bookmarkBorder = Icons.bookmark_border;
  static const IconData trendingUp = Icons.trending_up;
  static const IconData trendingDown = Icons.trending_down;
  static const IconData warning = Icons.warning;
  static const IconData error = Icons.error;
  static const IconData info = Icons.info;
  static const IconData success = Icons.check_circle;
  static const IconData lightMode = Icons.light_mode;
  static const IconData darkMode = Icons.dark_mode;
}

class AppConstants {
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Timeout Durations
  static const Duration shortTimeout = Duration(seconds: 5);
  static const Duration mediumTimeout = Duration(seconds: 10);
  static const Duration longTimeout = Duration(seconds: 30);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Text Limits
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;
  static const int maxNoteLength = 1000;
  
  // File Sizes
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB
  
  // Cache Settings
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 50; // items
  
  // API Settings
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}

class AppCategories {
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'work':
        return Icons.work;
      case 'prayer':
        return Icons.menu_book;
      case 'health':
        return Icons.fitness_center;
      case 'personal':
        return Icons.person;
      default:
        return Icons.category;
    }
  }

  static String getCategoryLabel(String category) {
    switch (category) {
      case 'work':
        return 'عمل';
      case 'prayer':
        return 'صلاة';
      case 'health':
        return 'صحة';
      case 'personal':
        return 'شخصي';
      default:
        return 'أخرى';
    }
  }

  static String getCategoryKey(String label) {
    switch (label) {
      case 'عمل':
        return 'work';
      case 'صلاة':
        return 'prayer';
      case 'صحة':
        return 'health';
      case 'شخصي':
        return 'personal';
      default:
        return 'other';
    }
  }

  static List<String> getAllCategories() {
    return ['work', 'prayer', 'health', 'personal'];
  }

  static Color getCategoryColor(String category) {
    switch (category) {
      case 'work':
        return AppColors.primaryColor;
      case 'prayer':
        return Colors.teal;
      case 'health':
        return Colors.orange;
      case 'personal':
        return Colors.purple;
      default:
        return AppColors.gray500;
    }
  }
}
