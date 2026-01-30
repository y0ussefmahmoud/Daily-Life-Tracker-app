#!/usr/bin/env dart

import 'dart:io';
import 'package:http/http.dart' as http;

/// Test Execution Script for Daily Life Tracker
/// 
/// This script provides a command-line interface for running comprehensive tests
/// Usage: dart test/run_tests.dart [options]
/// 
/// Options:
///   --phase <number>    Run specific phase (1-8)
///   --all              Run all phases (default)
///   --report           Generate detailed report
///   --help             Show this help message

void main(List<String> arguments) async {
  print('🚀 Daily Life Tracker Test Execution Script');
  print('=' * 50);

  if (arguments.contains('--help')) {
    _showHelp();
    return;
  }

  final phaseIndex = _getPhaseIndex(arguments);
  final generateReport = arguments.contains('--report');

  if (phaseIndex != null) {
    await _runPhase(phaseIndex, generateReport);
  } else {
    await _runAllPhases(generateReport);
  }
}

void _showHelp() {
  print('''
Usage: dart test/run_tests.dart [options]

Options:
  --phase <number>    Run specific phase (1-8)
  --all              Run all phases (default)
  --report           Generate detailed report
  --help             Show this help message

Phases:
  1 - Authentication Flow Tests
  2 - Navigation & Screens Tests
  3 - Tasks Management Tests
  4 - Projects Management Tests
  5 - Water Tracker & Statistics Tests
  6 - Dark/Light Mode Tests
  7 - Error Handling Tests
  8 - Performance Tests

Examples:
  dart test/run_tests.dart                    # Run all tests
  dart test/run_tests.dart --phase 1         # Run Phase 1 only
  dart test/run_tests.dart --phase 3 --report # Run Phase 3 with report
  dart test/run_tests.dart --all --report     # Run all with detailed report
''');
}

int? _getPhaseIndex(List<String> arguments) {
  final phaseIndex = arguments.indexOf('--phase');
  if (phaseIndex != -1 && phaseIndex + 1 < arguments.length) {
    final phase = int.tryParse(arguments[phaseIndex + 1]);
    if (phase != null && phase >= 1 && phase <= 8) {
      return phase;
    }
    print('❌ Invalid phase number. Please use 1-8.');
    exit(1);
  }
  return null;
}

Future<void> _runPhase(int phaseNumber, bool generateReport) async {
  final phaseName = _getPhaseName(phaseNumber);
  print('\n🔍 Running Phase $phaseNumber: $phaseName');
  print('-' * 40);

  final stopwatch = Stopwatch()..start();

  try {
    final result = await Process.run('flutter', [
      'test',
      'test/phase${phaseNumber}_*_test.dart',
      if (generateReport) '--reporter=expanded',
    ]);

    stopwatch.stop();

    if (result.exitCode == 0) {
      print('✅ Phase $phaseNumber completed successfully');
      print('⏱️  Duration: ${stopwatch.elapsed.inSeconds}s');
      
      if (generateReport) {
        await _generatePhaseReport(phaseNumber, result.stdout.toString());
      }
    } else {
      print('❌ Phase $phaseNumber failed');
      print('⏱️  Duration: ${stopwatch.elapsed.inSeconds}s');
      print('📝 Error output:');
      print(result.stderr);
    }
  } catch (e) {
    print('❌ Error running Phase $phaseNumber: $e');
  }
}

Future<void> _runAllPhases(bool generateReport) async {
  print('\n🎯 Running All Test Phases');
  print('=' * 40);

  final totalStopwatch = Stopwatch()..start();
  final results = <int, ProcessResult>{};

  for (int phase = 1; phase <= 8; phase++) {
    final phaseStopwatch = Stopwatch()..start();
    
    try {
      final result = await Process.run('flutter', [
        'test',
        'test/phase${phase}_*_test.dart',
        '--reporter=compact',
      ]);

      phaseStopwatch.stop();
      results[phase] = result;

      final status = result.exitCode == 0 ? '✅' : '❌';
      final duration = phaseStopwatch.elapsed.inSeconds;
      
      print('$status Phase $phase: ${_getPhaseName(phase)} (${duration}s)');
      
      if (result.exitCode != 0) {
        print('   Error: ${result.stderr.toString().split('\n').first}');
      }
    } catch (e) {
      print('❌ Phase $phase: Failed to run - $e');
    }
  }

  totalStopwatch.stop();
  
  print('\n' + '=' * 40);
  print('📊 Test Summary');
  print('=' * 40);
  
  int passedPhases = 0;
  int totalDuration = 0;

  for (int phase = 1; phase <= 8; phase++) {
    final result = results[phase];
    if (result != null) {
      final status = result.exitCode == 0 ? 'PASSED' : 'FAILED';
      final duration = result.exitCode == 0 ? 
        '✅ ${_getPhaseDuration(result.stdout.toString())}' : 
        '❌ Failed';
      
      print('Phase $phase: $status');
      
      if (result.exitCode == 0) {
        passedPhases++;
      }
    } else {
      print('Phase $phase: ❌ Not run');
    }
  }

  print('\n🎯 Overall Result: $passedPhases/8 phases passed');
  print('⏱️  Total Duration: ${totalStopwatch.elapsed.inMinutes}m ${totalStopwatch.elapsed.inSeconds % 60}s');

  if (generateReport) {
    await _generateFullReport(results);
  }

  if (passedPhases == 8) {
    print('\n🎉 All tests passed! Daily Life Tracker is ready for production! 🚀');
  } else {
    print('\n⚠️  Some tests failed. Please review the errors above.');
    exit(1);
  }
}

String _getPhaseName(int phaseNumber) {
  switch (phaseNumber) {
    case 1: return 'Authentication Flow';
    case 2: return 'Navigation & Screens';
    case 3: return 'Tasks Management';
    case 4: return 'Projects Management';
    case 5: return 'Water Tracker & Statistics';
    case 6: return 'Dark/Light Mode';
    case 7: return 'Error Handling';
    case 8: return 'Performance';
    default: return 'Unknown Phase';
  }
}

String _getPhaseDuration(String output) {
  // Extract duration from test output
  final durationMatch = RegExp(r'\((\d+)s\)').firstMatch(output);
  return durationMatch != null ? '${durationMatch.group(1)}s' : 'Unknown';
}

Future<void> _generatePhaseReport(int phaseNumber, String output) async {
  final reportFile = File('test/reports/phase_${phaseNumber}_report.md');
  
  if (!await reportFile.parent.exists()) {
    await reportFile.parent.create(recursive: true);
  }

  final timestamp = DateTime.now().toIso8601String();
  final phaseName = _getPhaseName(phaseNumber);

  final report = '''
# Phase $phaseNumber Test Report: $phaseName

**Generated:** $timestamp

## Test Output
```
$output
```

## Status
${output.contains('All tests passed') ? '✅ PASSED' : '❌ FAILED'}

---

*Report generated by Daily Life Tracker Test Runner*
''';

  await reportFile.writeAsString(report);
  print('📄 Report saved to: ${reportFile.path}');
}

Future<void> _generateFullReport(Map<int, ProcessResult> results) async {
  final reportFile = File('test/reports/comprehensive_test_report.md');
  
  if (!await reportFile.parent.exists()) {
    await reportFile.parent.create(recursive: true);
  }

  final timestamp = DateTime.now().toIso8601String();
  
  var report = '''
# Daily Life Tracker - Comprehensive Test Report

**Generated:** $timestamp  
**Test Framework:** Flutter Test  
**Total Phases:** 8

## Executive Summary

''';

  int passedPhases = 0;
  for (int phase = 1; phase <= 8; phase++) {
    final result = results[phase];
    if (result?.exitCode == 0) {
      passedPhases++;
    }
  }

  report += '''
- **Overall Status:** ${passedPhases == 8 ? '✅ ALL PASSED' : '⚠️ PARTIAL SUCCESS'}
- **Phases Passed:** $passedPhases/8
- **Success Rate:** ${((passedPhases / 8) * 100).toStringAsFixed(1)}%

## Phase Results

| Phase | Name | Status | Duration |
|-------|------|--------|----------|
''';

  for (int phase = 1; phase <= 8; phase++) {
    final result = results[phase];
    final status = result?.exitCode == 0 ? '✅ PASSED' : '❌ FAILED';
    final duration = result?.exitCode == 0 ? 
      _getPhaseDuration(result!.stdout.toString()) : 
      'Failed';
    
    report += '| $phase | ${_getPhaseName(phase)} | $status | $duration |\n';
  }

  report += '''

## Detailed Output

''';

  for (int phase = 1; phase <= 8; phase++) {
    final result = results[phase];
    if (result != null) {
      report += '''
### Phase $phase: ${_getPhaseName(phase)}

**Status:** ${result.exitCode == 0 ? 'PASSED' : 'FAILED'}

**Output:**
```
${result.stdout.toString()}
```

${result.stderr.toString().isNotEmpty ? '**Error:**\n```\n${result.stderr.toString()}\n```\n' : ''}

---
''';
    }
  }

  report += '''

## Recommendations

${passedPhases == 8 ? '''
🎉 **Excellent!** All tests are passing. The application is ready for production deployment.

**Next Steps:**
1. Run tests on physical devices
2. Perform manual user acceptance testing
3. Prepare deployment documentation
4. Deploy to production environment
''' : '''
⚠️ **Action Required:** Some tests are failing. Please address the issues before deployment.

**Recommended Actions:**
1. Review failed tests and fix underlying issues
2. Re-run failed phases individually
3. Ensure all critical functionality works
4. Perform additional manual testing
5. Consider deployment to staging environment first
'''}

---

*This report was automatically generated by the Daily Life Tracker Test Runner.*
*For questions about test results, please refer to the individual phase reports or contact the development team.*
''';

  await reportFile.writeAsString(report);
  print('📄 Comprehensive report saved to: ${reportFile.path}');
}
