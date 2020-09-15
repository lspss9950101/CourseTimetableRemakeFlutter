class Session {
  String name;
  DateTime begin, end;
  Session(this.begin, this.end, {this.name});
  Session.dummy() {
    this.name = 'S';
    this.begin = DateTime.now();
    this.end = DateTime.now();
  }
}