enum Satisfaction {
  insatisfait,
  correct,
  satisfait,
  tresSatisfait;

  static Satisfaction fromInt(int value) => switch (value) {
    1 => Satisfaction.insatisfait,
    2 => Satisfaction.correct,
    3 => Satisfaction.satisfait,
    _ => Satisfaction.tresSatisfait,
  };

  int toInt() => index + 1;
}
