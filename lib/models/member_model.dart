// lib/models/member_model.dart

class Member {
  final String id;
  final String name;
  final String lastName;
  final String phone;
  final String address;
  final DateTime birthdate;
  final bool enabled;
  final String? networkId;
  final String? networkName;
  final DateTime? createdDate;
  final String? profilePictureUrl;
  Member({
    required this.id,
    required this.name,
    required this.lastName,
    required this.phone,
    required this.address,
    required this.birthdate,
    required this.enabled,
    this.networkId,
    this.networkName,
    this.createdDate,
    this.profilePictureUrl,
  });

  @override
  String toString() {
    // Si Flutter intenta imprimir el objeto, imprimirá esto:
    return '$name $lastName'.trim();
  }

  // Getter para nombre completo
  String get fullName =>
      '$name ?? '
              '} $lastName'
          .replaceAll('  ', ' ');

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      lastName: json['lastName'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      birthdate: json['birthdate'] != null
          ? DateTime.parse(json['birthdate'])
          : DateTime.now(),
      enabled: json['enabled'] ?? true,
      networkId: json['networkId'],
      networkName: json['networkName'],
    );
  }
}
