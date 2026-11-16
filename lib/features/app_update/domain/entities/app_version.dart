// ============================================================================
// APP VERSION
// ============================================================================
// Numéro de version au format des tags du dépôt : 1.2.3, avec un "v"
// devant et une préversion facultatifs (v1.0.0-beta.2). Un éventuel
// "+N" (numéro de build) est ignoré.
// La comparaison suit le versionnage sémantique : 1.0.0-beta.1 < 1.0.0-beta.2
// < 1.0.0 < 1.0.1 < 1.1.0. Modèle de domaine pur, sans Flutter.

class AppVersion implements Comparable<AppVersion> {
  final int major;
  final int minor;
  final int patch;

  // --- Morceaux de la préversion : "beta.2" donne ["beta", "2"] ---
  final List<String> prerelease;

  const AppVersion(
    this.major,
    this.minor,
    this.patch, [
    this.prerelease = const [],
  ]);

  static final RegExp _pattern = RegExp(
    r'^v?(\d+)\.(\d+)\.(\d+)(?:-([0-9A-Za-z.-]+))?(?:\+[0-9A-Za-z.-]+)?$',
  );

  // --- Null si le texte n'est pas une version reconnue ---
  static AppVersion? tryParse(String text) {
    final match = _pattern.firstMatch(text.trim());
    if (match == null) return null;

    final prerelease = match.group(4);
    return AppVersion(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      prerelease == null ? const [] : prerelease.split('.'),
    );
  }

  bool get isPrerelease => prerelease.isNotEmpty;

  @override
  int compareTo(AppVersion other) {
    for (final diff in [
      major - other.major,
      minor - other.minor,
      patch - other.patch,
    ]) {
      if (diff != 0) return diff.sign;
    }

    // --- À numéro égal, une préversion passe avant la version finale ---
    if (isPrerelease != other.isPrerelease) return isPrerelease ? -1 : 1;
    return _comparePrerelease(prerelease, other.prerelease);
  }

  // --- Morceau par morceau : les nombres se comparent comme des nombres et
  // --- passent avant les mots ; à début égal, la plus courte passe avant ---
  static int _comparePrerelease(List<String> a, List<String> b) {
    for (var i = 0; i < a.length && i < b.length; i++) {
      final aNumber = int.tryParse(a[i]);
      final bNumber = int.tryParse(b[i]);

      final int diff;
      if (aNumber != null && bNumber != null) {
        diff = aNumber.compareTo(bNumber);
      } else if (aNumber != null) {
        diff = -1;
      } else if (bNumber != null) {
        diff = 1;
      } else {
        diff = a[i].compareTo(b[i]);
      }
      if (diff != 0) return diff.sign;
    }
    return (a.length - b.length).sign;
  }

  bool operator >(AppVersion other) => compareTo(other) > 0;
  bool operator <(AppVersion other) => compareTo(other) < 0;

  @override
  bool operator ==(Object other) {
    return other is AppVersion && compareTo(other) == 0;
  }

  @override
  int get hashCode => Object.hash(major, minor, patch, prerelease.join('.'));

  @override
  String toString() {
    final base = '$major.$minor.$patch';
    return isPrerelease ? '$base-${prerelease.join('.')}' : base;
  }
}
