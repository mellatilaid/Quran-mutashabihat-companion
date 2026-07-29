/// Identifies a single ayah — used as the .family argument for Screen 3
/// since a provider family key needs to be a single hashable value.
class AyahKey {
  final int surah;
  final int ayah;
  const AyahKey(this.surah, this.ayah);

  @override
  bool operator ==(Object other) =>
      other is AyahKey && other.surah == surah && other.ayah == ayah;

  @override
  int get hashCode => Object.hash(surah, ayah);
}
