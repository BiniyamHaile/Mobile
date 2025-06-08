class HashtagSuggestion {
  final String hashtag;
  final String postCount;

  HashtagSuggestion(this.hashtag, this.postCount);

   @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HashtagSuggestion &&
          runtimeType == other.runtimeType &&
          hashtag == other.hashtag &&
          postCount == other.postCount;

  @override
  int get hashCode => hashtag.hashCode ^ postCount.hashCode;
}