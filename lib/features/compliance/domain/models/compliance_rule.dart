class ComplianceRule {
  final String id;
  final String clause;
  final String document;
  final String title;
  final String description;
  final bool isMandatory;

  ComplianceRule({
    required this.id,
    required this.clause,
    required this.document,
    required this.title,
    required this.description,
    required this.isMandatory,
  });

  factory ComplianceRule.fromJson(Map<String, dynamic> json) {
    return ComplianceRule(
      id: json['id'] as String,
      clause: json['clause'] as String,
      document: json['document'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      isMandatory: json['isMandatory'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clause': clause,
      'document': document,
      'title': title,
      'description': description,
      'isMandatory': isMandatory,
    };
  }
}
