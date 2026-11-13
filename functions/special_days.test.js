// ============================================================================
// TESTS : special_days.js (node --test)
// ============================================================================

const test = require("node:test");
const assert = require("node:assert/strict");
const {
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
} = require("./special_days");

const day = (y, m, d) => ({ y, m, d });

test("parisDay : minuit à Paris enregistré en UTC retombe sur son jour", () => {
  // --- Le 28 décembre à minuit à Paris = le 27 à 23 h UTC (heure d'hiver) ---
  assert.deepEqual(parisDay(new Date(Date.UTC(2026, 11, 27, 23, 0))), day(2026, 12, 28));
  // --- Le 1er juillet à minuit à Paris = le 30 juin à 22 h UTC (heure d'été) ---
  assert.deepEqual(parisDay(new Date(Date.UTC(2026, 5, 30, 22, 0))), day(2026, 7, 1));
});

test("parisParts : donne l'heure de Paris", () => {
  const parts = parisParts(new Date(Date.UTC(2026, 10, 13, 8, 30)));
  assert.equal(parts.hour, 9);
  assert.equal(parts.minute, 30);
});

test("addDays : traverse les mois et les années", () => {
  assert.deepEqual(addDays(day(2026, 12, 30), 3), day(2027, 1, 2));
  assert.deepEqual(addDays(day(2028, 2, 28), 1), day(2028, 2, 29));
});

test("date ponctuelle : seulement le jour prévu", () => {
  const first = day(2026, 12, 28);
  const data = { recurrence: "none" };
  assert.equal(importantDateOccursOn(first, data, day(2026, 12, 28)), true);
  assert.equal(importantDateOccursOn(first, data, day(2027, 12, 28)), false);
});

test("tous les ans : revient chaque année, jamais avant", () => {
  const first = day(2023, 12, 12);
  const data = { recurrence: "yearly" };
  assert.equal(importantDateOccursOn(first, data, day(2026, 12, 12)), true);
  assert.equal(importantDateOccursOn(first, data, day(2022, 12, 12)), false);
  assert.equal(importantDateOccursOn(first, data, day(2026, 12, 13)), false);
});

test("tous les ans : un 29 février retombe le 28", () => {
  const first = day(2024, 2, 29);
  const data = { recurrence: "yearly" };
  assert.equal(importantDateOccursOn(first, data, day(2025, 2, 28)), true);
  assert.equal(importantDateOccursOn(first, data, day(2028, 2, 28)), false);
  assert.equal(importantDateOccursOn(first, data, day(2028, 2, 29)), true);
});

test("tous les mois : un 31 retombe sur le dernier jour", () => {
  const first = day(2026, 1, 31);
  const data = { recurrence: "monthly" };
  assert.equal(importantDateOccursOn(first, data, day(2026, 2, 28)), true);
  assert.equal(importantDateOccursOn(first, data, day(2026, 4, 30)), true);
  assert.equal(importantDateOccursOn(first, data, day(2026, 3, 30)), false);
});

test("toutes les semaines : même jour de la semaine", () => {
  const first = day(2026, 11, 5);
  const data = { recurrence: "weekly" };
  assert.equal(importantDateOccursOn(first, data, day(2026, 11, 19)), true);
  assert.equal(importantDateOccursOn(first, data, day(2026, 11, 20)), false);
});

test("limite d'occurrences : s'arrête après le nombre de fois prévu", () => {
  const first = day(2024, 6, 1);
  const data = { recurrence: "yearly", occurrenceLimit: 3 };
  assert.equal(importantDateOccursOn(first, data, day(2026, 6, 1)), true);
  assert.equal(importantDateOccursOn(first, data, day(2027, 6, 1)), false);

  const weekly = { recurrence: "weekly", occurrenceLimit: 3 };
  assert.equal(importantDateOccursOn(day(2026, 11, 5), weekly, day(2026, 11, 19)), true);
  assert.equal(importantDateOccursOn(day(2026, 11, 5), weekly, day(2026, 11, 26)), false);
});

test("ancien format : repeatsYearly vaut tous les ans", () => {
  const data = { repeatsYearly: true };
  assert.equal(importantDateOccursOn(day(2023, 12, 12), data, day(2026, 12, 12)), true);
});

const settings = {
  start: day(2023, 12, 12),
  showAnniversary: true,
  anniversaryEmoji: "💍",
  showMonthAnniversaries: true,
  monthAnniversaryEmoji: "❤️",
};

test("anniversaire : numéroté, pas le jour du début", () => {
  assert.deepEqual(anniversaryOn(settings, day(2024, 12, 12)), {
    emoji: "💍",
    title: "1er anniversaire",
  });
  assert.equal(anniversaryOn(settings, day(2026, 12, 12)).title, "3e anniversaire");
  assert.equal(anniversaryOn(settings, day(2023, 12, 12)), null);
});

test("mois-anniversaire : couvert par l'anniversaire le même jour", () => {
  assert.equal(anniversaryOn(settings, day(2026, 11, 12)).title, "35 mois");
  const monthsOnly = { ...settings, showAnniversary: false };
  assert.equal(anniversaryOn(monthsOnly, day(2026, 12, 12)).title, "36 mois");
});

test("anniversaires masqués : rien", () => {
  const hidden = { ...settings, showAnniversary: false, showMonthAnniversaries: false };
  assert.equal(anniversaryOn(hidden, day(2026, 12, 12)), null);
  assert.equal(anniversaryOn(null, day(2026, 12, 12)), null);
});

test("parseTime et isDue : créneaux de 5 minutes", () => {
  assert.equal(parseTime("09:30"), 570);
  assert.equal(parseTime("24:00"), null);
  assert.equal(parseTime("abc"), null);
  assert.equal(isDue(570, 570), true);
  assert.equal(isDue(572, 574), true);
  assert.equal(isDue(570, 575), false);
  assert.equal(isDue(null, 570), false);
});

test("preferencesOf : valeurs d'origine pour un appareil sans réglage", () => {
  assert.deepEqual(preferencesOf({ token: "abc" }), {
    enabled: true,
    newMemory: true,
    importantDates: true,
    anniversaries: true,
    dayOfTime: 540,
    reminderEnabled: false,
    reminderDaysBefore: 1,
    reminderTime: 1080,
  });
});

test("preferencesOf : lit les réglages enregistrés par l'app", () => {
  const preferences = preferencesOf({
    notifications: {
      enabled: true,
      newMemory: false,
      dayOfTime: "08:15",
      reminderEnabled: true,
      reminderDaysBefore: 3,
      reminderTime: "20:00",
    },
  });
  assert.equal(preferences.newMemory, false);
  assert.equal(preferences.dayOfTime, 495);
  assert.equal(preferences.reminderDaysBefore, 3);
  assert.equal(preferences.reminderTime, 1200);
});

test("specialDayLines : respecte les préférences de l'appareil", () => {
  const importantDates = [
    { first: day(2026, 12, 12), data: { recurrence: "none", emoji: "🎄", title: "Marché de Noël" } },
  ];
  const all = preferencesOf({});
  assert.deepEqual(
    specialDayLines({ day: day(2026, 12, 12), importantDates, settings, preferences: all }),
    ["💍 3e anniversaire", "🎄 Marché de Noël"],
  );

  const datesOnly = { ...all, anniversaries: false };
  assert.deepEqual(
    specialDayLines({ day: day(2026, 12, 12), importantDates, settings, preferences: datesOnly }),
    ["🎄 Marché de Noël"],
  );
});

test("reminderTitle", () => {
  assert.equal(reminderTitle(1), "Demain");
  assert.equal(reminderTitle(3), "Dans 3 jours");
});
