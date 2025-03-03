class SpinnerEntry {
  SpinnerEntry({
    required this.name,
    required this.nickName,
    this.isPresent = true,
  });
  final String name;
  final String nickName;
  bool isPresent;

  factory SpinnerEntry.fromCsv(List<dynamic> data) {
    if (data.length < 3) {
      throw Exception('Invalid row:\n{$data}');
    }
    return SpinnerEntry(
      name: data[0],
      nickName: data[1],
      isPresent: bool.tryParse(data[2].toString()) ?? true,
    );
  }
}
