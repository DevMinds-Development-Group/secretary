class TenantModel {
  final String id;
  final String name;
  final String shortName;
  final String slug;
  final String type;
  final bool enabled;
  final String? address;
  final String? phone;
  final String? email;

  const TenantModel({
    required this.id,
    required this.name,
    required this.shortName,
    required this.slug,
    required this.type,
    required this.enabled,
    this.address,
    this.phone,
    this.email,
  });

  bool get isMinistry => type == 'MINISTERIO';

  /// El nombre corto es el que cabe en la barra superior y en el selector; el
  /// largo es para los informes.
  String get displayName => shortName.isNotEmpty ? shortName : name;

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['id'] as String,
      name: (json['name'] ?? '') as String,
      shortName: (json['shortName'] ?? json['name'] ?? '') as String,
      slug: (json['slug'] ?? '') as String,
      type: (json['type'] ?? 'IGLESIA') as String,
      enabled: (json['enabled'] ?? true) as bool,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
    );
  }
}

class ChurchProvisionResult {
  final TenantModel church;
  final String adminUsername;
  final String oneTimePassword;

  const ChurchProvisionResult({
    required this.church,
    required this.adminUsername,
    required this.oneTimePassword,
  });

  factory ChurchProvisionResult.fromJson(Map<String, dynamic> json) {
    return ChurchProvisionResult(
      church: TenantModel.fromJson(Map<String, dynamic>.from(json['church'])),
      adminUsername: json['adminUsername'] as String,
      oneTimePassword: json['oneTimePassword'] as String,
    );
  }
}
