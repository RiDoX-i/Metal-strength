import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../core/models/exercise.dart';
import '../core/models/sex.dart';
import '../core/formulas/tiers.dart';
import '../state/app_state.dart';
import 'exercise_names.dart';

/// Lightweight, provider-driven localization for the shipped languages.
///
/// Strings live in [_table] keyed by `key -> { 'en': ..., 'fr': ..., ... }`.
/// Lookups fall back to English and finally to the key itself, so a missing
/// translation degrades gracefully instead of crashing.

/// Translate [key] into the app's current language.
String tr(BuildContext context, String key) {
  final lang = context.watch<AppState>().locale.languageCode;
  return _lookup(key, lang);
}

/// Like [tr] but substitutes `{name}` placeholders from [params].
String trp(BuildContext context, String key, Map<String, Object> params) {
  var out = tr(context, key);
  params.forEach((k, v) => out = out.replaceAll('{$k}', '$v'));
  return out;
}

String _lookup(String key, String lang) {
  final entry = _table[key];
  if (entry == null) return key;
  return entry[lang] ?? entry['en'] ?? key;
}

/// Localized [StrengthTier.label].
String tierLabel(BuildContext context, StrengthTier tier) =>
    tr(context, 'tier_${tier.name}');

/// Localized [Equipment.label].
String equipmentLabel(BuildContext context, Equipment equipment) =>
    tr(context, 'equip_${equipment.name}');

/// Localized [Sex.label].
String sexLabel(BuildContext context, Sex sex) => tr(context, 'sex_${sex.name}');

/// Localized display name for [exercise] in the app's current language.
///
/// Falls back to the exercise's canonical (English) catalog name when the id or
/// the language has no entry, so the UI never shows a blank or a raw id.
String exerciseName(BuildContext context, Exercise exercise) {
  final lang = context.watch<AppState>().locale.languageCode;
  return localizedExerciseName(exercise.id, exercise.name, lang);
}

/// Like [exerciseName] but works from a stored [id] + [fallback] name (used by
/// history rows where only the saved record is available).
String localizedExerciseName(String id, String fallback, String lang) {
  final entry = kExerciseNames[id];
  if (entry == null) return fallback;
  return entry[lang] ?? entry['en'] ?? fallback;
}

/// Whether [exercise] matches [query] in **any** supported language.
///
/// Matching is case- and accent-insensitive and spans every translation plus
/// the id, so a user browsing in Spanish can still find a lift by typing its
/// English name (and vice-versa).
bool exerciseMatchesQuery(Exercise exercise, String query) {
  final q = _normalizeForSearch(query);
  if (q.isEmpty) return true;
  final entry = kExerciseNames[exercise.id];
  final terms = <String>[
    exercise.name,
    exercise.id.replaceAll('-', ' '),
    if (entry != null) ...entry.values,
  ];
  return terms.any((t) => _normalizeForSearch(t).contains(q));
}

/// Lowercase + strip the diacritics found in the shipped languages so search is
/// forgiving of accents (e.g. "sentadilla" matches "Sentadílla", "press" the
/// accented variants, etc.).
String _normalizeForSearch(String s) {
  final buffer = StringBuffer();
  for (final rune in s.toLowerCase().runes) {
    final ch = String.fromCharCode(rune);
    buffer.write(_diacritics[ch] ?? ch);
  }
  return buffer.toString().trim();
}

const Map<String, String> _diacritics = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
  'ç': 'c', 'ñ': 'n', 'ß': 'ss', '°': '',
};

const Map<String, Map<String, String>> _table = {
  // ---- Brand / landing -----------------------------------------------------
  'app_tagline': {
    'en': 'Know your strength level from what you lift.',
    'fr': 'Connais ton niveau de force selon ce que tu soulèves.',
    'es': 'Conoce tu nivel de fuerza según lo que levantas.',
    'de': 'Erkenne dein Kraftniveau anhand dessen, was du hebst.',
    'pt': 'Descubra o seu nível de força pelo que você levanta.',
  },
  'browse_exercises': {
    'en': 'Browse exercises',
    'fr': 'Parcourir les exercices',
    'es': 'Explorar ejercicios',
    'de': 'Übungen durchsuchen',
    'pt': 'Explorar exercícios',
  },
  'browse_subtitle': {
    'en': 'Rate your strength on 270+ lifts',
    'fr': 'Évalue ta force sur plus de 270 exercices',
    'es': 'Evalúa tu fuerza en más de 270 ejercicios',
    'de': 'Bewerte deine Kraft bei über 270 Übungen',
    'pt': 'Avalie a sua força em mais de 270 exercícios',
  },
  'support_app': {
    'en': 'Support the app',
    'fr': "Soutenir l'application",
    'es': 'Apoyar la app',
    'de': 'App unterstützen',
    'pt': 'Apoiar o app',
  },
  'language': {
    'en': 'Language',
    'fr': 'Langue',
    'es': 'Idioma',
    'de': 'Sprache',
    'pt': 'Idioma',
  },
  'sign_out': {
    'en': 'Sign out',
    'fr': 'Se déconnecter',
    'es': 'Cerrar sesión',
    'de': 'Abmelden',
    'pt': 'Sair',
  },
  'signed_in_as': {
    'en': 'Signed in as {who}',
    'fr': 'Connecté en tant que {who}',
    'es': 'Conectado como {who}',
    'de': 'Angemeldet als {who}',
    'pt': 'Conectado como {who}',
  },
  'guest': {
    'en': 'Guest',
    'fr': 'Invité',
    'es': 'Invitado',
    'de': 'Gast',
    'pt': 'Convidado',
  },

  // ---- Catalog -------------------------------------------------------------
  'catalog_subtitle': {
    'en': 'Pick an exercise to rate your strength',
    'fr': 'Choisis un exercice pour évaluer ta force',
    'es': 'Elige un ejercicio para evaluar tu fuerza',
    'de': 'Wähle eine Übung, um deine Kraft zu bewerten',
    'pt': 'Escolha um exercício para avaliar a sua força',
  },
  'search_hint': {
    'en': 'Search exercises',
    'fr': 'Rechercher des exercices',
    'es': 'Buscar ejercicios',
    'de': 'Übungen suchen',
    'pt': 'Buscar exercícios',
  },
  'filter_all': {
    'en': 'All',
    'fr': 'Tous',
    'es': 'Todos',
    'de': 'Alle',
    'pt': 'Todos',
  },
  'empty_search': {
    'en': 'No exercises match your search',
    'fr': 'Aucun exercice ne correspond à ta recherche',
    'es': 'Ningún ejercicio coincide con tu búsqueda',
    'de': 'Keine Übung entspricht deiner Suche',
    'pt': 'Nenhum exercício corresponde à sua busca',
  },

  // ---- Equipment -----------------------------------------------------------
  'equip_barbell': {
    'en': 'Barbell',
    'fr': 'Barre',
    'es': 'Barra',
    'de': 'Langhantel',
    'pt': 'Barra',
  },
  'equip_dumbbell': {
    'en': 'Dumbbell',
    'fr': 'Haltère',
    'es': 'Mancuerna',
    'de': 'Kurzhantel',
    'pt': 'Halter',
  },
  'equip_kettlebell': {
    'en': 'Kettlebell',
    'fr': 'Kettlebell',
    'es': 'Pesa rusa',
    'de': 'Kettlebell',
    'pt': 'Kettlebell',
  },
  'equip_machine': {
    'en': 'Machine',
    'fr': 'Machine',
    'es': 'Máquina',
    'de': 'Maschine',
    'pt': 'Máquina',
  },
  'equip_cable': {
    'en': 'Cable',
    'fr': 'Poulie',
    'es': 'Polea',
    'de': 'Kabelzug',
    'pt': 'Cabo',
  },
  'equip_bodyweight': {
    'en': 'Bodyweight',
    'fr': 'Poids du corps',
    'es': 'Peso corporal',
    'de': 'Körpergewicht',
    'pt': 'Peso corporal',
  },

  // ---- Measure -------------------------------------------------------------
  'measure_title': {
    'en': 'Measure',
    'fr': 'Mesurer',
    'es': 'Medir',
    'de': 'Messen',
    'pt': 'Medir',
  },
  'rated_by_reps': {
    'en': 'Rated by reps performed',
    'fr': 'Évalué selon les répétitions',
    'es': 'Evaluado por repeticiones realizadas',
    'de': 'Bewertet nach geschafften Wiederholungen',
    'pt': 'Avaliado pelas repetições realizadas',
  },
  'lift_over_bw': {
    'en': 'lift ÷ bodyweight',
    'fr': 'charge ÷ poids du corps',
    'es': 'carga ÷ peso corporal',
    'de': 'Last ÷ Körpergewicht',
    'pt': 'carga ÷ peso corporal',
  },
  'edit': {
    'en': 'Edit',
    'fr': 'Modifier',
    'es': 'Editar',
    'de': 'Bearbeiten',
    'pt': 'Editar',
  },
  'measure_how': {
    'en': 'How do you want to measure?',
    'fr': 'Comment veux-tu mesurer ?',
    'es': '¿Cómo quieres medir?',
    'de': 'Wie möchtest du messen?',
    'pt': 'Como você quer medir?',
  },
  'single_lift': {
    'en': 'Single lift',
    'fr': 'Levée simple',
    'es': 'Levantamiento único',
    'de': 'Einzelübung',
    'pt': 'Levantamento único',
  },
  'total_wilks': {
    'en': 'Total (Wilks/DOTS)',
    'fr': 'Total (Wilks/DOTS)',
    'es': 'Total (Wilks/DOTS)',
    'de': 'Total (Wilks/DOTS)',
    'pt': 'Total (Wilks/DOTS)',
  },
  'your_best_set': {
    'en': 'Your best set',
    'fr': 'Ta meilleure série',
    'es': 'Tu mejor serie',
    'de': 'Dein bester Satz',
    'pt': 'A sua melhor série',
  },
  'weight': {
    'en': 'Weight',
    'fr': 'Charge',
    'es': 'Peso',
    'de': 'Gewicht',
    'pt': 'Peso',
  },
  'reps': {
    'en': 'Reps',
    'fr': 'Répétitions',
    'es': 'Repeticiones',
    'de': 'Wiederholungen',
    'pt': 'Repetições',
  },
  'best_single_each': {
    'en': 'Your best single (1RM) on each lift',
    'fr': 'Ton meilleur essai (1RM) sur chaque levée',
    'es': 'Tu mejor intento (1RM) en cada levantamiento',
    'de': 'Dein bester Versuch (1RM) bei jeder Übung',
    'pt': 'O seu melhor esforço (1RM) em cada levantamento',
  },
  'squat': {
    'en': 'Squat',
    'fr': 'Squat',
    'es': 'Sentadilla',
    'de': 'Kniebeuge',
    'pt': 'Agachamento',
  },
  'bench': {
    'en': 'Bench',
    'fr': 'Développé couché',
    'es': 'Press de banca',
    'de': 'Bankdrücken',
    'pt': 'Supino',
  },
  'deadlift': {
    'en': 'Deadlift',
    'fr': 'Soulevé de terre',
    'es': 'Peso muerto',
    'de': 'Kreuzheben',
    'pt': 'Levantamento terra',
  },
  'how_many_reps': {
    'en': 'How many reps?',
    'fr': 'Combien de répétitions ?',
    'es': '¿Cuántas repeticiones?',
    'de': 'Wie viele Wiederholungen?',
    'pt': 'Quantas repetições?',
  },
  'max_reps': {
    'en': 'Max reps',
    'fr': 'Répétitions max',
    'es': 'Repeticiones máximas',
    'de': 'Maximale Wiederholungen',
    'pt': 'Repetições máximas',
  },
  'high_reps_hint': {
    'en':
        'High reps reduce 1RM accuracy — keep it under {n} for a reliable estimate.',
    'fr':
        'Trop de répétitions réduisent la précision du 1RM — reste sous {n} pour une estimation fiable.',
    'es':
        'Muchas repeticiones reducen la precisión del 1RM — mantenlo por debajo de {n} para una estimación fiable.',
    'de':
        'Viele Wiederholungen verringern die 1RM-Genauigkeit — bleibe unter {n} für eine verlässliche Schätzung.',
    'pt':
        'Muitas repetições reduzem a precisão do 1RM — mantenha abaixo de {n} para uma estimativa confiável.',
  },
  'calculate_strength': {
    'en': 'Calculate strength',
    'fr': 'Calculer la force',
    'es': 'Calcular fuerza',
    'de': 'Kraft berechnen',
    'pt': 'Calcular força',
  },

  // ---- Result --------------------------------------------------------------
  'result_title': {
    'en': 'Result',
    'fr': 'Résultat',
    'es': 'Resultado',
    'de': 'Ergebnis',
    'pt': 'Resultado',
  },
  'stronger_than': {
    'en': 'Stronger than {n}% of lifters',
    'fr': 'Plus fort que {n}% des pratiquants',
    'es': 'Más fuerte que el {n}% de los practicantes',
    'de': 'Stärker als {n}% der Athleten',
    'pt': 'Mais forte que {n}% dos praticantes',
  },
  'est_1rm': {
    'en': 'Est. 1RM',
    'fr': '1RM est.',
    'es': '1RM est.',
    'de': 'Gesch. 1RM',
    'pt': '1RM est.',
  },
  'bw_ratio': {
    'en': 'Bodyweight ratio',
    'fr': 'Ratio poids du corps',
    'es': 'Ratio peso corporal',
    'de': 'Körpergewicht-Verhältnis',
    'pt': 'Razão peso corporal',
  },
  'top_tier': {
    'en': "You're at the top tier — Elite. Outstanding.",
    'fr': 'Tu es au sommet — Élite. Exceptionnel.',
    'es': 'Estás en el nivel máximo — Élite. Excepcional.',
    'de': 'Du bist auf der höchsten Stufe — Elite. Herausragend.',
    'pt': 'Você está no nível máximo — Elite. Excepcional.',
  },
  'next_tier': {
    'en': 'Next: {tier}',
    'fr': 'Suivant : {tier}',
    'es': 'Siguiente: {tier}',
    'de': 'Nächste: {tier}',
    'pt': 'Próximo: {tier}',
  },
  'more_reps': {
    'en': '{n} more reps',
    'fr': '{n} répétitions de plus',
    'es': '{n} repeticiones más',
    'de': '{n} weitere Wiederholungen',
    'pt': 'mais {n} repetições',
  },
  'tier_ladder': {
    'en': 'Tier ladder',
    'fr': 'Échelle des niveaux',
    'es': 'Escala de niveles',
    'de': 'Stufenleiter',
    'pt': 'Escala de níveis',
  },
  'share': {
    'en': 'Share',
    'fr': 'Partager',
    'es': 'Compartir',
    'de': 'Teilen',
    'pt': 'Compartilhar',
  },
  'share_caption': {
    'en':
        "I'm {tier} on {exercise} — stronger than {n}% of lifters 💪 Rate your strength on Metal Strength.",
    'fr':
        'Je suis {tier} au {exercise} — plus fort que {n}% des pratiquants 💪 Évalue ta force sur Metal Strength.',
    'es':
        'Soy {tier} en {exercise} — más fuerte que el {n}% de los practicantes 💪 Evalúa tu fuerza en Metal Strength.',
    'de':
        'Ich bin {tier} bei {exercise} — stärker als {n}% der Athleten 💪 Bewerte deine Kraft mit Metal Strength.',
    'pt':
        'Sou {tier} no {exercise} — mais forte que {n}% dos praticantes 💪 Avalie sua força no Metal Strength.',
  },
  'share_failed': {
    'en': 'Could not share the image. Please try again.',
    'fr': "Impossible de partager l'image. Réessaie.",
    'es': 'No se pudo compartir la imagen. Inténtalo de nuevo.',
    'de': 'Bild konnte nicht geteilt werden. Bitte versuche es erneut.',
    'pt': 'Não foi possível compartilhar a imagem. Tente novamente.',
  },
  'note_epley': {
    'en': '1RM estimated with the Epley formula (industry standard).',
    'fr': "1RM estimé avec la formule d'Epley (standard du secteur).",
    'es': '1RM estimado con la fórmula de Epley (estándar del sector).',
    'de': '1RM mit der Epley-Formel geschätzt (Branchenstandard).',
    'pt': '1RM estimado com a fórmula de Epley (padrão do setor).',
  },
  'note_high_rep': {
    'en': 'High-rep estimate — treat the 1RM as approximate.',
    'fr': 'Estimation à répétitions élevées — 1RM approximatif.',
    'es': 'Estimación con muchas repeticiones — considera el 1RM como aproximado.',
    'de': 'Schätzung mit vielen Wiederholungen — betrachte den 1RM als ungefähr.',
    'pt': 'Estimativa com muitas repetições — trate o 1RM como aproximado.',
  },
  'note_estimate': {
    'en': 'Standards are ratio-based estimates, not dataset percentiles.',
    'fr':
        'Les standards sont des estimations par ratio, pas des centiles mesurés.',
    'es': 'Los estándares son estimaciones por ratio, no centiles de datos.',
    'de':
        'Die Standards sind verhältnisbasierte Schätzungen, keine Datensatz-Perzentile.',
    'pt': 'Os padrões são estimativas por razão, não percentis de dados.',
  },

  // ---- World records -------------------------------------------------------
  'world_record': {
    'en': 'World record',
    'fr': 'Record du monde',
    'es': 'Récord mundial',
    'de': 'Weltrekord',
    'pt': 'Recorde mundial',
  },
  'wr_men': {
    'en': "Men's all-time record",
    'fr': 'Record absolu hommes',
    'es': 'Récord absoluto masculino',
    'de': 'Allzeitrekord der Männer',
    'pt': 'Recorde absoluto masculino',
  },
  'wr_women': {
    'en': "Women's all-time record",
    'fr': 'Record absolu femmes',
    'es': 'Récord absoluto femenino',
    'de': 'Allzeitrekord der Frauen',
    'pt': 'Recorde absoluto feminino',
  },
  'wr_held_by': {
    'en': '{holder} · {year}',
    'fr': '{holder} · {year}',
    'es': '{holder} · {year}',
    'de': '{holder} · {year}',
    'pt': '{holder} · {year}',
  },
  'wr_cat_raw_pl': {
    'en': 'Raw powerlifting',
    'fr': 'Force athlétique (raw)',
    'es': 'Powerlifting raw',
    'de': 'Raw-Powerlifting',
    'pt': 'Powerlifting raw',
  },
  'wr_cat_oly': {
    'en': 'Olympic weightlifting',
    'fr': 'Haltérophilie',
    'es': 'Halterofilia olímpica',
    'de': 'Olympisches Gewichtheben',
    'pt': 'Levantamento de peso olímpico',
  },
  'wr_cat_strongman': {
    'en': 'Strongman (straps)',
    'fr': 'Strongman (sangles)',
    'es': 'Strongman (correas)',
    'de': 'Strongman (Zughilfen)',
    'pt': 'Strongman (straps)',
  },

  // ---- Tips ----------------------------------------------------------------
  'tips_title': {
    'en': 'Tips to get stronger',
    'fr': 'Conseils pour progresser',
    'es': 'Consejos para ser más fuerte',
    'de': 'Tipps, um stärker zu werden',
    'pt': 'Dicas para ficar mais forte',
  },

  // ---- Tiers ---------------------------------------------------------------
  'tier_beginner': {
    'en': 'Beginner',
    'fr': 'Débutant',
    'es': 'Principiante',
    'de': 'Anfänger',
    'pt': 'Iniciante',
  },
  'tier_novice': {
    'en': 'Novice',
    'fr': 'Novice',
    'es': 'Novato',
    'de': 'Neuling',
    'pt': 'Novato',
  },
  'tier_intermediate': {
    'en': 'Intermediate',
    'fr': 'Intermédiaire',
    'es': 'Intermedio',
    'de': 'Mittelstufe',
    'pt': 'Intermediário',
  },
  'tier_advanced': {
    'en': 'Advanced',
    'fr': 'Avancé',
    'es': 'Avanzado',
    'de': 'Fortgeschritten',
    'pt': 'Avançado',
  },
  'tier_elite': {
    'en': 'Elite',
    'fr': 'Élite',
    'es': 'Élite',
    'de': 'Elite',
    'pt': 'Elite',
  },

  // ---- Sex -----------------------------------------------------------------
  'sex_male': {
    'en': 'Male',
    'fr': 'Homme',
    'es': 'Hombre',
    'de': 'Männlich',
    'pt': 'Homem',
  },
  'sex_female': {
    'en': 'Female',
    'fr': 'Femme',
    'es': 'Mujer',
    'de': 'Weiblich',
    'pt': 'Mulher',
  },

  // ---- Powerlifting score --------------------------------------------------
  'pl_score_title': {
    'en': 'Powerlifting score',
    'fr': 'Score force athlétique',
    'es': 'Puntuación de powerlifting',
    'de': 'Powerlifting-Wertung',
    'pt': 'Pontuação de powerlifting',
  },
  'total': {
    'en': 'Total',
    'fr': 'Total',
    'es': 'Total',
    'de': 'Gesamt',
    'pt': 'Total',
  },
  'all_scoring': {
    'en': 'All scoring systems',
    'fr': 'Tous les systèmes de score',
    'es': 'Todos los sistemas de puntuación',
    'de': 'Alle Wertungssysteme',
    'pt': 'Todos os sistemas de pontuação',
  },
  'pl_note': {
    'en':
        'Scores are computed in kilograms (converted for display). Recalibrate percentiles from OpenPowerlifting.org (public domain).',
    'fr':
        'Les scores sont calculés en kilogrammes (convertis pour l’affichage). Recalibre les centiles depuis OpenPowerlifting.org (domaine public).',
    'es':
        'Las puntuaciones se calculan en kilogramos (convertidas para mostrar). Recalibra los centiles desde OpenPowerlifting.org (dominio público).',
    'de':
        'Die Wertungen werden in Kilogramm berechnet (zur Anzeige umgerechnet). Kalibriere die Perzentile mit OpenPowerlifting.org (gemeinfrei).',
    'pt':
        'As pontuações são calculadas em quilogramas (convertidas para exibição). Recalibre os percentis em OpenPowerlifting.org (domínio público).',
  },

  // ---- Profile -------------------------------------------------------------
  'your_profile': {
    'en': 'Your profile',
    'fr': 'Ton profil',
    'es': 'Tu perfil',
    'de': 'Dein Profil',
    'pt': 'O seu perfil',
  },
  'profile_subtitle': {
    'en': 'Used to compare your lifts against population standards.',
    'fr': 'Sert à comparer tes charges aux standards de la population.',
    'es': 'Se usa para comparar tus levantamientos con los estándares de la población.',
    'de': 'Wird genutzt, um deine Übungen mit Bevölkerungsstandards zu vergleichen.',
    'pt': 'Usado para comparar os seus levantamentos com os padrões da população.',
  },
  'sex': {
    'en': 'Sex',
    'fr': 'Sexe',
    'es': 'Sexo',
    'de': 'Geschlecht',
    'pt': 'Sexo',
  },
  'units': {
    'en': 'Units',
    'fr': 'Unités',
    'es': 'Unidades',
    'de': 'Einheiten',
    'pt': 'Unidades',
  },
  'bodyweight': {
    'en': 'Bodyweight',
    'fr': 'Poids du corps',
    'es': 'Peso corporal',
    'de': 'Körpergewicht',
    'pt': 'Peso corporal',
  },
  'age_optional': {
    'en': 'Age (optional)',
    'fr': 'Âge (facultatif)',
    'es': 'Edad (opcional)',
    'de': 'Alter (optional)',
    'pt': 'Idade (opcional)',
  },
  'years_short': {
    'en': 'yrs',
    'fr': 'ans',
    'es': 'años',
    'de': 'J.',
    'pt': 'anos',
  },
  'done': {
    'en': 'Done',
    'fr': 'Terminé',
    'es': 'Listo',
    'de': 'Fertig',
    'pt': 'Concluído',
  },

  // ---- Auth ----------------------------------------------------------------
  'welcome': {
    'en': 'Welcome',
    'fr': 'Bienvenue',
    'es': 'Bienvenido',
    'de': 'Willkommen',
    'pt': 'Bem-vindo',
  },
  'login_subtitle': {
    'en': 'Create an account or sign in to save your progress.',
    'fr': 'Crée un compte ou connecte-toi pour sauvegarder ta progression.',
    'es': 'Crea una cuenta o inicia sesión para guardar tu progreso.',
    'de': 'Erstelle ein Konto oder melde dich an, um deinen Fortschritt zu speichern.',
    'pt': 'Crie uma conta ou entre para salvar o seu progresso.',
  },
  'email': {
    'en': 'Email',
    'fr': 'E-mail',
    'es': 'Correo electrónico',
    'de': 'E-Mail',
    'pt': 'E-mail',
  },
  'password': {
    'en': 'Password',
    'fr': 'Mot de passe',
    'es': 'Contraseña',
    'de': 'Passwort',
    'pt': 'Senha',
  },
  'create_account': {
    'en': 'Create account',
    'fr': 'Créer un compte',
    'es': 'Crear cuenta',
    'de': 'Konto erstellen',
    'pt': 'Criar conta',
  },
  'sign_in': {
    'en': 'Sign in',
    'fr': 'Se connecter',
    'es': 'Iniciar sesión',
    'de': 'Anmelden',
    'pt': 'Entrar',
  },
  'toggle_to_sign_in': {
    'en': 'Already have an account? Sign in',
    'fr': 'Déjà un compte ? Se connecter',
    'es': '¿Ya tienes una cuenta? Inicia sesión',
    'de': 'Schon ein Konto? Anmelden',
    'pt': 'Já tem uma conta? Entrar',
  },
  'toggle_to_create': {
    'en': 'New here? Create an account',
    'fr': 'Nouveau ? Crée un compte',
    'es': '¿Nuevo aquí? Crea una cuenta',
    'de': 'Neu hier? Konto erstellen',
    'pt': 'Novo aqui? Crie uma conta',
  },
  'continue_google': {
    'en': 'Continue with Google',
    'fr': 'Continuer avec Google',
    'es': 'Continuar con Google',
    'de': 'Mit Google fortfahren',
    'pt': 'Continuar com o Google',
  },
  'continue_guest': {
    'en': 'Continue as guest',
    'fr': 'Continuer en tant qu’invité',
    'es': 'Continuar como invitado',
    'de': 'Als Gast fortfahren',
    'pt': 'Continuar como convidado',
  },
  'or': {
    'en': 'or',
    'fr': 'ou',
    'es': 'o',
    'de': 'oder',
    'pt': 'ou',
  },
  'auth_not_configured': {
    'en': 'Sign-in is not configured yet — continuing as guest.',
    'fr': 'La connexion n’est pas encore configurée — accès en mode invité.',
    'es': 'El inicio de sesión aún no está configurado — continuando como invitado.',
    'de': 'Die Anmeldung ist noch nicht eingerichtet — weiter als Gast.',
    'pt': 'O login ainda não está configurado — continuando como convidado.',
  },
  'err_email_required': {
    'en': 'Enter a valid email address.',
    'fr': 'Saisis une adresse e-mail valide.',
    'es': 'Introduce una dirección de correo válida.',
    'de': 'Gib eine gültige E-Mail-Adresse ein.',
    'pt': 'Insira um e-mail válido.',
  },
  'err_password_short': {
    'en': 'Password must be at least 6 characters.',
    'fr': 'Le mot de passe doit comporter au moins 6 caractères.',
    'es': 'La contraseña debe tener al menos 6 caracteres.',
    'de': 'Das Passwort muss mindestens 6 Zeichen lang sein.',
    'pt': 'A senha deve ter pelo menos 6 caracteres.',
  },
  'err_generic_auth': {
    'en': 'Could not complete sign-in. Please try again.',
    'fr': 'Connexion impossible. Réessaie.',
    'es': 'No se pudo completar el inicio de sesión. Inténtalo de nuevo.',
    'de': 'Anmeldung fehlgeschlagen. Bitte versuche es erneut.',
    'pt': 'Não foi possível concluir o login. Tente novamente.',
  },

  // ---- Progress / history --------------------------------------------------
  'progress': {
    'en': 'Progress',
    'fr': 'Progression',
    'es': 'Progreso',
    'de': 'Fortschritt',
    'pt': 'Progresso',
  },
  'history_subtitle': {
    'en': 'Your saved assessments over time',
    'fr': 'Tes évaluations enregistrées au fil du temps',
    'es': 'Tus evaluaciones guardadas a lo largo del tiempo',
    'de': 'Deine gespeicherten Auswertungen im Zeitverlauf',
    'pt': 'Suas avaliações salvas ao longo do tempo',
  },
  'history_empty': {
    'en': 'No assessments yet. Rate a lift to start tracking your progress.',
    'fr':
        'Aucune évaluation pour l’instant. Évalue un exercice pour suivre ta progression.',
    'es':
        'Aún no hay evaluaciones. Evalúa un ejercicio para empezar a seguir tu progreso.',
    'de':
        'Noch keine Auswertungen. Bewerte eine Übung, um deinen Fortschritt zu verfolgen.',
    'pt':
        'Ainda não há avaliações. Avalie um exercício para acompanhar o seu progresso.',
  },
  'history_log': {
    'en': 'History',
    'fr': 'Historique',
    'es': 'Historial',
    'de': 'Verlauf',
    'pt': 'Histórico',
  },
  'assessments_count': {
    'en': '{n} entries',
    'fr': '{n} entrées',
    'es': '{n} registros',
    'de': '{n} Einträge',
    'pt': '{n} registros',
  },
  'est_1rm_trend': {
    'en': 'Estimated 1RM',
    'fr': '1RM estimé',
    'es': '1RM estimado',
    'de': 'Geschätztes 1RM',
    'pt': '1RM estimado',
  },
  'reps_trend': {
    'en': 'Reps',
    'fr': 'Répétitions',
    'es': 'Repeticiones',
    'de': 'Wiederholungen',
    'pt': 'Repetições',
  },
  'reps_value': {
    'en': '{n} reps',
    'fr': '{n} répétitions',
    'es': '{n} reps',
    'de': '{n} Whlg.',
    'pt': '{n} reps',
  },
  'export': {
    'en': 'Export',
    'fr': 'Exporter',
    'es': 'Exportar',
    'de': 'Exportieren',
    'pt': 'Exportar',
  },
  'exported_clipboard': {
    'en': 'History copied to clipboard (CSV)',
    'fr': 'Historique copié dans le presse-papiers (CSV)',
    'es': 'Historial copiado al portapapeles (CSV)',
    'de': 'Verlauf in die Zwischenablage kopiert (CSV)',
    'pt': 'Histórico copiado para a área de transferência (CSV)',
  },
  'clear_history': {
    'en': 'Clear history',
    'fr': 'Effacer l’historique',
    'es': 'Borrar historial',
    'de': 'Verlauf löschen',
    'pt': 'Limpar histórico',
  },
  'clear_history_q': {
    'en': 'Delete all saved entries for this exercise?',
    'fr': 'Supprimer toutes les entrées enregistrées pour cet exercice ?',
    'es': '¿Eliminar todos los registros guardados de este ejercicio?',
    'de': 'Alle gespeicherten Einträge für diese Übung löschen?',
    'pt': 'Excluir todos os registros salvos deste exercício?',
  },
  'cancel': {
    'en': 'Cancel',
    'fr': 'Annuler',
    'es': 'Cancelar',
    'de': 'Abbrechen',
    'pt': 'Cancelar',
  },
  'delete': {
    'en': 'Delete',
    'fr': 'Supprimer',
    'es': 'Eliminar',
    'de': 'Löschen',
    'pt': 'Excluir',
  },

  // ---- How strength is calculated -----------------------------------------
  'info_button': {
    'en': 'How we calculate your strength',
    'fr': 'Comment nous calculons ta force',
    'es': 'Cómo calculamos tu fuerza',
    'de': 'So berechnen wir deine Kraft',
    'pt': 'Como calculamos a sua força',
  },
  'info_title': {
    'en': 'How strength is calculated',
    'fr': 'Comment la force est calculée',
    'es': 'Cómo se calcula la fuerza',
    'de': 'Wie die Kraft berechnet wird',
    'pt': 'Como a força é calculada',
  },
  'info_intro': {
    'en':
        'Metal Strength turns the weight you lift into a clear level — from Beginner to Elite — by comparing it against population strength standards. Here is how.',
    'fr':
        'Metal Strength transforme la charge que tu soulèves en un niveau clair — de Débutant à Élite — en la comparant aux standards de force de la population. Voici comment.',
    'es':
        'Metal Strength convierte el peso que levantas en un nivel claro —de Principiante a Élite— comparándolo con los estándares de fuerza de la población. Así funciona.',
    'de':
        'Metal Strength verwandelt das Gewicht, das du hebst, in ein klares Level — von Anfänger bis Elite — durch Vergleich mit Kraftstandards der Bevölkerung. So funktioniert es.',
    'pt':
        'O Metal Strength transforma o peso que você levanta em um nível claro — de Iniciante a Elite — comparando-o com os padrões de força da população. Veja como.',
  },
  'info_step1_title': {
    'en': '1 · Estimate your one-rep max',
    'fr': '1 · Estime ton 1RM',
    'es': '1 · Estima tu 1RM',
    'de': '1 · Schätze dein 1RM',
    'pt': '1 · Estime o seu 1RM',
  },
  'info_step1_body': {
    'en':
        'From the weight and reps of your best set, we estimate the most you could lift for a single rep (your 1RM) using the Epley formula — the industry standard.',
    'fr':
        "À partir de la charge et des répétitions de ta meilleure série, on estime le maximum que tu pourrais soulever en une seule répétition (ton 1RM) avec la formule d'Epley, le standard du secteur.",
    'es':
        'A partir del peso y las repeticiones de tu mejor serie, estimamos el máximo que podrías levantar en una sola repetición (tu 1RM) con la fórmula de Epley, el estándar del sector.',
    'de':
        'Aus Gewicht und Wiederholungen deines besten Satzes schätzen wir das Maximum, das du für eine einzige Wiederholung heben könntest (dein 1RM), mit der Epley-Formel — dem Branchenstandard.',
    'pt':
        'A partir do peso e das repetições da sua melhor série, estimamos o máximo que você conseguiria levantar em uma única repetição (o seu 1RM) com a fórmula de Epley — o padrão do setor.',
  },
  'info_formula_1rm': {
    'en': '1RM = weight × (1 + reps ÷ 30)',
    'fr': '1RM = charge × (1 + répétitions ÷ 30)',
    'es': '1RM = peso × (1 + repeticiones ÷ 30)',
    'de': '1RM = Gewicht × (1 + Wiederholungen ÷ 30)',
    'pt': '1RM = peso × (1 + repetições ÷ 30)',
  },
  'info_step2_title': {
    'en': '2 · Bodyweight ratio',
    'fr': '2 · Ratio poids du corps',
    'es': '2 · Ratio peso corporal',
    'de': '2 · Körpergewicht-Verhältnis',
    'pt': '2 · Razão peso corporal',
  },
  'info_step2_body': {
    'en':
        'Your estimated 1RM is divided by your bodyweight. Lifting more relative to your size means a higher score, so a 60 kg and a 100 kg lifter are compared fairly.',
    'fr':
        'Ton 1RM estimé est divisé par ton poids de corps. Soulever davantage par rapport à ta taille donne un meilleur score, pour comparer équitablement un pratiquant de 60 kg et un de 100 kg.',
    'es':
        'Tu 1RM estimado se divide entre tu peso corporal. Levantar más en relación con tu tamaño da una mejor puntuación, así un levantador de 60 kg y otro de 100 kg se comparan de forma justa.',
    'de':
        'Dein geschätztes 1RM wird durch dein Körpergewicht geteilt. Wer im Verhältnis zur eigenen Größe mehr hebt, erzielt eine höhere Wertung — so werden ein 60-kg- und ein 100-kg-Athlet fair verglichen.',
    'pt':
        'O seu 1RM estimado é dividido pelo seu peso corporal. Levantar mais em relação ao seu tamanho gera uma pontuação maior, então um praticante de 60 kg e outro de 100 kg são comparados de forma justa.',
  },
  'info_step3_title': {
    'en': '3 · Your strength level',
    'fr': '3 · Ton niveau de force',
    'es': '3 · Tu nivel de fuerza',
    'de': '3 · Dein Kraftniveau',
    'pt': '3 · O seu nível de força',
  },
  'info_step3_body': {
    'en':
        'The ratio is matched against strength standards for your sex to place you in one of five levels: Beginner, Novice, Intermediate, Advanced, or Elite.',
    'fr':
        "Le ratio est comparé aux standards de force selon ton sexe pour te placer dans l'un des cinq niveaux : Débutant, Novice, Intermédiaire, Avancé ou Élite.",
    'es':
        'El ratio se compara con los estándares de fuerza según tu sexo para situarte en uno de los cinco niveles: Principiante, Novato, Intermedio, Avanzado o Élite.',
    'de':
        'Das Verhältnis wird mit den Kraftstandards für dein Geschlecht abgeglichen und ordnet dich einer von fünf Stufen zu: Anfänger, Neuling, Mittelstufe, Fortgeschritten oder Elite.',
    'pt':
        'A razão é comparada com os padrões de força para o seu sexo para colocá-lo em um de cinco níveis: Iniciante, Novato, Intermediário, Avançado ou Elite.',
  },
  'info_step4_title': {
    'en': '4 · Percentile',
    'fr': '4 · Centile',
    'es': '4 · Percentil',
    'de': '4 · Perzentil',
    'pt': '4 · Percentil',
  },
  'info_step4_body': {
    'en':
        "We also estimate how you compare to other lifters — the 'stronger than X%' figure — by interpolating between the level thresholds.",
    'fr':
        'On estime aussi ta position par rapport aux autres — le « plus fort que X % » — en interpolant entre les seuils des niveaux.',
    'es':
        'También estimamos cómo te comparas con otros —la cifra de «más fuerte que el X %»— interpolando entre los umbrales de los niveles.',
    'de':
        "Wir schätzen außerdem, wie du im Vergleich zu anderen stehst — die Angabe 'stärker als X %' — durch Interpolation zwischen den Stufengrenzen.",
    'pt':
        "Também estimamos como você se compara a outros praticantes — o número de 'mais forte que X%' — interpolando entre os limites dos níveis.",
  },
  'info_age_title': {
    'en': 'Age adjustment',
    'fr': "Ajustement selon l'âge",
    'es': 'Ajuste por edad',
    'de': 'Altersanpassung',
    'pt': 'Ajuste por idade',
  },
  'info_age_body': {
    'en':
        'Strength peaks around 25–35. If you enter your age, your 1RM is gently normalized so younger and older lifters are compared on equal footing.',
    'fr':
        'La force culmine autour de 25–35 ans. Si tu indiques ton âge, ton 1RM est légèrement normalisé pour comparer équitablement les pratiquants plus jeunes et plus âgés.',
    'es':
        'La fuerza alcanza su punto máximo entre los 25 y los 35 años. Si introduces tu edad, tu 1RM se normaliza ligeramente para comparar de forma justa a levantadores más jóvenes y mayores.',
    'de':
        'Die Kraft erreicht ihren Höhepunkt mit etwa 25–35 Jahren. Wenn du dein Alter angibst, wird dein 1RM leicht normalisiert, damit jüngere und ältere Athleten fair verglichen werden.',
    'pt':
        'A força atinge o pico por volta dos 25–35 anos. Se você informar a sua idade, o seu 1RM é levemente normalizado para comparar de forma justa praticantes mais novos e mais velhos.',
  },
  'info_bw_title': {
    'en': 'Bodyweight exercises',
    'fr': 'Exercices au poids du corps',
    'es': 'Ejercicios de peso corporal',
    'de': 'Körpergewichtsübungen',
    'pt': 'Exercícios de peso corporal',
  },
  'info_bw_body': {
    'en':
        'Movements like pull-ups, push-ups, and planks are rated by the reps (or seconds) you perform against rep standards for your sex — no external weight needed.',
    'fr':
        'Les mouvements comme les tractions, les pompes et la planche sont évalués selon les répétitions (ou les secondes) réalisées face aux standards de ton sexe — sans charge externe.',
    'es':
        'Movimientos como dominadas, flexiones y plancha se evalúan por las repeticiones (o segundos) que realizas frente a los estándares de tu sexo, sin peso externo.',
    'de':
        'Übungen wie Klimmzüge, Liegestütze und Planks werden anhand der Wiederholungen (oder Sekunden) bewertet, die du gegenüber den Standards deines Geschlechts schaffst — ohne Zusatzgewicht.',
    'pt':
        'Movimentos como barra fixa, flexões e prancha são avaliados pelas repetições (ou segundos) que você realiza frente aos padrões do seu sexo — sem peso externo.',
  },
  'info_total_title': {
    'en': 'Powerlifting total',
    'fr': 'Total force athlétique',
    'es': 'Total de powerlifting',
    'de': 'Powerlifting-Total',
    'pt': 'Total de powerlifting',
  },
  'info_total_body': {
    'en':
        'For squat, bench press, and deadlift you can enter all three to get your total and Wilks/DOTS score — the coefficients used to compare lifters across bodyweights.',
    'fr':
        'Pour le squat, le développé couché et le soulevé de terre, tu peux saisir les trois pour obtenir ton total et ton score Wilks/DOTS, les coefficients qui comparent les pratiquants de poids différents.',
    'es':
        'Para sentadilla, press de banca y peso muerto puedes introducir los tres para obtener tu total y tu puntuación Wilks/DOTS, los coeficientes que comparan levantadores de distinto peso corporal.',
    'de':
        'Für Kniebeuge, Bankdrücken und Kreuzheben kannst du alle drei eingeben, um dein Total und deine Wilks/DOTS-Wertung zu erhalten — die Koeffizienten, die Athleten über Körpergewichte hinweg vergleichen.',
    'pt':
        'Para agachamento, supino e levantamento terra você pode inserir os três para obter o seu total e a sua pontuação Wilks/DOTS, os coeficientes que comparam praticantes de pesos corporais diferentes.',
  },
  'info_disclaimer': {
    'en':
        'All standards are ratio-based estimates for guidance and motivation — not measured dataset percentiles or medical advice.',
    'fr':
        'Tous les standards sont des estimations par ratio, à titre indicatif et motivant — ni centiles mesurés, ni avis médical.',
    'es':
        'Todos los estándares son estimaciones por ratio, con fines orientativos y de motivación, no percentiles medidos ni consejo médico.',
    'de':
        'Alle Standards sind verhältnisbasierte Schätzungen zur Orientierung und Motivation — keine gemessenen Perzentile und keine medizinische Beratung.',
    'pt':
        'Todos os padrões são estimativas por razão, para orientação e motivação — não são percentis medidos nem aconselhamento médico.',
  },
};
