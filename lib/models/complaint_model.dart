import 'package:cloud_firestore/cloud_firestore.dart';

class Complaint {
  String serviceType;
  String requestType;
  String name;
  String phoneNumber;
  String address;
  String? additionalNotes;
  String? issueDescription;
  Timestamp createdOn;
  Timestamp updatedOn;
  bool isDone;
  String? completedBy; // Added field for the name of the person who completed the service

  Complaint({
    required this.serviceType,
    required this.requestType,
    required this.name,
    required this.phoneNumber,
    required this.address,
    this.additionalNotes,
    this.issueDescription,
    required this.createdOn,
    required this.updatedOn,
    required this.isDone,
    this.completedBy, // Updated constructor to include completedBy field
  });

  Complaint.fromJson(Map<String, dynamic> json)
      : serviceType = json['serviceType']! as String,
        requestType = json['requestType']! as String,
        name = json['name']! as String,
        phoneNumber = json['phoneNumber']! as String,
        address = json['address']! as String,
        additionalNotes = json['additionalNotes'] as String?,
        issueDescription = json['issueDescription'] as String?,
        createdOn = json['createdOn'] as Timestamp,
        updatedOn = json['updatedOn'] as Timestamp,
        isDone = json['isDone'] as bool,
        completedBy = json['completedBy'] as String?; // Deserialize completedBy field

  Map<String, dynamic> toJson() => {
        'serviceType': serviceType,
        'requestType': requestType,
        'name': name,
        'phoneNumber': phoneNumber,
        'address': address,
        'additionalNotes': additionalNotes,
        'issueDescription': issueDescription,
        'createdOn': createdOn,
        'updatedOn': updatedOn,
        'isDone': isDone,
        'completedBy': completedBy, // Serialize completedBy field
      };

  Complaint copyWith({
    String? serviceType,
    String? requestType,
    String? name,
    String? phoneNumber,
    String? address,
    String? additionalNotes,
    String? issueDescription,
    Timestamp? createdOn,
    Timestamp? updatedOn,
    bool? isDone,
    String? completedBy, // Include completedBy in copyWith method
  }) {
    return Complaint(
      serviceType: serviceType ?? this.serviceType,
      requestType: requestType ?? this.requestType,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      issueDescription: issueDescription ?? this.issueDescription,
      createdOn: createdOn ?? this.createdOn,
      updatedOn: updatedOn ?? this.updatedOn,
      isDone: isDone ?? this.isDone,
      completedBy: completedBy ?? this.completedBy, // Update completedBy
    );
  }
}
