class ChooseMfaRequest {
  const ChooseMfaRequest({
    required this.challengeId,
    required this.challengeToken,
    required this.mfaChannel,
  });

  final int challengeId;
  final String challengeToken;
  final String mfaChannel; // 'PHONE' or 'EMAIL'

  Map<String, dynamic> toJson() => {
        'challengeId': challengeId,
        'challengeToken': challengeToken,
        'mfaChannel': mfaChannel,
      };
}

class ChooseMfaResponse {
  const ChooseMfaResponse({
    required this.challengeId,
    required this.channel,
    required this.maskedDestination,
    required this.expiresAt,
  });

  final int challengeId;
  final String channel;
  final String maskedDestination;
  final String expiresAt;

  factory ChooseMfaResponse.fromJson(Map<String, dynamic> json) {
    return ChooseMfaResponse(
      challengeId: json['challengeId'] as int? ?? 0,
      channel: json['channel'] as String? ?? '',
      maskedDestination: json['maskedDestination'] as String? ?? '',
      expiresAt: json['expiresAt'] as String? ?? '',
    );
  }
}
