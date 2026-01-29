import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../providers/water_provider.dart';
import '../providers/project_provider.dart';
import '../utils/error_handler.dart';
import '../utils/constants.dart';
import 'home_screen.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _errorMessage;
  bool _hasError = false;
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    try {
      await authProvider.initialize();

      if (authProvider.isAuthenticated) {
        await Future.wait([
          Provider.of<TaskProvider>(context, listen: false).initialize(),
          Provider.of<WaterProvider>(context, listen: false).initialize(),
          Provider.of<ProjectProvider>(context, listen: false).loadProjects(),
        ]);
      }
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => authProvider.isAuthenticated
                ? const HomeScreen()
                : const LoginScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = handleSupabaseError(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _hasError
            ? ErrorStateWidget(
                message: _errorMessage ?? AppStrings.errorInitialization,
                onRetry: () {
                  setState(() {
                    _hasError = false;
                    _errorMessage = null;
                  });
                  _initializeApp();
                },
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    AppStrings.loading,
                    style: GoogleFonts.tajawal(
                      fontSize: AppTypography.body,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
