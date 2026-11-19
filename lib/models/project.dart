/// Model representing a Teen Project on Funngro.
class Project {
  final String id;
  final String title;
  final String company;
  final int payout;

  Project({
    required this.id,
    required this.title,
    required this.company,
    required this.payout,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Project && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
