# Amor

Journal de souvenirs pour les couples, en Flutter et Firebase. Chaque membre de la relation ajoute des souvenirs (photos, lieu, GIF), les dates qui comptent, et tout le monde voit les ajouts des autres en temps réel.

Amor est la réécriture en Flutter d'une première version Android en Kotlin, qui stockait ses données dans un dépôt GitHub et ses images sur un hébergeur externe. Tout passe maintenant par Firebase.

## Installer l'app

Les versions publiées sont dans les [releases](https://github.com/mpaitier/amor_app/releases).

**Android** : télécharge `amor-x.y.z.apk` sur le téléphone et ouvre-le. Android demande d'autoriser l'installation depuis le navigateur ou le gestionnaire de fichiers la première fois.

**iOS** : l'app n'est pas sur l'App Store. La release contient un `amor-x.y.z.ipa` non signé, à signer avec ton propre identifiant Apple au moment de l'installation (AltStore ou Sideloadly). Les étapes et les limites, notamment l'absence de notifications push, sont dans le guide **[Installer Amor sur iPhone](docs/installation-ios.md)**.

## Fonctionnalités

- Journal des souvenirs : titre, description, date, lieu (autocomplétion Geoapify), plusieurs photos, GIF. Visionneuse d'images en plein écran, avec glissement et navigation en boucle.
- Calendrier à défilement continu, avec la photo de couverture des souvenirs dans les cases.
- Dates importantes : récurrence annuelle, emoji, couleurs de la case, GIF.
- Anniversaire de la relation et mois-anniversaires dans le calendrier, avec un GIF tiré au hasard ou choisi par lien GIPHY.
- Comptes Google ou e-mail. Une relation peut réunir deux personnes ou plus, qui rejoignent par lien ou par code d'invitation. Chacun choisit son surnom et sa couleur, qui identifient l'auteur de chaque souvenir.
- Notifications push (Android) pour les nouveaux souvenirs et les jours spéciaux, réglables par appareil.
- Fenêtre à l'ouverture quand une nouvelle version est publiée dans les releases GitHub, avec le lien de téléchargement de l'APK ou de l'`.ipa`.
- Fin de relation d'un commun accord, suppression du compte dans l'app ou sur [la page web](https://amor-app-9ee55.web.app/delete-account), et suppression automatique après un an sans activité.

## Stack

- **App** : Flutter 3.47.5, Dart 3, `provider`, GoRouter.
- **Firebase** : Auth, Firestore, Storage, Cloud Functions v2 (Node.js 24), Cloud Messaging, Hosting (lien d'invitation, page de suppression de compte, `assetlinks.json`).
- **Services externes** : GIPHY (GIF), Geoapify (lieux).
- **Tests** : `flutter_test`, `mocktail`, `fake_cloud_firestore` ; `node --test` pour les fonctions.

## Architecture

Clean Architecture et MVVM, découpées par fonctionnalité :

```
lib/
├── core/            thème, session de la relation, utilitaires
├── shared/          widgets partagés
├── navigation/      routes GoRouter
├── features/
│   └── <fonctionnalité>/
│       ├── domain/        entités, contrats de dépôts, use cases (Dart pur)
│       ├── data/          modèles Firestore, sources de données, dépôts
│       └── presentation/  ViewModels (ChangeNotifier), écrans, composants
├── injection_container.dart   assemblage des dépendances
└── main.dart
```

Les fonctionnalités : `auth`, `couple`, `timeline`, `calendar`, `important_dates`, `settings`, `gif`, `place`, `notifications`, `navigation`, `color_history`.

Les écrans sont découpés en petits composants qui reçoivent leurs données et leurs callbacks. Seuls les écrans et quelques connecteurs lisent les ViewModels.

Les données d'une relation sont rangées sous `couples/{coupleId}/` dans Firestore (souvenirs, dates importantes, réglages) et sous `couples/{coupleId}/events/` dans Storage. Les règles (`firestore.rules`, `storage.rules`) réservent l'accès aux membres.

## Lancer le projet

Il faut Flutter 3.47.5 et un accès au projet Firebase `amor-app-9ee55`. Ces fichiers restent hors du dépôt et sont à créer en local :

| Fichier | Contenu |
| --- | --- |
| `lib/firebase_options.dart` | généré par `flutterfire configure` (Android et iOS) |
| `android/app/google-services.json` | téléchargé depuis la console Firebase |
| `.env` | `GIPHY_API_KEY=...` et `GEOAPIFY_API_KEY=...` |

```powershell
flutter pub get
flutter run
```

### Cloud Functions

```powershell
cd functions
npm ci
npm test
$env:FUNCTIONS_DISCOVERY_TIMEOUT = "60"
firebase deploy --only functions
```

Le délai de découverte est relevé parce que l'analyse des fonctions dépasse parfois le délai par défaut de la CLI Firebase.

## Tests

```powershell
flutter analyze
flutter test
```

## CI/CD

- `ci.yml`, à chaque pull request et sur `main` : analyse, tests avec couverture, tests des fonctions, puis builds Android et iOS sans signature pour vérifier que tout compile.
- `release.yml`, sur un tag `v*` : APK et AAB signés, release GitHub avec des notes générées à partir des PR, puis ajout de l'`.ipa` iOS non signé.

## Versions

`v1.0.0` sera la première version publiée sur le Play Store. Ensuite, une fonctionnalité fait monter la version mineure (`v1.1.0`) et un correctif la version de patch (`v1.0.1`). Le tag doit correspondre à la version de `pubspec.yaml`, et un tag avec un tiret (`v1.0.0-beta.1`) donne une préversion.

## Crédits

GIF fournis par [GIPHY](https://giphy.com). Recherche de lieux par [Geoapify](https://www.geoapify.com).

## Confidentialité

La [politique de confidentialité](https://amor-app-9ee55.web.app/privacy) décrit les données enregistrées, les services tiers et la suppression du compte. Sa source est `hosting/public/privacy.html` ; elle est aussi accessible dans l'app, dans Paramètres → Compte.

## Licence

Code distribué sous licence [MIT](LICENSE). Les clés d'API et la configuration Firebase ne font pas partie du dépôt : une copie du code doit utiliser son propre projet Firebase et ses propres clés GIPHY et Geoapify.
