enum LikeableType {
  reel('Reel'),
  comment('Comment');

  final String value;
  const LikeableType(this.value);

  factory LikeableType.fromValue(String value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Unknown LikeableType value: $value'),
    );
  }
}