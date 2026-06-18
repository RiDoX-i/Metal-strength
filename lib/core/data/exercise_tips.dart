import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../models/exercise.dart';
import 'exercise_art.dart';

/// Original, copyright-free coaching tips for getting stronger, grouped by
/// movement pattern and localized (EN/FR). Returns 5 bullet points.
List<String> tipsFor(BuildContext context, Exercise exercise) {
  final lang = context.watch<AppState>().locale.languageCode;
  final group = _tipGroup(patternFor(exercise));
  final byLang = _tips[group] ?? _tips['general']!;
  return byLang[lang] ?? byLang['en']!;
}

/// Collapse the (finer) figure pattern into a tips group.
String _tipGroup(String pattern) {
  switch (pattern) {
    case 'squat':
    case 'front_squat':
    case 'leg_press':
      return 'squat';
    case 'deadlift':
    case 'hinge':
      return 'hinge';
    case 'bench_press':
    case 'incline_press':
      return 'bench';
    case 'push_up':
    case 'dip':
      return 'bodyweight_push';
    case 'overhead_press':
      return 'overhead';
    case 'pull_up':
    case 'pulldown':
      return 'vertical_pull';
    case 'row':
      return 'row';
    case 'curl':
      return 'curl';
    case 'triceps':
      return 'triceps';
    case 'lateral_raise':
    case 'shrug':
      return 'shoulders_iso';
    case 'lunge':
      return 'lunge';
    case 'leg_extension':
    case 'leg_curl':
    case 'calf_raise':
      return 'leg_iso';
    case 'hip_thrust':
      return 'glutes';
    case 'plank':
    case 'crunch':
    case 'hanging_leg_raise':
      return 'core';
    case 'kettlebell_swing':
      return 'power';
    case 'olympic':
      return 'olympic';
    default:
      return 'general';
  }
}

const Map<String, Map<String, List<String>>> _tips = {
  'squat': {
    'en': [
      'Brace your core hard before each rep — take a big breath and hold it through the bottom.',
      'Drive your knees out in line with your toes so your hips track properly.',
      'Squat to at least parallel with control; depth builds more strength than half reps.',
      'Keep your mid-foot planted and push the floor away evenly through both legs.',
      'Add weight gradually (2.5–5 kg/week) and train the lift 2–3× per week.',
    ],
    'fr': [
      'Gaine fortement tes abdos avant chaque répétition — grande inspiration bloquée jusqu’en bas.',
      'Pousse les genoux vers l’extérieur, alignés avec tes orteils.',
      'Descends au moins à la parallèle, en contrôle ; la profondeur développe plus de force.',
      'Garde le milieu du pied ancré et repousse le sol uniformément avec les deux jambes.',
      'Ajoute du poids progressivement (2,5–5 kg/semaine) et entraîne le mouvement 2–3×/semaine.',
    ],
  },
  'hinge': {
    'en': [
      'Set your back flat and brace before the bar leaves the floor — never round under load.',
      'Push the floor away with your legs while keeping the bar close to your shins.',
      'Squeeze your glutes to finish the lift; don’t lean back past lockout.',
      'Build your grip with double-overhand holds or straps for heavy pulls.',
      'Train the posterior chain twice a week and prioritize recovery between heavy sessions.',
    ],
    'fr': [
      'Garde le dos plat et gainé avant que la barre ne quitte le sol — ne t’arrondis jamais.',
      'Repousse le sol avec les jambes en gardant la barre proche des tibias.',
      'Serre les fessiers pour terminer ; ne te penche pas en arrière au verrouillage.',
      'Renforce ta prise (double pronation ou sangles) pour les tirages lourds.',
      'Travaille la chaîne postérieure deux fois par semaine et soigne la récupération.',
    ],
  },
  'bench': {
    'en': [
      'Pull your shoulder blades back and down and keep them pinned to the bench.',
      'Keep your wrists stacked over your elbows and lower the bar to your lower chest.',
      'Drive your feet into the floor for a stable base (leg drive).',
      'Touch the chest under control and press in a slight arc back over the shoulders.',
      'Train pressing 2× per week and add triceps and upper-back work for carryover.',
    ],
    'fr': [
      'Resserre les omoplates vers le bas et garde-les plaquées sur le banc.',
      'Garde les poignets au-dessus des coudes et descends la barre vers le bas des pectoraux.',
      'Ancre les pieds au sol pour une base stable (drive des jambes).',
      'Touche la poitrine en contrôle et pousse en léger arc vers les épaules.',
      'Pousse 2×/semaine et ajoute triceps et haut du dos pour le transfert.',
    ],
  },
  'bodyweight_push': {
    'en': [
      'Keep a straight line from head to heels — squeeze your glutes and brace your abs.',
      'Lower under control until your chest is just above the floor (or elbows ~90°).',
      'Add reps first, then add load (a backpack or belt) once you pass ~15 clean reps.',
      'Keep elbows tucked ~45° from your sides to protect the shoulders.',
      'Train them often; bodyweight pushes respond well to frequent practice.',
    ],
    'fr': [
      'Garde une ligne droite de la tête aux talons — serre fessiers et abdos.',
      'Descends en contrôle jusqu’à frôler le sol (ou coudes à ~90°).',
      'Ajoute d’abord des répétitions, puis de la charge (sac, ceinture) au-delà de ~15 reps.',
      'Garde les coudes à ~45° du corps pour protéger les épaules.',
      'Entraîne-les souvent ; les poussées au poids du corps aiment la fréquence.',
    ],
  },
  'overhead': {
    'en': [
      'Brace your abs and squeeze your glutes so you don’t lean back to press.',
      'Keep the bar path vertical — move your head slightly back, then press up and around.',
      'Finish each rep with the bar stacked over your mid-foot and ears.',
      'Strengthen your triceps and upper back to push past sticking points.',
      'Progress slowly; the overhead press adds weight more slowly than bigger lifts.',
    ],
    'fr': [
      'Gaine les abdos et serre les fessiers pour ne pas te cambrer.',
      'Garde une trajectoire verticale — recule légèrement la tête, puis pousse vers le haut.',
      'Termine barre alignée au-dessus du milieu du pied et des oreilles.',
      'Renforce triceps et haut du dos pour passer les points de blocage.',
      'Progresse lentement ; le développé militaire avance moins vite que les gros mouvements.',
    ],
  },
  'vertical_pull': {
    'en': [
      'Start from a full hang and pull your shoulder blades down before bending your arms.',
      'Lead with your chest to the bar and drive your elbows down and back.',
      'Control the lowering — a slow negative builds strength fast.',
      'Add reps, then add weight with a belt once you hit ~10–12 clean reps.',
      'Train pulls as often as you press to keep your shoulders balanced.',
    ],
    'fr': [
      'Pars bras tendus et abaisse les omoplates avant de plier les bras.',
      'Mène la poitrine vers la barre et tire les coudes vers le bas et l’arrière.',
      'Contrôle la descente — une négative lente développe vite la force.',
      'Ajoute des répétitions, puis de la charge (ceinture) au-delà de ~10–12 reps.',
      'Tire aussi souvent que tu pousses pour équilibrer les épaules.',
    ],
  },
  'row': {
    'en': [
      'Hinge at the hips with a flat back and brace your core throughout.',
      'Pull to your lower ribs/belly and squeeze your shoulder blades together.',
      'Avoid jerking with your lower back — keep the torso angle steady.',
      'Pause briefly at the top of each rep for a stronger contraction.',
      'Match your rowing volume to your pressing to protect your shoulders.',
    ],
    'fr': [
      'Charnière des hanches, dos plat et abdos gainés tout du long.',
      'Tire vers le bas des côtes/le ventre et serre les omoplates.',
      'Évite les à-coups du bas du dos — garde l’angle du tronc constant.',
      'Marque une courte pause en haut pour une meilleure contraction.',
      'Équilibre ton volume de tirage et de poussée pour protéger les épaules.',
    ],
  },
  'curl': {
    'en': [
      'Keep your elbows pinned to your sides — only the forearm should move.',
      'Lower slowly (2–3 sec) to make every rep count.',
      'Don’t swing; if you need momentum, the weight is too heavy.',
      'Vary your grip (straight bar, EZ-bar, dumbbells, hammer) for full development.',
      'Biceps recover quickly — train them 2–3× per week with moderate volume.',
    ],
    'fr': [
      'Garde les coudes collés au corps — seul l’avant-bras bouge.',
      'Descends lentement (2–3 s) pour rentabiliser chaque rep.',
      'Pas d’élan ; s’il en faut, la charge est trop lourde.',
      'Varie la prise (barre droite, EZ, haltères, marteau) pour un développement complet.',
      'Les biceps récupèrent vite — 2–3×/semaine en volume modéré.',
    ],
  },
  'triceps': {
    'en': [
      'Keep your upper arms still and extend only at the elbow.',
      'Use a full range of motion — stretch at the bottom, lock out at the top.',
      'Mix heavy pressing (close-grip) with lighter isolation work.',
      'Keep wrists neutral and elbows from flaring to protect the joints.',
      'The triceps are most of your arm size — train them at least twice a week.',
    ],
    'fr': [
      'Garde les bras immobiles et n’étends qu’au niveau du coude.',
      'Utilise toute l’amplitude — étirement en bas, verrouillage en haut.',
      'Combine poussées lourdes (prise serrée) et isolation plus légère.',
      'Garde les poignets neutres et les coudes serrés pour protéger les articulations.',
      'Les triceps font l’essentiel du volume du bras — au moins 2×/semaine.',
    ],
  },
  'shoulders_iso': {
    'en': [
      'Use lighter weight and strict form — leave your ego at the door.',
      'Lead with your elbows and stop around shoulder height.',
      'Pause and squeeze at the top, then lower slowly.',
      'Higher reps (12–20) work well for these smaller muscles.',
      'Train them frequently; delts and traps recover fast.',
    ],
    'fr': [
      'Charge léger et forme stricte — laisse l’ego de côté.',
      'Mène avec les coudes et arrête vers la hauteur des épaules.',
      'Marque une pause et serre en haut, puis descends lentement.',
      'Des répétitions élevées (12–20) conviennent à ces petits muscles.',
      'Entraîne-les souvent ; deltoïdes et trapèzes récupèrent vite.',
    ],
  },
  'lunge': {
    'en': [
      'Take a long enough step so your front shin stays roughly vertical.',
      'Lower under control until your back knee nearly touches the floor.',
      'Keep your torso tall and your front heel planted as you drive up.',
      'Train both legs equally to fix side-to-side imbalances.',
      'Start with bodyweight, then add dumbbells or a barbell as you progress.',
    ],
    'fr': [
      'Fais un pas assez long pour garder le tibia avant presque vertical.',
      'Descends en contrôle jusqu’à frôler le sol avec le genou arrière.',
      'Garde le buste droit et le talon avant ancré en remontant.',
      'Travaille les deux jambes également pour corriger les déséquilibres.',
      'Commence au poids du corps, puis ajoute haltères ou barre.',
    ],
  },
  'leg_iso': {
    'en': [
      'Move slowly and control the lowering phase — no swinging.',
      'Use a full range of motion and pause in the fully shortened position.',
      'Higher reps (10–20) tend to work best for these isolation moves.',
      'Match quad and hamstring work to keep the knee balanced.',
      'For calves, pause at the bottom stretch and rise all the way onto your toes.',
    ],
    'fr': [
      'Bouge lentement et contrôle la descente — pas d’élan.',
      'Utilise toute l’amplitude et marque une pause en position contractée.',
      'Des répétitions élevées (10–20) marchent bien pour ces isolations.',
      'Équilibre quadriceps et ischios pour protéger le genou.',
      'Pour les mollets, marque l’étirement en bas et monte bien sur les pointes.',
    ],
  },
  'glutes': {
    'en': [
      'Tuck your chin and ribs down so you don’t arch through your lower back.',
      'Drive through your heels and squeeze your glutes hard at the top.',
      'Pause for a second at lockout on every rep.',
      'Use a full range — full stretch at the bottom, full squeeze at the top.',
      'Glutes respond to both heavy loads and higher-rep burnout sets.',
    ],
    'fr': [
      'Rentre le menton et les côtes pour ne pas cambrer le bas du dos.',
      'Pousse dans les talons et serre fort les fessiers en haut.',
      'Marque une seconde de pause au verrouillage à chaque rep.',
      'Utilise toute l’amplitude — étirement complet en bas, contraction complète en haut.',
      'Les fessiers aiment les charges lourdes comme les séries longues.',
    ],
  },
  'core': {
    'en': [
      'Brace as if about to be punched — quality tension beats more reps.',
      'Move slowly and avoid yanking with your hip flexors or neck.',
      'Breathe steadily; don’t hold your breath through the set.',
      'Progress by adding time, range, or load rather than just more reps.',
      'Train your core 2–3× per week alongside your heavy compound lifts.',
    ],
    'fr': [
      'Gaine comme si tu allais recevoir un coup — la tension prime sur le nombre.',
      'Bouge lentement, sans tirer avec les fléchisseurs de hanche ni le cou.',
      'Respire régulièrement ; ne bloque pas ta respiration.',
      'Progresse en ajoutant du temps, de l’amplitude ou de la charge.',
      'Travaille la sangle abdominale 2–3×/semaine avec tes gros mouvements.',
    ],
  },
  'power': {
    'en': [
      'Drive the movement with an explosive hip snap, not your arms.',
      'Keep your back flat and let the hips do the work — it’s a hinge, not a squat.',
      'Snap your glutes hard at the top and let the weight float.',
      'Keep the movement crisp; stop the set when speed drops.',
      'Build a strong deadlift and hinge to power your explosive work.',
    ],
    'fr': [
      'Donne l’impulsion avec un coup de hanche explosif, pas avec les bras.',
      'Garde le dos plat et laisse les hanches travailler — c’est une charnière, pas un squat.',
      'Claque les fessiers en haut et laisse la charge flotter.',
      'Garde le geste vif ; arrête la série quand la vitesse chute.',
      'Un bon soulevé de terre et une bonne charnière nourrissent l’explosivité.',
    ],
  },
  'olympic': {
    'en': [
      'Learn the technique with a coach or light bar before going heavy.',
      'Keep the bar close to your body and finish with a full, violent hip extension.',
      'Move fast under the bar and catch in a stable, braced position.',
      'Drill positions and footwork often — these lifts reward practice.',
      'Build your squat and pulling strength to support bigger lifts.',
    ],
    'fr': [
      'Apprends la technique avec un coach et une barre légère avant de charger.',
      'Garde la barre proche du corps et finis par une extension de hanche complète et puissante.',
      'Passe vite sous la barre et réceptionne en position stable et gainée.',
      'Répète positions et jeu de jambes souvent — ces mouvements récompensent la pratique.',
      'Développe ton squat et ta force de tirage pour soutenir des charges plus lourdes.',
    ],
  },
  'general': {
    'en': [
      'Train the movement 2–3× per week with progressive overload.',
      'Add a little weight or a rep when the current load feels solid.',
      'Use a full range of motion with controlled, deliberate reps.',
      'Warm up properly and stop sets shy of total failure most of the time.',
      'Sleep, protein, and consistency drive most of your strength gains.',
    ],
    'fr': [
      'Entraîne le mouvement 2–3×/semaine en surcharge progressive.',
      'Ajoute un peu de poids ou une rep quand la charge actuelle est solide.',
      'Utilise toute l’amplitude avec des répétitions contrôlées.',
      'Échauffe-toi bien et arrête souvent les séries avant l’échec total.',
      'Sommeil, protéines et régularité font l’essentiel des progrès.',
    ],
  },
};
