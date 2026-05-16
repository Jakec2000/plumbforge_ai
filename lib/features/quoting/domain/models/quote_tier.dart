class QuoteTier {
  final String title;
  final String description;
  final double addedValue;
  final bool isSelected;

  QuoteTier({
    required this.title,
    required this.description,
    required this.addedValue,
    this.isSelected = false,
  });
}
