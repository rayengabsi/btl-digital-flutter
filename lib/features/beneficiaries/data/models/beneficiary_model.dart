class Beneficiary {
  const Beneficiary({
    required this.id,
    required this.beneficiaryName,
    required this.ribNumber,
    this.bankName = 'BTL Bank',
  });

  final int id;
  final String beneficiaryName;
  final String ribNumber;
  final String bankName;

  /// Display value, e.g. '•••• 3565'.
  String get maskedAccount {
    if (ribNumber.length <= 4) return ribNumber;
    return '•••• ${ribNumber.substring(ribNumber.length - 4)}';
  }

  factory Beneficiary.fromJson(Map<String, dynamic> json) {
    return Beneficiary(
      id: json['id'] as int? ?? 0,
      beneficiaryName: json['beneficiaryName'] as String? ?? '',
      ribNumber: json['ribNumber'] as String? ?? '',
      bankName: json['bankName'] as String? ?? 'BTL Bank',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'beneficiaryName': beneficiaryName,
        'ribNumber': ribNumber,
        'bankName': bankName,
      };
}

class BeneficiaryRequest {
  const BeneficiaryRequest({
    required this.beneficiaryName,
    required this.ribNumber,
  });

  final String beneficiaryName;
  final String ribNumber; // 20 digits

  Map<String, dynamic> toJson() => {
        'beneficiaryName': beneficiaryName,
        'ribNumber': ribNumber,
      };
}
