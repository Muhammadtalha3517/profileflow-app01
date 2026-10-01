import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../models/task_item.dart';
import '../../models/form_field_match.dart';
import '../../models/activity_log_entry.dart';
import '../../providers/profile_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/assistant_provider.dart';
import '../../automation/form_scanner_script.dart';
import '../../automation/form_filler_script.dart';
import '../../field_mapping/field_matcher_engine.dart';
import '../../widgets/assistant/field_review_sheet.dart';
import '../../widgets/assistant/manual_action_banner.dart';

class FormAssistantWebViewScreen extends StatefulWidget {
  final String initialUrl;
  final TaskItem? task;

  const FormAssistantWebViewScreen({
    Key? key,
    required this.initialUrl,
    this.task,
  }) : super(key: key);

  @override
  State<FormAssistantWebViewScreen> createState() => _FormAssistantWebViewScreenState();
}

class _FormAssistantWebViewScreenState extends State<FormAssistantWebViewScreen> {
  late WebViewController _webViewController;
  final TextEditingController _urlBarController = TextEditingController();

  bool _isLoading = true;
  double _loadProgress = 0.0;
  String _pageTitle = '';
  String _currentUrl = '';
  bool _isAssistantPaused = false;
  bool _hasCaptcha = false;

  List<FormFieldMatch> _currentMatches = [];

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl.trim();
    if (!_currentUrl.startsWith('http://') && !_currentUrl.startsWith('https://')) {
      _currentUrl = 'https://$_currentUrl';
    }
    _urlBarController.text = _currentUrl;

    _initWebViewController();
  }

  void _initWebViewController() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadProgress = progress / 100.0;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _currentUrl = url;
              _urlBarController.text = url;
              _hasCaptcha = false;
            });
          },
          onPageFinished: (String url) async {
            setState(() {
              _isLoading = false;
              _currentUrl = url;
              _urlBarController.text = url;
            });
            final title = await _webViewController.getTitle();
            if (title != null && mounted) {
              setState(() {
                _pageTitle = title;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Web resource error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(_currentUrl));
  }

  @override
  void dispose() {
    _urlBarController.dispose();
    super.dispose();
  }

  void _navigateToUrl() {
    var url = _urlBarController.text.trim();
    if (url.isNotEmpty) {
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      _webViewController.loadRequest(Uri.parse(url));
    }
  }

  /// Scan the currently active webpage DOM for inputs, selects, textareas
  Future<void> _scanCurrentStep() async {
    if (_isAssistantPaused) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assistant is paused. Tap resume to scan.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final assistantProvider = context.read<AssistantProvider>();
    assistantProvider.logAction(
      action: 'Scan Step Initiated',
      details: 'Scanning active page: $_currentUrl',
      level: LogLevel.info,
    );

    try {
      final jsResult = await _webViewController.runJavaScriptReturningResult(
        FormScannerScript.jsScanScript,
      );

      String rawJson = jsResult.toString();
      if (rawJson.startsWith('"') && rawJson.endsWith('"')) {
        // Unescape string if double encoded by webview
        rawJson = jsonDecode(rawJson);
      }

      final Map<String, dynamic> data = jsonDecode(rawJson) as Map<String, dynamic>;

      final isSuccess = data['success'] as bool? ?? false;
      final captchaDetected = data['hasCaptcha'] as bool? ?? false;
      final rawFieldsList = (data['fields'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [];

      setState(() {
        _hasCaptcha = captchaDetected;
      });

      if (!isSuccess || rawFieldsList.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to detect compatible form fields on this step.'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        assistantProvider.logAction(
          action: 'Scan Completed',
          details: '0 compatible fields detected.',
          level: LogLevel.warning,
        );
        return;
      }

      // Match against authentic user profile
      final profile = context.read<ProfileProvider>().profile;
      final matches = FieldMatcherEngine.matchFields(
        rawFields: rawFieldsList,
        profile: profile,
      );

      setState(() {
        _currentMatches = matches;
      });

      assistantProvider.logAction(
        action: 'Fields Detected & Mapped',
        details: '${matches.length} fields found (${matches.where((m) => m.isSelected).length} confidently matched).',
        level: LogLevel.info,
      );

      // Update Task stats if task exists
      if (widget.task != null) {
        context.read<TaskProvider>().updateTaskStats(
          widget.task!.id,
          detectedCount: matches.length,
        );
      }

      // Automatically show the field review sheet
      if (mounted) {
        _showReviewBottomSheet();
      }
    } catch (e) {
      debugPrint('Scan error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scanning page: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showReviewBottomSheet() {
    if (_currentMatches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please scan the current step first.')),
      );
      return;
    }

    final profile = context.read<ProfileProvider>().profile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return FieldReviewSheet(
            matches: _currentMatches,
            profile: profile,
            onToggleSelection: (index, selected) {
              setSheetState(() {
                _currentMatches[index] = _currentMatches[index].copyWith(isSelected: selected);
              });
              setState(() {});
            },
            onUpdateOverride: (index, newValue) {
              setSheetState(() {
                _currentMatches[index] = _currentMatches[index].copyWith(
                  userSelectedValue: newValue,
                  isManualOverride: true,
                  isSelected: true,
                );
              });
              setState(() {});
            },
            onSelectAll: (selectAll) {
              setSheetState(() {
                _currentMatches = _currentMatches.map((m) {
                  return m.effectiveFillValue.isNotEmpty
                      ? m.copyWith(isSelected: selectAll)
                      : m.copyWith(isSelected: false);
                }).toList();
              });
              setState(() {});
            },
            onFillApproved: () {
              Navigator.pop(ctx);
              _fillApprovedFields();
            },
            onCancel: () => Navigator.pop(ctx),
          );
        },
      ),
    );
  }

  /// Injects user-approved values into DOM inputs
  Future<void> _fillApprovedFields() async {
    final selectedMatches = _currentMatches
        .where((m) => m.isSelected && m.effectiveFillValue.isNotEmpty)
        .toList();

    if (selectedMatches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No fields were selected to fill.')),
      );
      return;
    }

    final instructions = selectedMatches.map((m) {
      return {
        'selector': m.selector,
        'value': m.effectiveFillValue,
      };
    }).toList();

    final fillScript = FormFillerScript.buildFillScript(instructions);

    try {
      final jsResult = await _webViewController.runJavaScriptReturningResult(fillScript);
      String rawJson = jsResult.toString();
      if (rawJson.startsWith('"') && rawJson.endsWith('"')) {
        rawJson = jsonDecode(rawJson);
      }
      final data = jsonDecode(rawJson) as Map<String, dynamic>;
      final filledCount = data['filledCount'] as int? ?? 0;

      final assistantProvider = context.read<AssistantProvider>();
      assistantProvider.logAction(
        action: 'Fields Populated',
        details: 'Successfully filled $filledCount of ${instructions.length} approved fields.',
        level: LogLevel.success,
      );

      if (widget.task != null) {
        context.read<TaskProvider>().updateTaskStats(
          widget.task!.id,
          filledCount: filledCount,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text('Filled $filledCount field${filledCount == 1 ? '' : 's'}. Review before submitting!'),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint('Fill error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to populate fields: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          height: 40,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _urlBarController,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Enter URL...',
              prefixIcon: const Icon(Icons.lock_outline, size: 16, color: AppColors.securityBadge),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward, size: 18),
                onPressed: _navigateToUrl,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.go,
            onSubmitted: (_) => _navigateToUrl(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reload',
            onPressed: () => _webViewController.reload(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Loading Progress Bar
          if (_isLoading)
            LinearProgressIndicator(
              value: _loadProgress > 0 ? _loadProgress : null,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 3,
            ),

          // CAPTCHA / 2FA Manual Action Banner
          if (_hasCaptcha)
            const ManualActionBanner(
              message: 'Security / CAPTCHA detected. Manual user interaction required.',
            ),

          // User-Control Notice Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            child: Row(
              children: [
                const Icon(Icons.pan_tool_alt_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Manual control active: Review required before filling. No auto-submit.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                if (_isAssistantPaused)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.warningBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'PAUSED',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.warning),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Embedded WebView Browser
          Expanded(
            child: WebViewWidget(controller: _webViewController),
          ),

          // Assistant Floating Control Bar at Bottom
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Scan Current Step Button
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: _scanCurrentStep,
                    icon: const Icon(Icons.document_scanner_rounded, size: 18),
                    label: const Text(
                      'Scan Step',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Review / Fill Button
                Expanded(
                  flex: 3,
                  child: OutlinedButton.icon(
                    onPressed: _currentMatches.isNotEmpty ? _showReviewBottomSheet : null,
                    icon: const Icon(Icons.rate_review_rounded, size: 18),
                    label: Text(
                      _currentMatches.isNotEmpty ? 'Review (${_currentMatches.length})' : 'Review',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Pause / Play Toggle
                IconButton.outlined(
                  onPressed: () {
                    setState(() {
                      _isAssistantPaused = !_isAssistantPaused;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isAssistantPaused ? 'Form assistant paused.' : 'Form assistant resumed.'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: Icon(
                    _isAssistantPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    color: _isAssistantPaused ? AppColors.success : AppColors.warning,
                  ),
                  tooltip: _isAssistantPaused ? 'Resume Assistant' : 'Pause Assistant',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
