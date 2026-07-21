import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/design/app_design_system.dart';
import '../../../../../app/auth_provider.dart';
import '../../../../../app/enum/user_role.dart';
import '../../../../../app/app_bar/app_section_bar.dart';
import '../../../../auth/services/image_picker_service.dart';
import '../../../../reviews/presentation/pages/my_reviews_page.dart';
import '../client/client_payment_methods_page.dart';
import '../shared/archives_page.dart';
import '../freelancer/freelancer_activity_page.dart';
import '../freelancer/freelancer_payment_methods_page.dart';
import 'change_password_page.dart';
import 'contact_support_page.dart';
import 'my_information_page.dart';
import '../../../profile_provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFreelancer =
        context.watch<AuthProvider>().currentRole == UserRole.provider;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppSectionBar(pageTitle: 'Mon compte', showRolePill: true),
      body: AppPageBody(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
        useSafeAreaBottom: true,
        child: ListView(
          children: [
            _ProfileHeader(),
            AppGap.h28,
            _FlatSection(
              label: 'Compte',
              children: [
                _FlatTile(
                  icon: Icons.badge_rounded,
                  title: 'Profil & coordonnées',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MyInformationPage(),
                    ),
                  ),
                ),
                if (isFreelancer) ...[
                  _FlatTile(
                    icon: Icons.work_history_rounded,
                    title: 'Tableau de bord',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FreelancerActivityPage(),
                      ),
                    ),
                  ),
                  _FlatTile(
                    icon: Icons.grid_view_rounded,
                    title: 'Mes publications',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const FreelancerActivityPage(initialTab: 1),
                      ),
                    ),
                  ),
                ],
                _FlatTile(
                  icon: Icons.history_rounded,
                  title: 'Missions archivées',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ArchivesPage()),
                  ),
                ),
                _FlatTile(
                  icon: Icons.grade_rounded,
                  title: 'Avis & évaluations',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MyReviewsPage(isFreelancer: isFreelancer),
                    ),
                  ),
                ),
              ],
            ),
            AppGap.h28,
            _FlatSection(
              label: 'Paiements et sécurité',
              children: [
                _FlatTile(
                  icon: Icons.credit_card_rounded,
                  title: 'Portefeuille & paiements',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => isFreelancer
                          ? const FreelancerPaymentMethodsPage()
                          : const ClientPaymentMethodsPage(),
                    ),
                  ),
                ),
                _FlatTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Changer le mot de passe',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordPage(),
                    ),
                  ),
                ),
              ],
            ),
            AppGap.h28,
            _FlatSection(
              label: 'Aide et session',
              children: [
                _FlatTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Aide & support',
                  onTap: () {},
                ),
                _FlatTile(
                  icon: Icons.mail_outline_rounded,
                  title: 'Contacter le support',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ContactSupportPage(),
                    ),
                  ),
                ),
                _FlatTile(
                  icon: Icons.info_outline_rounded,
                  title: 'À propos',
                  onTap: () {},
                ),
                _FlatTile(
                  icon: Icons.logout_rounded,
                  title: 'Déconnexion',
                  showChevron: false,
                  onTap: () async => context.read<AuthProvider>().logout(),
                ),
                _FlatTile(
                  icon: Icons.delete_outline_rounded,
                  title: 'Supprimer le compte',
                  titleColor: context.colors.error,
                  showChevron: false,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DeleteAccountPage(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section label + rows plats ──────────────────────────────────────────────

class _FlatSection extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const _FlatSection({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre de section noir — même langage que les profils publics.
        Text(
          label,
          style: context.text.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
          ),
        ),
        AppGap.h10,
        AppSurfaceCard(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: context.colors.border),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: context.colors.divider,
                    indent: 54,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Ligne de menu ────────────────────────────────────────────────────────────

class _FlatTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? titleColor;
  final bool showChevron;

  const _FlatTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.titleColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = titleColor ?? context.colors.textTertiary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      splashColor: context.colors.primary.withValues(alpha: 0.04),
      highlightColor: context.colors.surfaceAlt,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            AppIconCircle(
              icon: icon,
              size: 34,
              iconSize: 18,
              backgroundColor: titleColor == null
                  ? context.colors.surfaceAlt
                  : context.colors.errorLight,
              iconColor: iconColor,
            ),
            AppGap.w12,
            Expanded(
              child: Text(
                title,
                style: titleColor != null
                    ? context.accountMenuTitleStyle.copyWith(color: titleColor)
                    : context.accountMenuTitleStyle,
              ),
            ),
            if (showChevron)
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: context.colors.textHint,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── En-tête profil ──────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profileProv = context.watch<ProfileProvider>();
    final profile = profileProv.profile;
    final displayName = profile?.fullName.isNotEmpty == true
        ? profile!.fullName
        : 'Utilisateur';
    final avatarUrl = profile?.avatarUrl;
    final isVerified = profile?.isVerified ?? false;
    final isUploading = profileProv.isSaving;

    // Même langage que les profils publics : nom en gros à gauche,
    // avatar à droite.
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.displaySmall,
                ),
                if (profile?.email?.isNotEmpty == true) ...[
                  AppGap.h4,
                  Text(
                    profile!.email!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyMedium?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          AppGap.w16,
          GestureDetector(
            onTap: isUploading ? null : () => _pickAvatar(context, profileProv),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.surfaceAlt,
                    border: Border.all(
                      color: context.colors.border,
                      width: 1.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 46,
                    backgroundColor: Colors.transparent,
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl == null
                        ? Text(
                            displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : '?',
                            style: context.text.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: context.colors.textSecondary,
                            ),
                          )
                        : null,
                  ),
                ),
                if (isUploading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.inkDark.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (!isUploading)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: context.colors.textPrimary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.colors.background,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 14,
                        color: context.colors.background,
                      ),
                    ),
                  ),
                if (isVerified && !isUploading)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: context.colors.background,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        size: 16,
                        color: AppColors.info,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAvatar(
    BuildContext context,
    ProfileProvider profileProv,
  ) async {
    final file = await ImagePickerService.showPicker(context);
    if (file == null) return;
    await profileProv.uploadAvatar(file);
  }
}

// ─── Page suppression de compte ──────────────────────────────────────────────

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => DeleteAccountPageState();
}

class DeleteAccountPageState extends State<DeleteAccountPage> {
  final _controller = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  String? _error;
  bool _confirmed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isGoogleUser && _controller.text.trim().isEmpty) {
      setState(() => _error = 'Entrez votre mot de passe');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final errorMsg = await auth.deleteAccount(_controller.text.trim());
    if (!mounted) return;
    if (errorMsg != null) {
      setState(() {
        _isLoading = false;
        _error = errorMsg;
      });
    } else {
      Navigator.of(context, rootNavigator: true).popUntil((r) => r.isFirst);
    }
  }

  bool get canDelete => _confirmed && !_isLoading;

  @override
  Widget build(BuildContext context) {
    final isGoogleUser = context.read<AuthProvider>().isGoogleUser;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppPageAppBar(
        titleWidget: Text(
          'Supprimer le compte',
          style: context.accountDialogTitleStyle,
        ),
        centerTitle: true,
        leading: AppBackButtonLeading(onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: AppInsets.a24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppDangerBanner(
              title: 'Les données suivantes seront supprimées :',
              items: const [
                'Votre profil et informations personnelles',
                'Vos missions et candidatures',
                'Vos publications et votes',
                'Vos avis et évaluations',
                'Vos messages et conversations',
                'Votre historique de transactions',
              ],
            ),
            AppGap.h24,
            Text(
              isGoogleUser ? 'Confirmation' : 'Confirmez votre identité',
              style: context.text.labelLarge,
            ),
            AppGap.h6,
            Text(
              isGoogleUser
                  ? 'Cochez la case ci-dessous pour confirmer la suppression.'
                  : 'Entrez votre mot de passe pour confirmer.',
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            AppGap.h14,
            if (!isGoogleUser) ...[
              TextField(
                controller: _controller,
                obscureText: _obscure,
                onSubmitted: (_) {
                  if (canDelete) _confirm();
                },
                style: context.text.bodyMedium?.copyWith(
                  fontSize: AppFontSize.body,
                ),
                decoration:
                    AppInputDecorations.formField(
                      context,
                      hintText: 'Mot de passe',
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        size: 20,
                        color: context.colors.textTertiary,
                      ),
                      contentPadding: AppInsets.h16v16,
                    ).copyWith(
                      hintStyle: context.text.bodyLarge?.copyWith(
                        color: context.colors.textHint,
                        fontSize: AppFontSize.base,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          size: 20,
                          color: context.colors.textTertiary,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
              ),
              AppGap.h8,
            ],
            if (_error != null) ...[
              AppErrorMessage(message: _error!),
              AppGap.h8,
            ],
            InkWell(
              onTap: _isLoading
                  ? null
                  : () => setState(() => _confirmed = !_confirmed),
              borderRadius: BorderRadius.circular(AppDesign.radius8),
              child: Padding(
                padding: AppInsets.v4,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _confirmed,
                        onChanged: _isLoading
                            ? null
                            : (v) => setState(() => _confirmed = v ?? false),
                        activeColor: context.colors.error,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDesign.radius4,
                          ),
                        ),
                        side: BorderSide(
                          color: _confirmed
                              ? context.colors.error
                              : context.colors.border,
                          width: 1.5,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    AppGap.w10,
                    Expanded(
                      child: Text(
                        'Je comprends que cette action est définitive et que mes données ne pourront pas être récupérées.',
                        style: context.text.bodyMedium?.copyWith(
                          color: _confirmed
                              ? context.colors.textPrimary
                              : context.colors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppGap.h28,
            AppButton(
              label: 'Supprimer définitivement',
              variant: ButtonVariant.destructive,
              onPressed: (canDelete && _confirmed) ? _confirm : null,
              isLoading: _isLoading,
            ),
            AppGap.h10,
            AppButton(
              label: 'Annuler',
              variant: ButtonVariant.ghost,
              onPressed: _isLoading ? null : () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Mes stories par catégorie ───────────────────────────────────────────────
