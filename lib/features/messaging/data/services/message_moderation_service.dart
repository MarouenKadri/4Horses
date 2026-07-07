class ModerationResult {
  final bool blocked;
  final String? reason;

  const ModerationResult({required this.blocked, this.reason});

  static const allowed = ModerationResult(blocked: false);
}

class MessageModerationService {
  MessageModerationService._();
  static final MessageModerationService instance = MessageModerationService._();

  // ── Emails ────────────────────────────────────────────────────────────────
  static final _email = RegExp(
    r'[a-zA-Z0-9._%+\-]+\s*@\s*[a-zA-Z0-9.\-]+\s*\.\s*[a-zA-Z]{2,}',
    caseSensitive: false,
  );

  // ── Téléphones français (+33 / 0033 / 0X) ─────────────────────────────────
  static final _phoneFr = RegExp(
    r'(\+\s*33|0{2}\s*33|0)\s*[1-9](\s*[\d]{2}){4}',
    caseSensitive: false,
  );

  // ── Téléphones tunisiens (+216 / 00216 / 2x,5x,9x XXXXXXX) ───────────────
  static final _phoneTn = RegExp(
    r'(\+\s*216|0{2}\s*216|\b[259]\d)\s*[\s.\-]?\d{3}\s*[\s.\-]?\d{3}',
    caseSensitive: false,
  );

  // ── Numéros internationaux génériques (+XX...) ────────────────────────────
  static final _phoneIntl = RegExp(
    r'\+\s*\d{1,3}[\s.\-]?\(?\d{1,4}\)?[\s.\-]?\d{3,5}[\s.\-]?\d{3,5}',
  );

  // ── Suite de chiffres obfusquée (10 chiffres avec séparateurs) ────────────
  static final _phoneRaw = RegExp(r'\b\d[\d\s.\-]{8,}\d\b');

  // ── Apps de messagerie externe ────────────────────────────────────────────
  static final _socialApps = RegExp(
    r'\b(whatsapp|wa\.me|telegram|t\.me|signal|viber|messenger|wechat|skype|snapchat|instagram|tiktok|discord)\b',
    caseSensitive: false,
  );

  // ── Intentions de contact hors plateforme ─────────────────────────────────
  static final _contactIntent = RegExp(
    r'\b(mon\s*(numéro|num|tel|téléphone|portable|mobile|mail|email|adresse)'
    r'|appelle[rz]?[\s\-]*moi|contacte[rz]?[\s\-]*moi'
    r'|écri[st]?\s*(moi|nous)\s*(sur|via|par)'
    r'|envoie[rz]?\s*(moi|nous)\s*(un\s*sms|un\s*message)\s*(sur|via|par)'
    r'|rejoins?\s*moi\s*(sur|via|par)'
    r'|sms|hors\s*(app|application|plateforme))\b',
    caseSensitive: false,
  );

  // ── Providers email ───────────────────────────────────────────────────────
  static final _emailProviders = RegExp(
    r'\b(gmail|yahoo|hotmail|outlook|icloud|proton|live|msn'
    r'|orange|sfr|free|wanadoo|numericable|bouygues)\b',
    caseSensitive: false,
  );

  // ── Adresses physiques ────────────────────────────────────────────────────
  static final _physicalAddress = RegExp(
    r'\b\d+\s*(,?\s*)?(rue|avenue|avenu|av\.|boulevard|blvd|allée|allee|impasse|chemin|place|route|voie)\b',
    caseSensitive: false,
  );

  // ── Liens HTTP/www ────────────────────────────────────────────────────────
  static final _httpLink = RegExp(
    r'(https?://|www\.)\S+',
    caseSensitive: false,
  );

  // ─────────────────────────────────────────────────────────────────────────

  static final _locationMessage = RegExp(r'^📍\s+-?\d+\.\d+,-?\d+\.\d+$');

  ModerationResult check(String text) {
    if (_locationMessage.hasMatch(text)) return ModerationResult.allowed;
    if (_email.hasMatch(text)) {
      return const ModerationResult(
        blocked: true,
        reason: 'Les adresses email ne sont pas autorisées dans le chat.',
      );
    }
    if (_phoneFr.hasMatch(text) ||
        _phoneTn.hasMatch(text) ||
        _phoneIntl.hasMatch(text) ||
        _phoneRaw.hasMatch(text)) {
      return const ModerationResult(
        blocked: true,
        reason: 'Les numéros de téléphone ne sont pas autorisés dans le chat.',
      );
    }
    if (_socialApps.hasMatch(text)) {
      return const ModerationResult(
        blocked: true,
        reason: 'Les contacts via des apps externes ne sont pas autorisés.',
      );
    }
    if (_contactIntent.hasMatch(text)) {
      return const ModerationResult(
        blocked: true,
        reason: 'Les échanges de coordonnées ne sont pas autorisés.',
      );
    }
    if (_emailProviders.hasMatch(text)) {
      return const ModerationResult(
        blocked: true,
        reason: 'Les adresses email ne sont pas autorisées dans le chat.',
      );
    }
    if (_physicalAddress.hasMatch(text)) {
      return const ModerationResult(
        blocked: true,
        reason: 'Les adresses physiques ne sont pas autorisées dans le chat.',
      );
    }
    if (_httpLink.hasMatch(text)) {
      return const ModerationResult(
        blocked: true,
        reason: 'Les liens externes ne sont pas autorisés dans le chat.',
      );
    }
    return ModerationResult.allowed;
  }
}
