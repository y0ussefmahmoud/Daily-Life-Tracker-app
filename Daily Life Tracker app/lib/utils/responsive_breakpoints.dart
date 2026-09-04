// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: [https://y0ussef.com/](https://y0ussef.com/)
// - Whatsapp: [https://wa.me/Y0ussefmahmoud](https://wa.me/Y0ussefmahmoud)
// - Email: info@Youssef.com

import 'package:flutter/widgets.dart';

class ResponsiveBreakpoints {
  ResponsiveBreakpoints._();

  static const double mobile = 600;
  static const double tablet = 1024;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < tablet;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tablet;
  }

  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) return 3;
    if (isTablet(context)) return 2;
    return 1;
  }

  static double getCardWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (isDesktop(context)) return width * 0.3;
    if (isTablet(context)) return width * 0.45;
    return width * 0.9;
  }

  static double getDialogWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (isDesktop(context)) return 600;
    if (isTablet(context)) return 500;
    return width * 0.9;
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 24);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  }

  static double getFontSize(BuildContext context, double mobileSize) {
    if (isDesktop(context)) return mobileSize * 1.2;
    if (isTablet(context)) return mobileSize * 1.1;
    return mobileSize;
  }
}
