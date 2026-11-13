// ============================================================================
// SPECIAL DAYS
// ============================================================================
// Logique pure (sans Firebase) : quels jours spéciaux tombent un jour donné.
// Reprend les règles de l'app Flutter (ImportantDateEntity,
// CoupleSettingsEntity) : mêmes fréquences, même limite d'occurrences, même
// report du 31 et du 29 février sur le dernier jour du mois.
//
// Un "jour" est un objet { y, m, d } (mois de 1 à 12), en heure de Paris.

const PARIS = "Europe/Paris";

// --- Date JS -> { y, m, d, hour, minute } en heure de Paris ---
function parisParts(date) {
  const formatter = new Intl.DateTimeFormat("en-CA", {
    timeZone: PARIS,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    hourCycle: "h23",
  });
  const parts = {};
  for (const part of formatter.formatToParts(date)) {
    parts[part.type] = part.value;
  }
  return {
    y: Number(parts.year),
    m: Number(parts.month),
    d: Number(parts.day),
    hour: Number(parts.hour),
    minute: Number(parts.minute),
  };
}

// --- Date JS -> jour de Paris. Une date enregistrée à minuit par l'app
// --- (23 h ou 22 h UTC la veille) retombe bien sur son jour ---
function parisDay(date) {
  const { y, m, d } = parisParts(date);
  return { y, m, d };
}

function toUtc(day) {
  return Date.UTC(day.y, day.m - 1, day.d);
}

function compareDays(a, b) {
  return toUtc(a) - toUtc(b);
}

function sameDay(a, b) {
  return compareDays(a, b) === 0;
}

function daysBetween(from, to) {
  return Math.round((toUtc(to) - toUtc(from)) / 86400000);
}

function addDays(day, count) {
  const date = new Date(toUtc(day) + count * 86400000);
  return { y: date.getUTCFullYear(), m: date.getUTCMonth() + 1, d: date.getUTCDate() };
}

// --- Jour `d` d'un mois, ramené au dernier jour si le mois est plus court ---
function dayInMonth(y, m, d) {
  const lastDay = new Date(Date.UTC(y, m, 0)).getUTCDate();
  return { y, m, d: Math.min(d, lastDay) };
}

function monthSerial(day) {
  return day.y * 12 + (day.m - 1);
}

// --- Fréquence d'une date importante, anciens documents compris ---
function recurrenceOf(data) {
  const known = ["none", "weekly", "monthly", "yearly"];
  if (known.includes(data.recurrence)) return data.recurrence;
  return data.repeatsYearly === true ? "yearly" : "none";
}

// --- La date importante tombe-t-elle ce jour-là ? `first` est son jour de
// --- départ ({ y, m, d }), `data` le document Firestore ---
function importantDateOccursOn(first, data, day) {
  if (compareDays(day, first) < 0) return false;

  const recurrence = recurrenceOf(data);
  let index;
  switch (recurrence) {
    case "none":
      return sameDay(day, first);
    case "weekly": {
      const days = daysBetween(first, day);
      if (days % 7 !== 0) return false;
      index = days / 7;
      break;
    }
    case "monthly":
      if (!sameDay(day, dayInMonth(day.y, day.m, first.d))) return false;
      index = monthSerial(day) - monthSerial(first);
      break;
    case "yearly":
      if (!sameDay(day, dayInMonth(day.y, first.m, first.d))) return false;
      index = day.y - first.y;
      break;
    default:
      return false;
  }

  const limit = data.occurrenceLimit;
  return typeof limit !== "number" || index < limit;
}

function anniversaryTitle(years) {
  return `${years === 1 ? "1er" : `${years}e`} anniversaire`;
}

function monthAnniversaryTitle(months) {
  return `${months} mois`;
}

// --- Anniversaire ou mois-anniversaire du jour, selon les réglages du
// --- couple. L'anniversaire affiché couvre le mois-anniversaire du même
// --- jour. Renvoie { emoji, title } ou null ---
function anniversaryOn(settings, day) {
  if (!settings || !settings.start) return null;
  const start = settings.start;

  if (settings.showAnniversary) {
    const years = day.y - start.y;
    if (years >= 1 && sameDay(day, dayInMonth(day.y, start.m, start.d))) {
      return { emoji: settings.anniversaryEmoji, title: anniversaryTitle(years) };
    }
  }

  if (settings.showMonthAnniversaries) {
    const months = monthSerial(day) - monthSerial(start);
    const coveredByAnniversary = settings.showAnniversary && months % 12 === 0;
    if (
      months >= 1 &&
      !coveredByAnniversary &&
      sameDay(day, dayInMonth(day.y, day.m, start.d))
    ) {
      return {
        emoji: settings.monthAnniversaryEmoji,
        title: monthAnniversaryTitle(months),
      };
    }
  }

  return null;
}

// --- "09:30" -> 570 ; null si illisible ---
function parseTime(value) {
  if (typeof value !== "string") return null;
  const match = /^(\d{1,2}):(\d{2})$/.exec(value);
  if (!match) return null;
  const hours = Number(match[1]);
  const minutes = Number(match[2]);
  if (hours > 23 || minutes > 59) return null;
  return hours * 60 + minutes;
}

// --- La fonction passe toutes les 5 minutes : une heure réglée est due
// --- pendant le créneau de 5 minutes qui la contient ---
const SLOT_MINUTES = 5;

function isDue(timeMinutes, nowMinutes) {
  if (timeMinutes === null) return false;
  return Math.floor(timeMinutes / SLOT_MINUTES) === Math.floor(nowMinutes / SLOT_MINUTES);
}

// --- Préférences d'un appareil, avec les valeurs d'origine pour les champs
// --- absents (mêmes valeurs que NotificationPreferences côté app) ---
function preferencesOf(deviceData) {
  const raw = (deviceData && deviceData.notifications) || {};
  const bool = (value, fallback) => (typeof value === "boolean" ? value : fallback);
  return {
    enabled: bool(raw.enabled, true),
    newMemory: bool(raw.newMemory, true),
    importantDates: bool(raw.importantDates, true),
    anniversaries: bool(raw.anniversaries, true),
    dayOfTime: parseTime(raw.dayOfTime) ?? 9 * 60,
    reminderEnabled: bool(raw.reminderEnabled, false),
    reminderDaysBefore:
      Number.isInteger(raw.reminderDaysBefore) && raw.reminderDaysBefore > 0
        ? raw.reminderDaysBefore
        : 1,
    reminderTime: parseTime(raw.reminderTime) ?? 18 * 60,
  };
}

// --- Lignes à annoncer pour un jour donné : "🎂 Anniversaire de Lulu" ---
function specialDayLines({ day, importantDates, settings, preferences }) {
  const lines = [];

  if (preferences.anniversaries) {
    const anniversary = anniversaryOn(settings, day);
    if (anniversary) lines.push(`${anniversary.emoji} ${anniversary.title}`.trim());
  }

  if (preferences.importantDates) {
    for (const date of importantDates) {
      if (importantDateOccursOn(date.first, date.data, day)) {
        lines.push(`${date.data.emoji || ""} ${date.data.title || ""}`.trim());
      }
    }
  }

  return lines;
}

// --- Titre du rappel : "Demain", "Dans 3 jours" ---
function reminderTitle(daysBefore) {
  return daysBefore === 1 ? "Demain" : `Dans ${daysBefore} jours`;
}

module.exports = {
  parisParts,
  parisDay,
  addDays,
  importantDateOccursOn,
  anniversaryOn,
  parseTime,
  isDue,
  preferencesOf,
  specialDayLines,
  reminderTitle,
};
