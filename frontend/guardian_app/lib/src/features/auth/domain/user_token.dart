
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userTokenProvider = StateProvider<String?>((ref) {
  // In a real app, you would fetch this from secure storage
  // For now, we are using a hardcoded token for testing
  return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ0ZXN0dXNlciIsImV4cCI6MTc0MjY4ODAwMH0.4-s4JGtCbB2pPs8T5pD2-gOF2s-gG1s5J3rY_5t5a_s";
});
