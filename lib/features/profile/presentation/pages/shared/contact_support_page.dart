import 'package:flutter/material.dart';
import '../../../../../core/design/app_design_system.dart';

class ContactSupportPage extends StatefulWidget {
  const ContactSupportPage({super.key});

  @override
  State<ContactSupportPage> createState() => _ContactSupportPageState();
}

class _ContactSupportPageState extends State<ContactSupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _sujetCtrl = TextEditingController();
  final _objetCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  static const _sujetOptions = [
    'Problème technique',
    'Question sur une mission',
    'Problème de paiement',
    'Signaler un utilisateur',
    'Demande sur informations personnelles',
    'Autre',
  ];

  @override
  void dispose() {
    _sujetCtrl.dispose();
    _objetCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _pickSujet() {
    showAppBottomSheet(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              'Sujet',
              style: context.text.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
            ),
          ),
          Divider(height: 1, color: context.colors.divider),
          ..._sujetOptions.map((option) {
            final selected = _sujetCtrl.text == option;
            return InkWell(
              onTap: () {
                setState(() => _sujetCtrl.text = option);
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: context.text.bodyLarge?.copyWith(
                          color: selected
                              ? context.colors.textPrimary
                              : context.colors.textSecondary,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (selected)
                      Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: context.colors.textPrimary,
                      ),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _sent = true;
    });
    showAppSnackBar(
      context,
      'Message envoyé. Nous vous répondrons sous 24h.',
      type: SnackBarType.success,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
        titleWidget: Text(
          'Contacter le support',
          style: context.profilePageTitleStyle,
        ),
      ),
      bottomNavigationBar: AppActionFooter(
        child: AppButton(
          label: 'Envoyer',
          onPressed: (_isLoading || _sent) ? null : _submit,
          isLoading: _isLoading,
          variant: ButtonVariant.black,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 116),
          children: [
            _SupportField(
              controller: _sujetCtrl,
              label: 'Sujet',
              hintText: 'Choisir un sujet',
              prefixIcon: Icons.label_outline_rounded,
              readOnly: true,
              onTap: _pickSujet,
              suffixIcon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: context.colors.textHint,
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Veuillez choisir un sujet' : null,
            ),
            AppGap.h16,
            _SupportField(
              controller: _objetCtrl,
              label: 'Objet',
              hintText: 'Titre de votre message',
              prefixIcon: Icons.short_text_rounded,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
            ),
            AppGap.h16,
            _SupportField(
              controller: _messageCtrl,
              label: 'Message',
              hintText: 'Décrivez votre problème en détail…',
              prefixIcon: Icons.chat_bubble_outline_rounded,
              maxLines: 6,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Champ requis';
                if (v.trim().length < 20) return 'Minimum 20 caractères';
                return null;
              },
            ),
            AppGap.h16,
            _InlineHelper(
              text:
                  'Notre équipe vous répondra par email sous 24 heures ouvrées.',
            ),
            AppGap.h20,
            _InfoCard(),
          ],
        ),
      ),
    );
  }
}

// ── Champ réutilisable ────────────────────────────────────────────────────────

class _SupportField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final int maxLines;
  final String? Function(String?)? validator;

  const _SupportField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(
        fontSize: AppFontSize.body,
        fontWeight: FontWeight.w400,
        color: context.colors.textPrimary,
      ),
      decoration: AppInputDecorations.profileField(
        context,
        hintText: hintText,
        radius: 18,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(prefixIcon, size: 16, color: context.colors.textHint),
        ),
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.fromLTRB(
          0,
          maxLines > 1 ? 14 : 16,
          16,
          maxLines > 1 ? 14 : 16,
        ),
      ).copyWith(labelText: label, errorStyle: context.profileErrorStyle),
    );
  }
}

// ── Helper inline ─────────────────────────────────────────────────────────────

class _InlineHelper extends StatelessWidget {
  final String text;
  const _InlineHelper({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.text.bodyMedium?.copyWith(
        color: context.colors.textSecondary,
        height: 1.45,
      ),
    );
  }
}

// ── Carte info canaux de contact ──────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppInsets.a14,
      decoration: BoxDecoration(
        color: context.colors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppDesign.radius12),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Autres canaux',
            style: context.text.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          AppGap.h10,
          _channel(context, Icons.mail_outline_rounded, 'support@inkern.com'),
          AppGap.h6,
          _channel(
            context,
            Icons.access_time_rounded,
            'Lun – Ven, 9h – 18h (heure de Tunis)',
          ),
        ],
      ),
    );
  }

  Widget _channel(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.colors.textSecondary),
        AppGap.w8,
        Text(text, style: context.text.bodySmall),
      ],
    );
  }
}
