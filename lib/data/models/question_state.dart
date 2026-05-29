// <<===========================================================================>>
// <<========================== ÉTAT DU QUESTIONNAIRE ==========================>>
// <<===========================================================================>>
// Équivalent de QuestionState.kt — enum des étapes du questionnaire

enum QuestionState {
  // <<--- Saisie de la réponse --->
  input,

  // <<--- Revue et confirmation --->
  review,

  // <<--- Terminé --->
  completed,
}