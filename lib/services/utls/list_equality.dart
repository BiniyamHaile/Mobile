bool listsEqual(List list1, List list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
        if (list1[i] != list2[i]) return false;
    }
    return true;
}

bool isWhitespace(String char) {
    return char.trim().isEmpty;
}