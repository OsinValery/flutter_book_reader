extension MyString on String {
  /// returns last position of one character [shar]
  /// in text between [start] and [end] positions
  /// returns -1, if no char in this range
  int findLastSimbolInRange(String char, int start, int end) {
    assert(char.length == 1);
    assert(start >= 0 && start < length);
    assert(start < end && end <= length);

    while (start != end) {
      if (this[end] == char) return end;
      end -= 1;
    }
    return -1;
  }

  /// splits text on fragments of [chanksLen] lengths, make less length, if borders brake the words.
  /// slits string from [start] to [end], if [end] == null, [end] = length of string
  Iterable<String> splitTextByChanks(int chanksLen,
      {int start = 0, int? end}) sync* {
    int currentPos = start;
    int textEnd = end ?? length;

    while (true) {
      int nextPos = currentPos + chanksLen;
      if (nextPos >= textEnd) {
        yield substring(currentPos);
        return;
      }
      int lastSpacePos = findLastSimbolInRange(" ", currentPos, nextPos);
      if (lastSpacePos != -1) nextPos = lastSpacePos;
      yield substring(currentPos, nextPos);
      currentPos = nextPos + (lastSpacePos == -1 ? 0 : 1);
    }
  }
}
