import 'dart:convert';

class UnityCommand {
  const UnityCommand({
    required this.type,
    required this.requestId,
    required this.payload,
  });

  final String type;
  final String requestId;
  final Map<String, Object?> payload;

  String encode() => jsonEncode({
        'type': type,
        'requestId': requestId,
        'payload': payload,
      });
}

class UnityEvent {
  const UnityEvent({
    required this.type,
    required this.requestId,
    required this.success,
    this.payload = const {},
    this.error,
  });

  final String type;
  final String requestId;
  final bool success;
  final Map<String, Object?> payload;
  final String? error;

  factory UnityEvent.decode(String source) {
    final json = jsonDecode(source) as Map<String, Object?>;
    return UnityEvent(
      type: json['type'] as String,
      requestId: json['requestId'] as String? ?? '',
      success: json['success'] as bool? ?? true,
      payload: (json['payload'] as Map?)?.cast<String, Object?>() ?? {},
      error: json['error'] as String?,
    );
  }
}
