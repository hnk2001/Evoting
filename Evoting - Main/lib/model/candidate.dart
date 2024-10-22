class Candidate {
  final String name;
  final String party;

  Candidate({required this.name, required this.party});

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      name: json['name'] as String,
      party: json['party'] as String,
    );
  }
}
