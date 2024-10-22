class ElectionResult {
  final String candidateName;
  final String partyName;
  final int votes;

  ElectionResult(
      {required this.candidateName,
      required this.partyName,
      required this.votes});

  factory ElectionResult.fromJson(String key, int votes) {
    final parts = key.split(' (Party: ');
    final candidateName = parts[0];
    final partyName =
        parts[1].substring(0, parts[1].length - 1); // remove trailing ')'
    return ElectionResult(
      candidateName: candidateName,
      partyName: partyName,
      votes: votes,
    );
  }
}
