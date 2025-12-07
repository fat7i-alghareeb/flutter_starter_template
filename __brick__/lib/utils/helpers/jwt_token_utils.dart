import 'package:jwt_decoder/jwt_decoder.dart';

import 'colored_print.dart';

/// JWT/token related helper functions used by the networking layer.
///
/// Kept under `utils/helpers` so it can be reused by non-network code
/// without depending directly on Dio types.
bool isTokenAboutToExpire(String token, {int bufferTimeInMinutes = 5}) {
  try {
    final expirationDate = JwtDecoder.getExpirationDate(token);
    final now = DateTime.now();

    final bufferTime = expirationDate.subtract(
      Duration(minutes: bufferTimeInMinutes),
    );
    final remaining = expirationDate.difference(now);

    if (remaining.isNegative) {
      printR('⏳ Token already expired');
    } else {
      final days = remaining.inDays;
      final hours = remaining.inHours % 24;
      final minutes = remaining.inMinutes % 60;
      printK(
        '✅ Token still valid for: $days d, $hours h, $minutes m'
        ' (${remaining.inMinutes} minutes total)',
      );
    }

    return now.isAfter(bufferTime);
  } catch (e) {
    printR('Error decoding token: $e');
    return true; // Treat invalid token as expired
  }
}
