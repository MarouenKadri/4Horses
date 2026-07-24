class ModerationResult {
  final bool blocked;
  final String? reason;

  const ModerationResult({required this.blocked, this.reason});

  static const allowed = ModerationResult(blocked: false);
}

/// Filtrage anti-fuite de coordonnées (email, téléphone, apps externes).
///
/// Toutes les vérifications travaillent sur un texte **normalisé** :
/// minuscules, accents retirés, chiffres Unicode (arabes, pleine chasse,
/// mathématiques) convertis en ASCII, caractères invisibles supprimés,
/// lettre « o » collée à des chiffres traitée comme un zéro, et nombres
/// en toutes lettres (« zero six douze… ») convertis en chiffres.
///
/// La détection « numéro fractionné » garde une fenêtre glissante des
/// derniers messages purement numériques par conversation : envoyer
/// « 06 12 » puis « 34 56 » puis « 78 » est bloqué au 3ᵉ message.
class MessageModerationService {
  MessageModerationService._();
  static final MessageModerationService instance = MessageModerationService._();

  static const _msgEmail =
      'Les adresses email ne sont pas autorisées dans le chat.';
  static const _msgPhone =
      'Les numéros de téléphone ne sont pas autorisés dans le chat.';
  static const _msgApps =
      'Les contacts via des apps externes ne sont pas autorisés.';
  static const _msgIntent =
      'Les échanges de coordonnées ne sont pas autorisés.';
  static const _msgAddress =
      'Les adresses physiques ne sont pas autorisées dans le chat.';
  static const _msgLink =
      'Les liens externes ne sont pas autorisés dans le chat.';
  static const _msgSplit =
      'Les coordonnées partagées en plusieurs messages ne sont pas autorisées.';

  // ── Emails ────────────────────────────────────────────────────────────────
  static final _email = RegExp(
    r'[a-z0-9._%+\-]+\s*@\s*[a-z0-9.\-]+\s*\.\s*[a-z]{2,}',
  );

  /// Obfuscations : « arobase », « (at) », « [at] », « point com »…
  static final _emailObfuscated = RegExp(
    r'\barobase\b|[\(\[]\s*(at|arobase)\s*[\)\]]|\bpoint\s*(com|net|org|fr|tn|io|co)\b',
  );

  // ── Téléphones français (+33 / 0033 / 0X) ─────────────────────────────────
  static final _phoneFr = RegExp(
    r'(\+\s*33|0{2}\s*33|0)\s*[1-9](\s*[\d]{2}){4}',
  );

  // ── Téléphones tunisiens (+216 / 00216 / 2x,5x,9x XXXXXXX) ───────────────
  static final _phoneTn = RegExp(
    r'(\+\s*216|0{2}\s*216|\b[259]\d)\s*[\s.\-]?\d{3}\s*[\s.\-]?\d{3}',
  );

  // ── Numéros internationaux génériques (+XX...) ────────────────────────────
  static final _phoneIntl = RegExp(
    r'\+\s*\d{1,3}[\s.\-]?\(?\d{1,4}\)?[\s.\-]?\d{3,5}[\s.\-]?\d{3,5}',
  );

  // ── Suite de chiffres obfusquée (10 chiffres avec séparateurs) ────────────
  static final _phoneRaw = RegExp(r'\b\d[\d\s.\-]{8,}\d\b');

  // ── Apps externes : noms longs, matchés sur le texte « écrasé »
  //    (séparateurs retirés) pour attraper « w h a t s a p p »,
  //    « w.h.a.t.s.a.p.p », etc. ──────────────────────────────────────────────
  static const _squeezedApps = [
    'whatsapp',
    'whatsap',
    'watsapp',
    'watsap',
    'wattsapp',
    'telegram',
    'telegramme',
    'snapchat',
    'instagram',
    'facebook',
    'messenger',
    'discord',
    'wechat',
    'tiktok',
    'linkedin',
    'viber',
    'skype',
  ];

  // ── Apps externes : alias courts, avec frontières de mots ─────────────────
  static final _shortApps = RegExp(
    r'\b(wa\.?me|t\.?me|insta|ig|snap|tg|fb|imo|botim|wapp|wtsp|signal|twitter)\b',
  );

  // ── Intentions de contact hors plateforme (texte déaccentué) ──────────────
  static final _contactIntent = RegExp(
    r'\b(mon\s*(numero|num|tel|telephone|portable|mobile|mail|email|adresse)'
    r'|appelle[rz]?[\s\-]*moi|contacte[rz]?[\s\-]*moi'
    r'|ecri[st]?\s*(moi|nous)\s*(sur|via|par)'
    r'|envoie[rz]?\s*(moi|nous)\s*(un\s*sms|un\s*message)\s*(sur|via|par)'
    r'|rejoins?\s*moi\s*(sur|via|par)'
    r'|sms|hors\s*(app|application|plateforme))\b',
  );

  // ── Providers email ───────────────────────────────────────────────────────
  static final _emailProviders = RegExp(
    r'\b(gmail|yahoo|hotmail|outlook|icloud|proton|protonmail|live|msn|gmx'
    r'|laposte|orange|sfr|free|wanadoo|numericable|bouygues)\b',
  );

  // ── Adresses physiques ────────────────────────────────────────────────────
  static final _physicalAddress = RegExp(
    r'\b\d+\s*(,?\s*)?(rue|avenue|avenu|av\.|boulevard|blvd|allee|impasse|chemin|place|route|voie)\b',
  );

  // ── Liens HTTP/www ────────────────────────────────────────────────────────
  static final _httpLink = RegExp(r'(https?://|www\.)\S+');

  // ── Nombres en toutes lettres → chiffres ──────────────────────────────────
  static const _numberWords = {
    'zero': '0',
    'un': '1',
    'deux': '2',
    'trois': '3',
    'quatre': '4',
    'cinq': '5',
    'six': '6',
    'sept': '7',
    'huit': '8',
    'neuf': '9',
    'dix': '10',
    'onze': '11',
    'douze': '12',
    'treize': '13',
    'quatorze': '14',
    'quinze': '15',
    'seize': '16',
    'vingt': '20',
    'trente': '30',
    'quarante': '40',
    'cinquante': '50',
    'soixante': '60',
  };
  static final _numberWordPattern = RegExp(
    '\\b(${_numberWords.keys.join('|')})\\b',
  );

  static final _locationMessage = RegExp(r'^📍\s+-?\d+\.\d+,-?\d+\.\d+$');

  // ── Fenêtre glissante anti-fractionnement ─────────────────────────────────
  static const _splitWindow = Duration(minutes: 10);
  static const _splitDigitThreshold = 9;
  final Map<String, List<_DigitFragment>> _recentFragments = {};

  /// Vérifie [text]. Passer [conversationId] active la détection des numéros
  /// fractionnés sur plusieurs messages ; [recordFragment] doit être `true`
  /// uniquement sur le chemin d'envoi réel (pas la frappe en direct) pour
  /// mémoriser les fragments numériques.
  ModerationResult check(
    String text, {
    String? conversationId,
    bool recordFragment = false,
  }) {
    if (_locationMessage.hasMatch(text)) return ModerationResult.allowed;

    final norm = _normalize(text);
    final digitized = _digitizeWords(norm);
    final squeezed = norm.replaceAll(RegExp(r'[^a-z0-9]+'), '');

    if (_email.hasMatch(norm) || _emailObfuscated.hasMatch(norm)) {
      return const ModerationResult(blocked: true, reason: _msgEmail);
    }
    if (_phoneFr.hasMatch(digitized) ||
        _phoneTn.hasMatch(digitized) ||
        _phoneIntl.hasMatch(digitized) ||
        _phoneRaw.hasMatch(digitized)) {
      return const ModerationResult(blocked: true, reason: _msgPhone);
    }
    if (_squeezedApps.any(squeezed.contains) || _shortApps.hasMatch(norm)) {
      return const ModerationResult(blocked: true, reason: _msgApps);
    }
    if (_contactIntent.hasMatch(norm)) {
      return const ModerationResult(blocked: true, reason: _msgIntent);
    }
    if (_emailProviders.hasMatch(norm)) {
      return const ModerationResult(blocked: true, reason: _msgEmail);
    }
    if (_physicalAddress.hasMatch(norm)) {
      return const ModerationResult(blocked: true, reason: _msgAddress);
    }
    if (_httpLink.hasMatch(norm)) {
      return const ModerationResult(blocked: true, reason: _msgLink);
    }

    // ── Numéro fractionné : messages purement numériques cumulés ────────────
    if (conversationId != null) {
      final compact = digitized.replaceAll(RegExp(r'[\s.\-_,;:()/]+'), '');
      final isPureDigits = RegExp(r'^\d{2,8}$').hasMatch(compact);
      if (isPureDigits) {
        final now = DateTime.now();
        final fragments = _recentFragments[conversationId] ?? [];
        fragments.removeWhere((f) => now.difference(f.at) > _splitWindow);
        final combined =
            fragments.fold(0, (sum, f) => sum + f.length) + compact.length;
        if (combined >= _splitDigitThreshold) {
          _recentFragments[conversationId] = fragments;
          return const ModerationResult(blocked: true, reason: _msgSplit);
        }
        if (recordFragment) {
          fragments.add(_DigitFragment(now, compact.length));
          _recentFragments[conversationId] = fragments;
        }
      }
    }

    return ModerationResult.allowed;
  }

  /// Minuscules, déaccentuation, chiffres Unicode → ASCII, caractères
  /// invisibles supprimés, « o » en contexte numérique → « 0 ».
  String _normalize(String text) {
    final buf = StringBuffer();
    for (final rune in text.runes) {
      // Chiffres arabes-indiens ٠-٩
      if (rune >= 0x0660 && rune <= 0x0669) {
        buf.writeCharCode(0x30 + rune - 0x0660);
        continue;
      }
      // Chiffres persans ۰-۹
      if (rune >= 0x06F0 && rune <= 0x06F9) {
        buf.writeCharCode(0x30 + rune - 0x06F0);
        continue;
      }
      // Chiffres pleine chasse ０-９
      if (rune >= 0xFF10 && rune <= 0xFF19) {
        buf.writeCharCode(0x30 + rune - 0xFF10);
        continue;
      }
      // Chiffres mathématiques 𝟎-𝟡 (gras, double, sans-serif, mono…)
      if (rune >= 0x1D7CE && rune <= 0x1D7FF) {
        buf.writeCharCode(0x30 + (rune - 0x1D7CE) % 10);
        continue;
      }
      // Caractères invisibles / de contrôle de mise en forme
      if (rune == 0x200B ||
          rune == 0x200C ||
          rune == 0x200D ||
          rune == 0x2060 ||
          rune == 0xFEFF ||
          rune == 0x00AD) {
        continue;
      }
      buf.writeCharCode(rune);
    }

    var s = buf.toString().toLowerCase();

    const accents = 'àâäáãåéèêëíìîïóòôöõúùûüýÿçñ';
    const plain = 'aaaaaaeeeeiiiiooooouuuuyycn';
    for (var i = 0; i < accents.length; i++) {
      s = s.replaceAll(accents[i], plain[i]);
    }

    // « o » utilisé comme zéro : O6 12…, 06 12 34 56 7o
    s = s.replaceAll(RegExp(r'o(?=[\s.\-]*\d)'), '0');
    s = s.replaceAllMapped(RegExp(r'(\d[\s.\-]*)o'), (m) => '${m[1]}0');
    return s;
  }

  /// « zero six douze trente quatre… » → « 0 6 12 30 4… », pour que les
  /// regex téléphone attrapent aussi les nombres en toutes lettres.
  String _digitizeWords(String norm) {
    return norm.replaceAllMapped(
      _numberWordPattern,
      (m) => _numberWords[m[1]]!,
    );
  }
}

class _DigitFragment {
  final DateTime at;
  final int length;
  const _DigitFragment(this.at, this.length);
}
