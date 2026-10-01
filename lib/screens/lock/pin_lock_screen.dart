import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/security_provider.dart';

class PinLockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;

  const PinLockScreen({Key? key, required this.onUnlocked}) : super(key: key);

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> with SingleTickerProviderStateMixin {
  String _enteredPin = '';
  final int _pinLength = 4;
  bool _isError = false;
  String _errorMessage = '';

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 12.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    // Auto trigger biometric prompt if enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryBiometricUnlock();
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _tryBiometricUnlock() async {
    final secProvider = context.read<SecurityProvider>();
    if (secProvider.isBiometricEnabled) {
      final success = await secProvider.authenticateWithBiometrics(
        reason: 'Authenticate to unlock your ProfileFlow vault',
      );
      if (success && mounted) {
        widget.onUnlocked();
      }
    }
  }

  void _onDigitPressed(String digit) {
    if (_enteredPin.length < _pinLength) {
      setState(() {
        _isError = false;
        _errorMessage = '';
        _enteredPin += digit;
      });

      if (_enteredPin.length == _pinLength) {
        _verifyPin();
      }
    }
  }

  void _onDeletePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _isError = false;
        _errorMessage = '';
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  Future<void> _verifyPin() async {
    final secProvider = context.read<SecurityProvider>();
    final isValid = await secProvider.verifyPin(_enteredPin);

    if (isValid) {
      if (mounted) {
        widget.onUnlocked();
      }
    } else {
      _shakeController.forward(from: 0.0);
      setState(() {
        _isError = true;
        _errorMessage = 'Incorrect PIN. Please try again.';
        _enteredPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secProvider = context.watch<SecurityProvider>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Lock Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Unlock ProfileFlow',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Enter your PIN to access your encrypted profile vault',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),

              const SizedBox(height: 32),

              // PIN Indicator Dots with shake animation
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value * (_isError ? 1 : 0), 0),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pinLength, (index) {
                    final isFilled = index < _enteredPin.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isError
                            ? AppColors.error
                            : (isFilled
                                ? AppColors.primary
                                : (isDark ? AppColors.dividerDark : AppColors.dividerLight)),
                        border: Border.all(
                          color: _isError ? AppColors.error : AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 16),

              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                const SizedBox(height: 18),

              const Spacer(flex: 1),

              // Keypad
              _buildKeypad(secProvider.isBiometricEnabled),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad(bool hasBiometrics) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton('1'),
            _buildKeypadButton('2'),
            _buildKeypadButton('3'),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton('4'),
            _buildKeypadButton('5'),
            _buildKeypadButton('6'),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton('7'),
            _buildKeypadButton('8'),
            _buildKeypadButton('9'),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (hasBiometrics)
              _buildIconButton(
                icon: Icons.fingerprint_rounded,
                onPressed: _tryBiometricUnlock,
                color: AppColors.secondary,
              )
            else
              const SizedBox(width: 72, height: 72),
            _buildKeypadButton('0'),
            _buildIconButton(
              icon: Icons.backspace_outlined,
              onPressed: _onDeletePressed,
              color: AppColors.textSecondaryLight,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadButton(String digit) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: 72,
      height: 72,
      child: Material(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _onDigitPressed(digit),
          child: Center(
            child: Text(
              digit,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(
            child: Icon(icon, size: 30, color: color),
          ),
        ),
      ),
    );
  }
}
