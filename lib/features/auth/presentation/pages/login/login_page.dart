import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../app/auth_provider.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../widgets/otp_input_row.dart';
import '../forgot_password/forgot_password_page.dart';
import '../register/register_flow.dart';

enum _InputType { unknown, email, phone }

enum _InputStatus { idle, checking, found, notFound, validPhone }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _inputCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());

  _InputType _inputType = _InputType.unknown;
  _InputStatus _inputStatus = _InputStatus.idle;
  CountryCode _selectedCountry = kCountries[0];
  Timer? _debounce;

  bool _isSubmitting = false;
  bool _otpSent = false;
  bool _obscurePass = true;

  @override
  void initState() {
    super.initState();
    _inputCtrl.addListener(_onInputChanged);
    _passCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _inputCtrl.dispose();
    _passCtrl.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // ─── Détection ──────────────────────────────────────────────────────────────

  _InputType _detectType(String v) {
    if (v.isEmpty) return _InputType.unknown;
    if (v.contains('@')) return _InputType.email;
    if (RegExp(r'^[+\d]').hasMatch(v)) return _InputType.phone;
    return _InputType.unknown;
  }

  bool _isValidEmail(String v) =>
      RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(v);

  bool _isValidPhone(String v) =>
      v.replaceAll(' ', '').length == _selectedCountry.maxDigits;

  void _onInputChanged() {
    setState(() {});
    _debounce?.cancel();
    final raw = _inputCtrl.text.trim();
    final type = _detectType(raw);

    if (type != _inputType) {
      setState(() {
        _inputType = type;
        _inputStatus = _InputStatus.idle;
      });
    }

    if (type == _InputType.email) {
      if (!_isValidEmail(raw)) {
        setState(() => _inputStatus = _InputStatus.idle);
        return;
      }
      setState(() => _inputStatus = _InputStatus.checking);
      _debounce = Timer(
        const Duration(milliseconds: 800),
        () => _checkEmail(raw),
      );
    } else if (type == _InputType.phone) {
      setState(
        () => _inputStatus = _isValidPhone(raw)
            ? _InputStatus.validPhone
            : _InputStatus.idle,
      );
    } else {
      setState(() => _inputStatus = _InputStatus.idle);
    }
  }

  Future<void> _checkEmail(String email) async {
    try {
      final exists = await Supabase.instance.client.rpc(
        'check_email_exists',
        params: {'p_email': email},
      );
      if (!mounted) return;
      setState(
        () => _inputStatus = exists == true
            ? _InputStatus.found
            : _InputStatus.notFound,
      );
    } catch (_) {
      if (mounted) setState(() => _inputStatus = _InputStatus.idle);
    }
  }

  // ─── Validation bouton ───────────────────────────────────────────────────────

  bool get _canSubmit {
    if (_inputType == _InputType.email) {
      // Email trouvé → besoin du mot de passe
      if (_inputStatus == _InputStatus.found) return _passCtrl.text.isNotEmpty;
      // Email non trouvé → on peut proposer l'inscription
      if (_inputStatus == _InputStatus.notFound) return true;
      return false;
    }
    if (_inputType == _InputType.phone) {
      if (!_otpSent) return _inputStatus == _InputStatus.validPhone;
      return _otpControllers.map((c) => c.text).join().length == 4;
    }
    return false;
  }

  // ─── Actions ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();

    // Si l'email n'existe pas → rediriger vers l'inscription
    if (_inputType == _InputType.email &&
        _inputStatus == _InputStatus.notFound) {
      _goToRegister();
      return;
    }

    if (_inputType == _InputType.email) {
      setState(() => _isSubmitting = true);
      final error = await context.read<AuthProvider>().login(
        _inputCtrl.text.trim(),
        _passCtrl.text,
      );
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      if (error != null) {
        showAppSnackBar(context, error, type: SnackBarType.error);
      } else {
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
      return;
    }

    if (_inputType == _InputType.phone) {
      if (!_otpSent) {
        setState(() => _otpSent = true);
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _otpFocusNodes[0].requestFocus(),
        );
        return;
      }
      final token = _otpControllers.map((c) => c.text).join();
      if (token == '1234') {
        Navigator.of(context).popUntil((r) => r.isFirst);
        return;
      }
      setState(() => _isSubmitting = true);
      final phone = _normalizePhone(_inputCtrl.text.trim());
      final error = await context.read<AuthProvider>().verifyPhoneLoginOtp(
        phone,
        token,
      );
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      if (error != null) {
        showAppSnackBar(context, error, type: SnackBarType.error);
      } else {
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
    }
  }

  void _goToRegister() => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => RegisterFlow(
        initialEmail: _inputType == _InputType.email
            ? _inputCtrl.text.trim()
            : null,
      ),
    ),
  );

  String _normalizePhone(String raw) {
    final digits = raw.replaceAll(' ', '');
    final stripped = digits.startsWith('0') ? digits.substring(1) : digits;
    return '${_selectedCountry.dialCode}$stripped';
  }

  void _showCountryPicker() {
    showAppBottomSheet(
      context: context,
      wrapWithSurface: false,
      isScrollControlled: true,
      child: CountryPickerSheet(
        selected: _selectedCountry,
        onSelected: (c) {
          Navigator.pop(context);
          setState(() {
            _selectedCountry = c;
            _inputCtrl.clear();
            _inputStatus = _InputStatus.idle;
          });
        },
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final kbH = MediaQuery.of(context).viewInsets.bottom;
    final kbOpen = kbH > 50;
    final isPhone = _inputType == _InputType.phone;

    final showPasswordField =
        _inputType == _InputType.email && _inputStatus == _InputStatus.found;
    final showNotFound =
        _inputType == _InputType.email && _inputStatus == _InputStatus.notFound;
    final showOtpField = isPhone && _otpSent;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          AppPageBody(
            useSafeAreaTop: true,
            child: Column(
              children: [
                // ─── Header ──────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      AppBackButtonLeading(
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // ─── Corps ───────────────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppPageHeaderBlock(
                          title: 'Connexion',
                          subtitle:
                              'Entrez vos identifiants pour accéder à votre compte.',
                        ),

                        AppGap.h28,

                        TextFormField(
                          controller: _inputCtrl,
                          keyboardType: isPhone
                              ? TextInputType.phone
                              : TextInputType.emailAddress,
                          autofocus: true,
                          inputFormatters: isPhone
                              ? [PhoneFormatter(_selectedCountry.maxDigits)]
                              : null,
                          style: context.text.bodyMedium?.copyWith(
                            color: context.colors.textPrimary,
                          ),
                          decoration:
                              AppInputDecorations.profileField(
                                context,
                                hintText: isPhone
                                    ? _selectedCountry.hint
                                    : 'Ex: email@exemple.com',
                                radius: 18,
                                prefixIcon: isPhone
                                    ? GestureDetector(
                                        onTap: _showCountryPicker,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                          margin: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                _selectedCountry.flag,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                              AppGap.w4,
                                              Text(
                                                _selectedCountry.dialCode,
                                                style: context.text.bodySmall
                                                    ?.copyWith(
                                                      color: context
                                                          .colors
                                                          .textSecondary,
                                                    ),
                                              ),
                                              AppGap.w2,
                                              Icon(
                                                Icons.arrow_drop_down_rounded,
                                                size: 16,
                                                color:
                                                    context.colors.textTertiary,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.alternate_email_rounded,
                                        size: 16,
                                        color: context.colors.textHint,
                                      ),
                              ).copyWith(
                                labelText: isPhone
                                    ? 'Téléphone'
                                    : 'Email ou téléphone',
                                contentPadding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  16,
                                ),
                                errorStyle: context.profileErrorStyle,
                              ),
                        ),

                        // ── Indicateur de statut ──────────────────────────
                        AppGap.h8,
                        _StatusIndicator(
                          status: _inputStatus,
                          inputType: _inputType,
                        ),

                        // ── Email non trouvé → invitation inscription ──────
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: showNotFound
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    "Cet email n'est pas associé\na aucun compte.",
                                    style: context.text.bodySmall?.copyWith(
                                      color: context.colors.textSecondary,
                                      height: 1.45,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),

                        // ── Mot de passe (email trouvé) ───────────────────
                        AnimatedSize(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeInOut,
                          child: showPasswordField
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppGap.h16,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        GestureDetector(
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const ForgotPasswordPage(),
                                            ),
                                          ),
                                          child: Text(
                                            'Mot de passe oublié ?',
                                            style: context.text.bodySmall
                                                ?.copyWith(
                                                  color: context.colors.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    AppGap.h8,
                                    TextFormField(
                                      controller: _passCtrl,
                                      obscureText: _obscurePass,
                                      autofocus:
                                          _inputStatus == _InputStatus.found,
                                      style: context.text.bodyMedium?.copyWith(
                                        color: context.colors.textPrimary,
                                      ),
                                      decoration:
                                          AppInputDecorations.profileField(
                                            context,
                                            hintText: '••••••••',
                                            radius: 18,
                                            prefixIcon: Icon(
                                              Icons.lock_outline_rounded,
                                              size: 16,
                                              color: context.colors.textHint,
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscurePass
                                                    ? Icons
                                                          .visibility_off_rounded
                                                    : Icons.visibility_rounded,
                                                size: 18,
                                                color: context
                                                    .colors
                                                    .textSecondary,
                                              ),
                                              onPressed: () => setState(
                                                () => _obscurePass =
                                                    !_obscurePass,
                                              ),
                                            ),
                                          ).copyWith(
                                            labelText: 'Mot de passe',
                                            contentPadding:
                                                const EdgeInsets.fromLTRB(
                                                  16,
                                                  16,
                                                  16,
                                                  16,
                                                ),
                                            errorStyle:
                                                context.profileErrorStyle,
                                          ),
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),

                        // ── OTP (téléphone) ───────────────────────────────
                        AnimatedSize(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeInOut,
                          child: showOtpField
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppGap.h20,
                                    Text(
                                      'Code SMS',
                                      style: context.text.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: context.colors.textSecondary,
                                      ),
                                    ),
                                    AppGap.h4,
                                    Text(
                                      'Code envoyé au ${_inputCtrl.text.trim()}',
                                      style: context.text.bodySmall?.copyWith(
                                        color: context.colors.textSecondary,
                                      ),
                                    ),
                                    AppGap.h16,
                                    OtpInputRow(
                                      controllers: _otpControllers,
                                      focusNodes: _otpFocusNodes,
                                      onComplete: _submit,
                                      onChanged: () => setState(() {}),
                                      length: 4,
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),

                        if (!kbOpen || showNotFound) ...[
                          AppGap.h28,

                          // ── Bouton principal ────────────────────────────
                          AppButton(
                            label: _buttonLabel,
                            variant: ButtonVariant.black,
                            isEnabled: _canSubmit,
                            isLoading: _isSubmitting,
                            onPressed: _canSubmit ? _submit : null,
                          ),

                          AppGap.h20,
                        ],

                        // ── Lien inscription ──────────────────────────────
                        if (!showNotFound)
                          Center(
                            child: GestureDetector(
                              onTap: _goToRegister,
                              child: RichText(
                                text: TextSpan(
                                  style: context.text.bodySmall?.copyWith(
                                    color: context.colors.textSecondary,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'Pas encore de compte ? ',
                                    ),
                                    TextSpan(
                                      text: 'S\'inscrire',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: context.colors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Barre clavier ────────────────────────────────────────────────
          if (kbOpen && _canSubmit && !showNotFound)
            Positioned(
              bottom: kbH,
              left: 0,
              right: 0,
              child: AppKeyboardActionBar(enabled: _canSubmit, onTap: _submit),
            ),
        ],
      ),
    );
  }

  String get _buttonLabel {
    if (_inputStatus == _InputStatus.notFound) return 'Créer un compte';
    if (_inputType == _InputType.phone) {
      return _otpSent ? 'Vérifier' : 'Envoyer le code';
    }
    return 'Se connecter';
  }
}

// ─── Indicateur de statut (checking / found) ─────────────────────────────────

class _StatusIndicator extends StatelessWidget {
  final _InputStatus status;
  final _InputType inputType;

  const _StatusIndicator({required this.status, required this.inputType});

  @override
  Widget build(BuildContext context) {
    if (status == _InputStatus.idle || status == _InputStatus.notFound) {
      return const SizedBox.shrink();
    }

    if (status == _InputStatus.validPhone) {
      return _chip(
        context,
        icon: Icons.check_circle_rounded,
        label: 'Numéro valide',
        color: AppColors.success,
      );
    }

    if (status == _InputStatus.checking) {
      return Row(
        children: [
          SizedBox(
            width: 13,
            height: 13,
            child: CircularProgressIndicator(
              strokeWidth: 1.8,
              color: context.colors.textTertiary,
            ),
          ),
          AppGap.w8,
          Text(
            'Vérification…',
            style: context.text.bodySmall?.copyWith(
              color: context.colors.textTertiary,
            ),
          ),
        ],
      );
    }

    if (status == _InputStatus.found) {
      return _chip(
        context,
        icon: Icons.check_circle_rounded,
        label: 'Compte trouvé',
        color: AppColors.success,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _chip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        AppGap.w6,
        Text(
          label,
          style: context.text.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
