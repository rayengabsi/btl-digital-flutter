class MfaChannelInfo {
  const MfaChannelInfo({
    required this.channel,
    required this.maskedDestination,
  });

  final String channel; // 'PHONE' or 'EMAIL'
  final String maskedDestination;

  factory MfaChannelInfo.fromJson(Map<String, dynamic> json) {
    return MfaChannelInfo(
      channel: json['channel'] as String? ?? '',
      maskedDestination: json['maskedDestination'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'channel': channel,
        'maskedDestination': maskedDestination,
      };
}

class LoginChallengeResponse {
  const LoginChallengeResponse({
    required this.challengeId,
    required this.challengeToken,
    required this.mfaRequired,
    required this.availableChannels,
    required this.expiresAt,
  });

  final int challengeId;
  final String challengeToken;
  final bool mfaRequired;
  final List<MfaChannelInfo> availableChannels;
  final String expiresAt;

  factory LoginChallengeResponse.fromJson(Map<String, dynamic> json) {
    final channelsList = json['availableChannels'] as List? ?? [];
    return LoginChallengeResponse(
      challengeId: json['challengeId'] as int? ?? 0,
      challengeToken: json['challengeToken'] as String? ?? '',
      mfaRequired: json['mfaRequired'] as bool? ?? true,
      availableChannels: channelsList
          .map((e) => MfaChannelInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      expiresAt: json['expiresAt'] as String? ?? '',
    );
  }
}
