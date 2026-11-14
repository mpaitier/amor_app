// ============================================================================
// MIGRATION DES DONNÉES VERS UNE RELATION
// ============================================================================
// Copie les anciennes collections globales dans couples/{coupleId}/ :
// - timeline_events          -> couples/{coupleId}/timeline_events
//   ("who" remplacé par creatorUid, images copiées dans Storage sous
//   couples/{coupleId}/ et liens réécrits)
// - important_dates          -> couples/{coupleId}/important_dates
// - app_settings/couple      -> couples/{coupleId}/settings/general
//
// Les identifiants des documents sont conservés. Rien n'est supprimé : les
// anciennes données restent en place jusqu'au nettoyage, à lancer à part une
// fois la migration vérifiée dans l'app.
//
// Sans --apply, le script ne fait que décrire ce qu'il ferait. Une
// sauvegarde JSON des anciennes données est écrite dans backups/ à chaque
// lancement.
//
// Utilisation (depuis tools/migration, après npm install) :
//   node migrate_to_couple.js --couple=<coupleId> --map=Titi:<uid>,Lulu:<uid>
//   node migrate_to_couple.js --couple=<coupleId> --map=Titi:<uid>,Lulu:<uid> --apply
//   node migrate_to_couple.js --cleanup --report=backups/report-....json
//   node migrate_to_couple.js --cleanup --report=backups/report-....json --apply
//
// Identifiants : variable d'environnement GOOGLE_APPLICATION_CREDENTIALS
// pointant vers la clé JSON d'un compte de service du projet.

const fs = require("node:fs");
const path = require("node:path");
const { randomUUID } = require("node:crypto");
const { initializeApp, applicationDefault } = require("firebase-admin/app");
const { getFirestore, FieldValue, Timestamp } = require("firebase-admin/firestore");
const { getStorage } = require("firebase-admin/storage");
const {
  parseAuthorMap,
  parseArgs,
  parseStorageUrl,
  targetStoragePath,
  downloadUrl,
  splitImageUrls,
  migratedEventData,
} = require("./migration_logic");

const PROJECT_ID = "amor-app-9ee55";
const DEFAULT_BUCKET = "amor-app-9ee55.firebasestorage.app";
const BACKUP_DIR = path.join(__dirname, "backups");

// ============================================================================
// OUTILS
// ============================================================================

function log(message) {
  console.log(message);
}

function stamp() {
  return new Date().toISOString().replace(/[:.]/g, "-");
}

// --- Valeurs Firestore -> JSON lisible (dates en ISO) ---
function toJson(value) {
  if (value instanceof Timestamp) return { __timestamp: value.toDate().toISOString() };
  if (Array.isArray(value)) return value.map(toJson);
  if (value && typeof value === "object") {
    const result = {};
    for (const [key, inner] of Object.entries(value)) result[key] = toJson(inner);
    return result;
  }
  return value;
}

function writeJson(fileName, content) {
  fs.mkdirSync(BACKUP_DIR, { recursive: true });
  const filePath = path.join(BACKUP_DIR, fileName);
  fs.writeFileSync(filePath, JSON.stringify(content, null, 2));
  return filePath;
}

// --- Copie une image et lui donne un jeton de téléchargement. Si la copie
// --- existe déjà (script relancé), son jeton est réutilisé ---
async function copyImage(storage, from, toPath, bucketName) {
  const destination = storage.bucket(bucketName).file(toPath);
  const [exists] = await destination.exists();
  if (!exists) {
    await storage.bucket(from.bucket).file(from.path).copy(destination);
  }

  const [metadata] = await destination.getMetadata();
  const existingToken =
    metadata.metadata && metadata.metadata.firebaseStorageDownloadTokens;
  const token = existingToken ? existingToken.split(",")[0] : randomUUID();
  if (!existingToken) {
    await destination.setMetadata({ metadata: { firebaseStorageDownloadTokens: token } });
  }
  return downloadUrl(bucketName, toPath, token);
}

// ============================================================================
// MIGRATION
// ============================================================================

async function migrate({ db, storage, coupleId, authorMap, apply, bucketName }) {
  const coupleRef = db.collection("couples").doc(coupleId);
  const coupleDoc = await coupleRef.get();
  if (!coupleDoc.exists) throw new Error(`La relation ${coupleId} n'existe pas.`);

  // --- Les auteurs doivent faire partie de la relation ---
  const members = coupleDoc.data().members || [];
  for (const [name, uid] of Object.entries(authorMap)) {
    if (!members.includes(uid)) {
      log(`⚠️  ${name} (${uid}) ne fait pas partie de la relation ${coupleId}.`);
    }
  }

  // --- Lecture des anciennes données ---
  const [eventsSnapshot, datesSnapshot, settingsDoc] = await Promise.all([
    db.collection("timeline_events").get(),
    db.collection("important_dates").get(),
    db.collection("app_settings").doc("couple").get(),
  ]);

  const backupPath = writeJson(`backup-${stamp()}.json`, {
    projectId: PROJECT_ID,
    createdAt: new Date().toISOString(),
    timeline_events: eventsSnapshot.docs.map((doc) => ({ id: doc.id, data: toJson(doc.data()) })),
    important_dates: datesSnapshot.docs.map((doc) => ({ id: doc.id, data: toJson(doc.data()) })),
    app_settings_couple: settingsDoc.exists ? toJson(settingsDoc.data()) : null,
  });
  log(`💾 Sauvegarde : ${backupPath}`);
  log(`   ${eventsSnapshot.size} souvenirs, ${datesSnapshot.size} dates importantes, ` +
    `réglages ${settingsDoc.exists ? "présents" : "absents"}.`);

  // --- Auteurs sans correspondance ---
  const unknownAuthors = new Set();
  for (const doc of eventsSnapshot.docs) {
    const who = doc.data().who;
    if (who && !authorMap[who]) unknownAuthors.add(who);
  }
  if (unknownAuthors.size > 0) {
    log(`⚠️  Auteurs sans uid (creatorUid restera vide) : ${[...unknownAuthors].join(", ")}`);
  }

  const report = {
    coupleId,
    createdAt: new Date().toISOString(),
    eventIds: [],
    importantDateIds: [],
    settingsMigrated: false,
    copiedImages: [],
  };

  // --- Souvenirs et leurs images ---
  for (const doc of eventsSnapshot.docs) {
    const data = doc.data();
    const newUrls = [];

    for (const url of splitImageUrls(data.imageUrl)) {
      const source = parseStorageUrl(url);
      if (!source) {
        newUrls.push(url);
        continue;
      }
      const toPath = targetStoragePath(coupleId, source.path);
      if (toPath === source.path) {
        newUrls.push(url);
        continue;
      }
      if (apply) {
        newUrls.push(await copyImage(storage, source, toPath, bucketName));
      } else {
        newUrls.push(url);
      }
      report.copiedImages.push({ from: source, to: toPath });
    }

    const target = migratedEventData(data, { authorMap, imageUrl: newUrls.join("|") });
    log(`📸 ${data.title || doc.id} : ${newUrls.length} image(s), auteur ${target.creatorUid || "inconnu"}`);
    if (apply) {
      await coupleRef.collection("timeline_events").doc(doc.id).set({
        ...target,
        migratedAt: FieldValue.serverTimestamp(),
      });
    }
    report.eventIds.push(doc.id);
  }

  // --- Dates importantes ---
  for (const doc of datesSnapshot.docs) {
    log(`📅 ${doc.data().title || doc.id}`);
    if (apply) {
      await coupleRef.collection("important_dates").doc(doc.id).set({
        ...doc.data(),
        migratedAt: FieldValue.serverTimestamp(),
      });
    }
    report.importantDateIds.push(doc.id);
  }

  // --- Réglages ---
  if (settingsDoc.exists) {
    log("⚙️  Réglages de la relation");
    if (apply) {
      await coupleRef.collection("settings").doc("general").set(settingsDoc.data());
    }
    report.settingsMigrated = true;
  }

  log(`🖼️  ${report.copiedImages.length} image(s) Storage à copier.`);

  if (apply) {
    const reportPath = writeJson(`report-${stamp()}.json`, report);
    log(`✅ Migration terminée. Rapport (pour le nettoyage) : ${reportPath}`);
  } else {
    log("ℹ️  Simulation seulement. Relance avec --apply pour copier les données.");
  }
}

// ============================================================================
// NETTOYAGE (après vérification dans l'app)
// ============================================================================
// Supprime les anciens documents et les images copiées, d'après le rapport
// écrit par la migration.

async function cleanup({ db, storage, reportPath, apply }) {
  const report = JSON.parse(fs.readFileSync(reportPath, "utf8"));
  log(`🧹 Nettoyage d'après ${reportPath} (relation ${report.coupleId})`);
  log(`   ${report.eventIds.length} souvenirs, ${report.importantDateIds.length} dates, ` +
    `${report.copiedImages.length} images.`);

  if (!apply) {
    log("ℹ️  Simulation seulement. Relance avec --apply pour supprimer.");
    return;
  }

  for (const id of report.eventIds) {
    await db.collection("timeline_events").doc(id).delete();
  }
  for (const id of report.importantDateIds) {
    await db.collection("important_dates").doc(id).delete();
  }
  if (report.settingsMigrated) {
    await db.collection("app_settings").doc("couple").delete();
  }
  for (const { from } of report.copiedImages) {
    await storage.bucket(from.bucket).file(from.path).delete({ ignoreNotFound: true });
  }
  log("✅ Anciennes données supprimées.");
}

// ============================================================================
// POINT D'ENTRÉE
// ============================================================================

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const bucketName = typeof args.bucket === "string" ? args.bucket : DEFAULT_BUCKET;

  initializeApp({
    credential: applicationDefault(),
    projectId: PROJECT_ID,
    storageBucket: bucketName,
  });
  const db = getFirestore();
  const storage = getStorage();
  const apply = args.apply === true;

  if (args.cleanup) {
    if (typeof args.report !== "string") throw new Error("--report=<fichier> manquant.");
    await cleanup({ db, storage, reportPath: args.report, apply });
    return;
  }

  if (typeof args.couple !== "string") throw new Error("--couple=<coupleId> manquant.");
  const authorMap = parseAuthorMap(typeof args.map === "string" ? args.map : "");
  await migrate({ db, storage, coupleId: args.couple, authorMap, apply, bucketName });
}

main().catch((error) => {
  console.error(`❌ ${error.message}`);
  process.exitCode = 1;
});
