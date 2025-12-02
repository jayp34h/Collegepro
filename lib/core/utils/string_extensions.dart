/// String extensions to provide capitalize functionality
/// that was removed in recent Flutter versions
extension StringCapitalization on String {
  /// Capitalizes the first letter of the string and makes the rest lowercase
  /// Example: "hello world" -> "Hello world"
  String capitalize() {
    if (isEmpty) return this;
    if (length == 1) return toUpperCase();
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
  
  /// Capitalizes the first letter of each word in the string
  /// Example: "hello world" -> "Hello World"
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.isEmpty ? word : word.capitalize())
        .join(' ');
  }
  
  /// Capitalizes only the first letter, keeping the rest as is
  /// Example: "hELLO wORLD" -> "HELLO wORLD"
  String capitalizeFirst() {
    if (isEmpty) return this;
    if (length == 1) return toUpperCase();
    return this[0].toUpperCase() + substring(1);
  }
  
  /// Checks if string is null or empty
  bool get isNullOrEmpty => isEmpty;
  
  /// Checks if string is not null and not empty
  bool get isNotNullOrEmpty => isNotEmpty;
}
