class Beneficiary {
  const Beneficiary({
    required this.id,
    required this.beneficiaryName,
    required this.ribNumber,
  });

  final int id;
  final String beneficiaryName;
  final String ribNumber;

  factory Beneficiary.fromJson(Map<String, dynamic> json) {
    return Beneficiary(
      id: json['id'] as int? ?? 0,
      beneficiaryName: json['beneficiaryName'] as String? ?? '',
      ribNumber: json['ribNumber'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'beneficiaryName': beneficiaryName,
        'ribNumber': ribNumber,
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
