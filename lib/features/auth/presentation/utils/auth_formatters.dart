// Fonctions utilitaires de masquage partagées dans le module auth.

String friendlyAuthError(String message) {
  if (message.contains('Invalid login credentials')) {
    return 'Email ou mot de passe incorrect';
  }
  if (message.contains('Email not confirmed')) {
    return 'Confirmez votre email avant de vous connecter';
  }
  if (message.contains('User already registered')) {
    return 'Cet email est déjà utilisé';
  }
  if (message.contains('Password should be')) {
    return 'Mot de passe trop court (minimum 8 caractères)';
  }
  return 'Une erreur est survenue';
}

int passwordStrength(String password) {
  if (password.length < 4) return 0;
  int s = 0;
  if (password.length >= 8) s++;
  if (password.contains(RegExp(r'[A-Z]'))) s++;
  if (password.contains(RegExp(r'[0-9]'))) s++;
  if (password.contains(RegExp(r'[!@#\$%^&*]'))) s++;
  return s;
}

bool isPhoneComplete(String phone, int requiredDigits) {
  final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
  return digits.length >= requiredDigits;
}

String maskEmail(String email) {
  if (!email.contains('@')) return email;
  final parts = email.split('@');
  final name = parts[0];
  final domain = parts[1];
  if (name.length <= 2) return email;
  return '${name.substring(0, 2)}${'•' * (name.length - 2)}@$domain';
}

String maskPhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
  if (digits.length < 4) return phone;
  return '+33 ${digits.substring(0, 2)} •• •• •• ${digits.substring(digits.length - 2)}';
}
