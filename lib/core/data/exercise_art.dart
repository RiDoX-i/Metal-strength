import '../models/exercise.dart';

/// Asset path to the **equipment-category** icon for [exercise]. Every
/// exercise sharing an [Equipment] type shows the same logo (all barbell
/// lifts use the barbell icon, all dumbbell lifts the dumbbell icon, …), so
/// the catalog reads as one consistent icon set. The enum name maps 1:1 to a
/// file in `assets/images/` and always exists; the same icon is used for both
/// sexes. (The movement-pattern art lives in `assets/images/figures/` and is
/// still selected by [patternFor] for the improvement tips.)
String figureFor(Exercise exercise) =>
    'assets/images/${exercise.equipment.name}.svg';

/// The movement-pattern token for [exercise] (e.g. `squat`, `bench_press`).
/// Shared by the figure art and the improvement tips so they stay in sync.
String patternFor(Exercise exercise) {
  final s = '${exercise.id} ${exercise.name}'.toLowerCase();
  bool has(List<String> keys) => keys.any(s.contains);

  // Order matters: most specific patterns first so generic words ("press",
  // "row", "squat", "curl") don't capture a more specific movement.

  // Posterior-chain hinges (must beat the generic "deadlift" / "squat").
  if (has(['romanian', 'stiff-leg', 'stiff leg', 'good-morning', 'good morning',
      'rdl'])) {
    return _f('hinge');
  }
  if (has(['hyperextension', 'hyper-extension', 'back-extension',
      'back extension', 'reverse-hyper', 'superman'])) {
    return _f('hinge');
  }
  // Deadlift family (before Olympic, so "snatch-grip-deadlift" stays a pull).
  if (has(['deadlift', 'rack-pull', 'rack pull', 'deficit'])) return _f('deadlift');

  // Glute bridges / hip thrusts and glute-isolation floor work.
  if (has(['hip-thrust', 'hip thrust', 'glute-bridge', 'glute bridge',
      'frog-pump', 'frog pump', 'donkey-kick', 'fire-hydrant', 'clamshell',
      'single-leg-hip', 'single-leg-glute'])) {
    return _f('hip_thrust');
  }

  if (has(['swing'])) return _f('kettlebell_swing');
  if (has(['clean', 'snatch', 'jerk', 'high-pull', 'high pull'])) {
    return _f('olympic');
  }

  if (has(['front-squat', 'front squat'])) return _f('front_squat');
  if (has(['overhead-squat', 'overhead squat'])) return _f('olympic');
  if (has(['leg-press', 'leg press', 'hack-squat', 'hack squat'])) {
    return _f('leg_press');
  }
  if (has(['split-squat', 'split squat', 'lunge', 'step-up', 'step up',
      'curtsy'])) {
    return _f('lunge');
  }
  if (has(['squat', 'pistol', 'wall-sit', 'wall sit', 'sissy'])) {
    return _f('squat');
  }

  if (has(['calf', 'tibialis'])) return _f('calf_raise');
  if (has(['leg-curl', 'leg curl', 'ham-raise', 'nordic', 'glute-ham',
      'hamstring'])) {
    return _f('leg_curl');
  }
  if (has(['leg-extension', 'leg extension'])) return _f('leg_extension');

  // Arms / shoulders.
  if (has(['triceps', 'tricep', 'skull', 'pushdown', 'push-down', 'kickback',
      'jm-press', 'jm press', 'french-press'])) {
    return _f('triceps');
  }
  if (has(['lateral', 'rear-delt', 'rear delt', 'rear', 'reverse-fly',
      'reverse fly', ' fly', 'flye', 'face-pull', 'face pull', 'upright',
      'front-raise', 'front raise', 'pec-deck', 'pec deck'])) {
    return _f('lateral_raise');
  }
  if (has(['shrug'])) return _f('shrug');

  // Presses.
  if (has(['incline'])) return _f('incline_press');
  if (has(['overhead-press', 'overhead press', 'shoulder-press',
      'shoulder press', 'military', 'push-press', 'push press', 'arnold',
      'behind-neck', 'behind the neck', 'landmine-press', 'z-press',
      'thruster'])) {
    return _f('overhead_press');
  }

  // Pulls.
  if (has(['pulldown', 'pull-down', 'lat-pull', 'pullover'])) {
    return _f('pulldown');
  }
  if (has(['pull-up', 'pull up', 'pullup', 'chin-up', 'chin up', 'chinup',
      'muscle-up', 'muscle up'])) {
    return _f('pull_up');
  }
  if (has(['row'])) return _f('row');
  if (has(['dip'])) return _f('dip');
  if (has(['push-up', 'push up', 'pushup'])) return _f('push_up');

  if (has(['curl'])) return _f('curl'); // leg-curl already handled above

  // Remaining horizontal presses (bench, chest press, db press, floor/pin).
  if (has(['bench', 'chest-press', 'chest press', 'floor-press', 'floor press',
      'pin-press', 'pin press', 'press'])) {
    return _f('bench_press');
  }

  // Core.
  if (has(['plank'])) return _f('plank');
  if (has(['hanging-leg', 'hanging leg', 'hanging-knee', 'hanging knee',
      'toes-to-bar', 'toes to bar', 'leg-raise', 'leg raise', 'knee-raise',
      'knee raise', 'l-sit', 'l sit'])) {
    return _f('hanging_leg_raise');
  }
  if (has(['crunch', 'sit-up', 'sit up', 'situp', 'russian-twist',
      'russian twist', 'bicycle', 'v-up', 'v up', 'dead-bug', 'dead bug',
      'flutter', 'hollow', 'ab-wheel', 'ab wheel', 'mountain-climber',
      'mountain climber', 'bird-dog', 'bird dog'])) {
    return _f('crunch');
  }

  return _f('generic');
}

/// Identity helper kept so every rule reads `return _f('pattern')`.
String _f(String token) => token;
