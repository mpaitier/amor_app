// ============================================================================
// INVITE CODE
// ============================================================================
// Format des codes d'invitation et des liens qui les portent. Doit rester
// aligné avec functions/couples_logic.js.

// --- Ni 0/O ni 1/I/L : un code se recopie sans hésitation ---
const String inviteCodeAlphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
const int inviteCodeLength = 6;

// --- Domaine Firebase Hosting qui sert la page de secours et le fichier
// --- assetlinks.json des App Links ---
const String inviteLinkHost = 'amor-app-9ee55.web.app';
const String inviteLinkPathPrefix = '/join/';

// --- Majuscules, sans espaces ni tirets. null si ce n'est pas un code ---
String? normalizeInviteCode(String input) {
  final code = input.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
  if (code.length != inviteCodeLength) return null;
  for (final char in code.split('')) {
    if (!inviteCodeAlphabet.contains(char)) return null;
  }
  return code;
}

// --- Lien à partager : https://amor-app-9ee55.web.app/join/K7PQ2A ---
String inviteLinkFor(String code) {
  return 'https://$inviteLinkHost$inviteLinkPathPrefix$code';
}

// --- Code contenu dans un chemin /join/K7PQ2A. null pour tout autre
// --- chemin ou un code mal formé ---
String? inviteCodeFromPath(String path) {
  if (!path.startsWith(inviteLinkPathPrefix)) return null;
  final rest = path.substring(inviteLinkPathPrefix.length).split('/').first;
  return normalizeInviteCode(rest);
}
