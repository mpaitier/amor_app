# Installer Amor sur iPhone

Amor n'est pas sur l'App Store. L'app iOS est publiée dans les [releases GitHub](https://github.com/mpaitier/amor_app/releases) sous forme de fichier `.ipa` non signé. iOS n'installe que des apps signées : c'est donc toi qui la signes, gratuitement, avec ton identifiant Apple, au moyen d'AltStore.

Il te faut :
- un iPhone sous iOS 13 ou plus récent ;
- un PC Windows ou un Mac, sur le même Wi-Fi que l'iPhone ;
- un identifiant Apple (le tien, ou un second créé pour l'occasion) ;
- un câble pour la première installation.

## Première installation

1. **Sur le PC Windows**, installe iTunes et iCloud depuis le site d'Apple (pas les versions du Microsoft Store), puis AltServer depuis [altstore.io](https://altstore.io). Sur Mac, AltServer suffit.
2. Branche l'iPhone, accepte « Faire confiance à cet ordinateur », puis active la synchronisation en Wi-Fi dans iTunes (ou dans le Finder sur Mac). C'est elle qui permettra le renouvellement automatique.
3. Dans l'icône AltServer (barre des tâches ou barre des menus), choisis **Install AltStore**, puis ton iPhone, et entre ton identifiant Apple.
4. **Sur l'iPhone** :
   - Réglages → Général → VPN et gestion de l'appareil : touche ton identifiant Apple, puis « Faire confiance ».
   - Sous iOS 16 ou plus récent : Réglages → Confidentialité et sécurité → Mode développeur, à activer. L'iPhone redémarre.
5. Toujours sur l'iPhone, ouvre la page des releases dans Safari et télécharge le fichier `amor-x.y.z.ipa` de la dernière version. Il arrive dans l'app Fichiers.
6. Ouvre AltStore, onglet **My Apps**, touche **+** et choisis le fichier `.ipa`. Amor apparaît sur l'écran d'accueil.

## Les 7 jours

Une app signée avec un identifiant Apple gratuit expire au bout de 7 jours. Tant qu'AltServer tourne sur le PC et que l'iPhone est sur le même Wi-Fi, AltStore la renouvelle tout seul en arrière-plan. Garde simplement le PC allumé de temps en temps, avec AltServer lancé.

Si l'app a expiré, elle ne s'ouvre plus, mais rien n'est perdu : ouvre AltStore avec le PC allumé et touche **Refresh All**. Ne supprime pas l'app pour la réinstaller, tu perdrais ta session.

## Mettre à jour

Télécharge le nouveau `.ipa` dans les releases et installe-le comme la première fois (**My Apps** → **+**). Il remplace l'ancienne version et garde ta session.

## Ce qui change par rapport à Android

- **Pas de notifications push** : une app signée avec un identifiant Apple gratuit n'y a pas droit. Les souvenirs et dates arrivent normalement à l'ouverture de l'app.
- **Lien d'invitation** : un lien `https://amor-app-9ee55.web.app/join/...` ouvre la page web au lieu de l'app. Entre le code d'invitation à la main dans « Rejoindre la relation ».
- **Trois apps au maximum** installées de cette façon en même temps, AltStore compris.

La connexion avec Google ou par e-mail fonctionne comme sur Android.

## Sans renouvellement automatique : Sideloadly

[Sideloadly](https://sideloadly.io) installe aussi le `.ipa` depuis un PC ou un Mac, sans AltStore sur l'iPhone. En revanche, il faut rebrancher l'iPhone et relancer l'installation tous les 7 jours, avec le même identifiant Apple et sans supprimer l'app pour garder ta session.
