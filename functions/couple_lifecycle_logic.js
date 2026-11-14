// ============================================================================
// CYCLE DE VIE D'UNE RELATION : LOGIQUE PURE
// ============================================================================
// Fin de relation d'un commun accord et suppression après un an
// d'inactivité. Sans Firebase : les dates sont des millisecondes, testées
// avec node --test.

const DAY_MS = 24 * 60 * 60 * 1000;

// --- Rappel envoyé aux membres qui n'ont pas répondu, 6 jours après la
// --- demande d'arrêt ---
const END_REMINDER_AFTER_DAYS = 6;

// --- Inactivité : suppression au bout d'un an, avertissements 30 puis
// --- 7 jours avant ---
const INACTIVITY_DELETE_AFTER_DAYS = 365;
const INACTIVITY_WARNINGS = [
  { key: "d7", daysBefore: 7 },
  { key: "d30", daysBefore: 30 },
];

// --- Avancement d'une demande d'arrêt : seuls les membres actuels
// --- comptent (un membre parti ne bloque pas la décision) ---
function endRequestProgress(couple) {
  const members = (couple && couple.members) || [];
  const endRequest = couple && couple.endRequest;
  const acceptedBy = (endRequest && endRequest.acceptedBy) || [];
  const accepted = members.filter((uid) => acceptedBy.includes(uid));
  return {
    accepted: accepted.length,
    total: members.length,
    allAccepted: members.length > 0 && accepted.length === members.length,
  };
}

// --- Membres qui n'ont encore ni accepté ni refusé ---
function membersWithoutAnswer(couple) {
  const endRequest = (couple && couple.endRequest) || {};
  const answered = [...(endRequest.acceptedBy || []), ...(endRequest.declinedBy || [])];
  return ((couple && couple.members) || []).filter((uid) => !answered.includes(uid));
}

// --- Le rappel du 6e jour est-il dû ? Une seule fois par demande ---
function needsEndReminder(endRequest, requestedAtMs, nowMs) {
  if (!endRequest || endRequest.reminderSentAt) return false;
  if (typeof requestedAtMs !== "number") return false;
  return nowMs - requestedAtMs >= END_REMINDER_AFTER_DAYS * DAY_MS;
}

// --- Que faire d'une relation inactive ?
// --- "delete", { warn: "d30" | "d7", daysLeft }, ou null ---
function inactivityAction(lastActivityMs, nowMs, warningsSent) {
  if (typeof lastActivityMs !== "number") return null;
  const inactiveDays = (nowMs - lastActivityMs) / DAY_MS;
  if (inactiveDays >= INACTIVITY_DELETE_AFTER_DAYS) return "delete";

  const sent = warningsSent || {};
  // --- Le plus proche d'abord : si les deux sont dus, seul J-7 part ---
  for (const { key, daysBefore } of INACTIVITY_WARNINGS) {
    if (inactiveDays >= INACTIVITY_DELETE_AFTER_DAYS - daysBefore && !sent[key]) {
      return { warn: key, daysLeft: daysBefore };
    }
  }
  return null;
}

// --- Date à partir de laquelle une relation peut être concernée (le
// --- premier avertissement) ---
function inactivityQueryCutoffMs(nowMs) {
  const earliest = Math.max(...INACTIVITY_WARNINGS.map((w) => w.daysBefore));
  return nowMs - (INACTIVITY_DELETE_AFTER_DAYS - earliest) * DAY_MS;
}

module.exports = {
  DAY_MS,
  END_REMINDER_AFTER_DAYS,
  INACTIVITY_DELETE_AFTER_DAYS,
  endRequestProgress,
  membersWithoutAnswer,
  needsEndReminder,
  inactivityAction,
  inactivityQueryCutoffMs,
};
