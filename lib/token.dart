// --- Data Model for Etherscan Transaction ---
class TokenTransaction {
  final String hash;
  final String from;
  final String to;
  final BigInt value; // Amount transferred (in wei)
  final BigInt gasPrice;
  final BigInt gasUsed;
  final int blockNumber;
  final int timeStamp; // Unix timestamp
  final String tokenSymbol;
  final int tokenDecimal;

  TokenTransaction({
    required this.hash,
    required this.from,
    required this.to,
    required this.value,
    required this.gasPrice,
    required this.gasUsed,
    required this.blockNumber,
    required this.timeStamp,
    required this.tokenSymbol,
    required this.tokenDecimal,
  });

  // Factory method to parse JSON from Etherscan API
  factory TokenTransaction.fromJson(Map<String, dynamic> json) {
    String? sanitizeNumericString(String? input) {
      if (input == null) return null;
      return input.replaceAll(',', '').replaceAll(' ', '');
    }

    // Add more robust checking here to prevent parsing errors
    try {
      // Ensure all required fields are present and are strings before parsing
      final String? hash = json['hash'] as String?;
      final String? from = json['from'] as String?;
      final String? to = json['to'] as String?;
      final String? value = json['value'] as String?;
      final String? gasPrice = json['gasPrice'] as String?;
      final String? gasUsed = json['gasUsed'] as String?;
      final String? blockNumber = json['blockNumber'] as String?;
      final String? timeStamp = json['timeStamp'] as String?;
      final String? tokenSymbol = json['tokenSymbol'] as String?;
      final String? tokenDecimal = json['tokenDecimal'] as String?;

      if (from == null ||
          to == null ||
          value == null ||
          gasPrice == null ||
          gasUsed == null ||
          blockNumber == null ||
          timeStamp == null ||
          tokenSymbol == null ||
          tokenDecimal == null) {
        // Log or throw if a required field is missing
        print('Missing required field in transaction JSON: $json');
        throw FormatException('Missing required field in transaction JSON');
      }

      return TokenTransaction(
        hash: hash ?? '', // Handle potential null hash, default to empty string
        from: from,
        to: to,
        value: BigInt.parse(sanitizeNumericString(value)!),
        gasPrice: BigInt.parse(gasPrice),
        gasUsed: BigInt.parse(gasUsed),
        blockNumber: int.parse(blockNumber),
        timeStamp: int.parse(timeStamp),
        tokenSymbol: tokenSymbol,
        tokenDecimal: int.parse(tokenDecimal),
      );
    } catch (e) {
      // Log or throw a more informative error if parsing fails
      print('Error parsing transaction JSON: $json\nError: $e');
      // Depending on how critical this is, you might return null or a dummy object,
      // but throwing helps identify malformed data immediately.
      throw FormatException('Failed to parse TokenTransaction from JSON: $e');
    }
  }
}
