enum NavigationAction {
  push,
  pop,
  replace,
  remove;

  @override
  String toString() {
    return super.toString().split('.').last;
  }
}
