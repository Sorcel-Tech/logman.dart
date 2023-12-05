enum LogmanRecordType {
  simple,
  network,
  navigation;

  @override
  String toString() {
    return super.toString().split('.').last;
  }
}
