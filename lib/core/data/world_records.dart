import '../models/sex.dart';

/// A single world-record entry. [weightKg] is stored in kilograms and converted
/// for display. [categoryKey] is an l10n key (see app_strings `wr_cat_*`).
class WorldRecord {
  const WorldRecord({
    required this.holder,
    required this.year,
    required this.weightKg,
    required this.categoryKey,
  });

  final String holder;
  final int year;
  final double weightKg;
  final String categoryKey;
}

/// Per-exercise male/female records.
class _RecordPair {
  const _RecordPair({this.male, this.female});
  final WorldRecord? male;
  final WorldRecord? female;
}

/// Widely-cited all-time best lifts, keyed by exercise id. This is a curated
/// starter set covering the iconic lifts — VERIFY AND EXTEND before a store
/// release, as records change and vary by federation. Exercises absent here (or
/// missing a record for the user's sex) simply show no record card.
const Map<String, _RecordPair> _records = {
  'squat': _RecordPair(
    male: WorldRecord(
        holder: 'Ray Williams',
        year: 2019,
        weightKg: 490,
        categoryKey: 'wr_cat_raw_pl'),
    female: WorldRecord(
        holder: 'Sonita Muluh',
        year: 2023,
        weightKg: 305,
        categoryKey: 'wr_cat_raw_pl'),
  ),
  'bench-press': _RecordPair(
    male: WorldRecord(
        holder: 'Julius Maddox',
        year: 2020,
        weightKg: 355,
        categoryKey: 'wr_cat_raw_pl'),
    female: WorldRecord(
        holder: 'April Mathis',
        year: 2016,
        weightKg: 207.5,
        categoryKey: 'wr_cat_raw_pl'),
  ),
  'deadlift': _RecordPair(
    male: WorldRecord(
        holder: 'Hafþór Júlíus Björnsson',
        year: 2020,
        weightKg: 501,
        categoryKey: 'wr_cat_strongman'),
    female: WorldRecord(
        holder: 'Tamara Walcott',
        year: 2022,
        weightKg: 290.5,
        categoryKey: 'wr_cat_raw_pl'),
  ),
  'clean-and-jerk': _RecordPair(
    male: WorldRecord(
        holder: 'Lasha Talakhadze',
        year: 2021,
        weightKg: 267,
        categoryKey: 'wr_cat_oly'),
    female: WorldRecord(
        holder: 'Li Wenwen',
        year: 2021,
        weightKg: 187,
        categoryKey: 'wr_cat_oly'),
  ),
  'snatch': _RecordPair(
    male: WorldRecord(
        holder: 'Lasha Talakhadze',
        year: 2021,
        weightKg: 225,
        categoryKey: 'wr_cat_oly'),
    female: WorldRecord(
        holder: 'Tatiana Kashirina',
        year: 2014,
        weightKg: 155,
        categoryKey: 'wr_cat_oly'),
  ),
};

/// The world record for [exerciseId] matching [sex], or null if none is
/// tracked (the UI hides the card in that case).
WorldRecord? worldRecordFor(String exerciseId, Sex sex) {
  final pair = _records[exerciseId];
  if (pair == null) return null;
  return sex.isMale ? pair.male : pair.female;
}
