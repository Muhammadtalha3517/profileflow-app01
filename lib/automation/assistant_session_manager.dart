import 'dart:convert';
import '../models/user_profile.dart';
import '../models/form_field_match.dart';
import '../models/activity_log_entry.dart';
import '../database/local_database.dart';
import '../field_mapping/field_matcher_engine.dart';
import 'form_scanner_script.dart';
import 'form_filler_script.dart';

enum SessionStatus {
  idle,
  scanning,
  fieldsDetected,
  readyToFill,
  filling,
  completed,
  paused,
  error,
}

class AssistantSessionManager {
  final LocalDatabase _db = LocalDatabase();

  SessionStatus status = SessionStatus.idle;
  String currentUrl = '';
  String currentPageTitle = '';
  bool hasCaptcha = false;
  List<FormFieldMatch> currentMatches = [];
  String? errorMessage;

  /// Scans the current DOM via the provided JS evaluation callback
  Future<void> scanCurrentStep({
    required Future<String> Function(String script) evaluateJavascript,
    required UserProfile profile,
  }) async {
    status = SessionStatus.scanning;
    errorMessage = null;

    try {
      final rawResult = await evaluateJavascript(FormScannerScript.jsScanScript);
      final jsonMap = jsonDecode(rawResult) as Map<String, dynamic>;

      if (jsonMap['success'] == true) {
        currentUrl = jsonMap['url'] as String? ?? '';
        currentPageTitle = jsonMap['pageTitle'] as String? ?? '';
        hasCaptcha = jsonMap['hasCaptcha'] as bool? ?? false;

        final rawFields = (jsonMap['fields'] as List<dynamic>?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [];

        if (rawFields.isEmpty) {
          status = SessionStatus.idle;
          errorMessage = 'Unable to detect compatible form fields on this step.';
          return;
        }

        // Run field matching engine against user's real profile
        currentMatches = FieldMatcherEngine.matchFields(
          rawFields: rawFields,
          profile: profile,
        );

        status = SessionStatus.fieldsDetected;

        // Log scan event
        await _db.addActivityLog(ActivityLogEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: DateTime.now(),
          actionType: 'pageScanned',
          title: 'Step Scanned',
          description: '${rawFields.length} fields detected on current step.',
          targetUrl: currentUrl,
          count: rawFields.length,
        ));
      } else {
        status = SessionStatus.error;
        errorMessage = jsonMap['error'] as String? ?? 'Failed to inspect page fields.';
      }
    } catch (e) {
      status = SessionStatus.error;
      errorMessage = 'Scan error: $e';
    }
  }

  /// Toggles selection of a specific field match
  void toggleFieldSelection(int index, bool selected) {
    if (index >= 0 && index < currentMatches.length) {
      currentMatches[index] = currentMatches[index].copyWith(isSelected: selected);
    }
  }

  /// Updates manual value override for a specific field match
  void updateFieldOverride(int index, String newValue) {
    if (index >= 0 && index < currentMatches.length) {
      currentMatches[index] = currentMatches[index].copyWith(
        userSelectedValue: newValue,
        isManualOverride: true,
        isSelected: true,
      );
    }
  }

  /// Selects or deselects all fields
  void selectAllFields(bool select) {
    currentMatches = currentMatches
        .map((m) => m.copyWith(isSelected: select && m.effectiveFillValue.isNotEmpty))
        .toList();
  }

  /// Fills only the user-approved fields via JS injection
  Future<int> fillApprovedFields({
    required Future<String> Function(String script) evaluateJavascript,
  }) async {
    final selectedMatches = currentMatches.where((m) => m.isSelected && m.effectiveFillValue.isNotEmpty).toList();

    if (selectedMatches.isEmpty) {
      return 0;
    }

    status = SessionStatus.filling;

    try {
      final fillInstructions = selectedMatches.map((m) {
        return {
          'selector': m.selector,
          'value': m.effectiveFillValue,
        };
      }).toList();

      final fillScript = FormFillerScript.buildFillScript(fillInstructions);
      final rawResult = await evaluateJavascript(fillScript);
      final jsonMap = jsonDecode(rawResult) as Map<String, dynamic>;

      final filledCount = jsonMap['filledCount'] as int? ?? 0;
      status = SessionStatus.completed;

      // Log fill event
      await _db.addActivityLog(ActivityLogEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        actionType: 'fieldsFilled',
        title: 'Fields Populated',
        description: '$filledCount fields successfully filled into current form.',
        targetUrl: currentUrl,
        count: filledCount,
      ));

      return filledCount;
    } catch (e) {
      status = SessionStatus.error;
      errorMessage = 'Fill error: $e';
      return 0;
    }
  }

  void reset() {
    status = SessionStatus.idle;
    currentMatches.clear();
    errorMessage = null;
    hasCaptcha = false;
  }
}
