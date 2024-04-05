class SkipTimes {
  Opening op;
  Ending ed;
  double epLength = 0;
  SkipTimes({required this.op, required this.ed, this.epLength = 0});
}

class Opening {
  double start;
  double end;
  Opening({required this.start, required this.end});
}
class Ending {
  double start;
  double end;
  Ending({required this.start, required this.end});
}