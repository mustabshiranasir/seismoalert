import 'package:hive/hive.dart';

class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String relation;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relation,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      relation: json['relation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'relation': relation,
    };
  }

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phone,
    String? relation,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relation: relation ?? this.relation,
    );
  }
}

class EmergencyContactAdapter extends TypeAdapter<EmergencyContact> {
  @override
  final int typeId = 1;

  @override
  EmergencyContact read(BinaryReader reader) {
    return EmergencyContact(
      id: reader.readString(),
      name: reader.readString(),
      phone: reader.readString(),
      relation: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, EmergencyContact obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.phone);
    writer.writeString(obj.relation);
  }
}
