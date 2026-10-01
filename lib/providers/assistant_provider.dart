import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/form_field_match.dart';
import '../automation/assistant_session_manager.dart';

class AssistantProvider with ChangeNotifier {
  final AssistantSessionManager _session = AssistantSessionManager();

  String? _activeTaskId;
  bool _isOverlayExpanded = true;
  bool _isManualActionBannerVisible = false;
  String _manualActionMessage = '';

  SessionStatus get status => _session.status;
  List<FormFieldMatch> get currentMatches => _session.currentMatches;
  String get currentUrl => _session.currentUrl;
  String get currentPageTitle => _session.currentPageTitle;
  bool get hasCaptcha => _session.hasCaptcha;
  String? get errorMessage => _session.errorMessage;
  String? get activeTaskId => _activeTaskId;
  bool get isOverlayExpanded => _isOverlayExpanded;
  bool get isManualActionBannerVisible => _isManualActionBannerVisible;
  String get manualActionMessage => _manualActionMessage;

  int get approvedFieldsCount => _session.currentMatches
      .where((m) => m.isSelected && m.effectiveFillValue.isNotEmpty)
      .length;

  int get totalDetectedFieldsCount => _session.currentMatches.length;

  void setActiveTaskId(String? taskId) {
    _activeTaskId = taskId;
    notifyListeners();
  }

  void toggleOverlayExpanded() {
    _isOverlayExpanded = !_isOverlayExpanded;
    notifyListeners();
  }

  void showManualActionBanner(String message) {
    _manualActionMessage = message;
    _isManualActionBannerVisible = true;
    notifyListeners();
  }

  void dismissManualActionBanner() {
    _isManualActionBannerVisible = false;
    notifyListeners();
  }

  Future<void> scanCurrentStep({
    required Future<String> Function(String script) evaluateJavascript,
    required UserProfile profile,
  }) async {
    await _session.scanCurrentStep(
      evaluateJavascript: evaluateJavascript,
      profile: profile,
    );

    if (_session.hasCaptcha) {
      showManualActionBanner('Manual action required: CAPTCHA / Human verification detected on page.');
    }

    notifyListeners();
  }

  void toggleFieldSelection(int index, bool selected) {
    _session.toggleFieldSelection(index, selected);
    notifyListeners();
  }

  void updateFieldOverride(int index, String newValue) {
    _session.updateFieldOverride(index, newValue);
    notifyListeners();
  }

  void selectAllFields(bool select) {
    _session.selectAllFields(select);
    notifyListeners();
  }

  Future<int> fillApprovedFields({
    required Future<String> Function(String script) evaluateJavascript,
  }) async {
    final count = await _session.fillApprovedFields(
      evaluateJavascript: evaluateJavascript,
    );
    notifyListeners();
    return count;
  }

  void resetSession() {
    _session.reset();
    _isManualActionBannerVisible = false;
    notifyListeners();
  }
}
