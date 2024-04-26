import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/complaint_model.dart'; // Ensure you import your Complaint model correctly

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final CollectionReference<Complaint> _complaintsRef;

  DatabaseService() {
    _complaintsRef = _firestore.collection('complaints').withConverter<Complaint>(
      fromFirestore: (snapshot, _) => Complaint.fromJson(snapshot.data()!),
      toFirestore: (complaint, _) => complaint.toJson(),
    );
  }

  Stream<QuerySnapshot<Complaint>> getComplaintsByServiceType(String serviceType) {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  return _firestore.collection('complaints')
      .where('serviceType', isEqualTo: serviceType)
      .where('isDone', isEqualTo: false) // Add this line to exclude completed complaints
      .withConverter<Complaint>(
        fromFirestore: (snapshot, _) => Complaint.fromJson(snapshot.data()!),
        toFirestore: (complaint, _) => complaint.toJson(),
      )
      .snapshots();
}
Stream<QuerySnapshot<Complaint>> getCompletedCollection(bool isDone) {
    // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  return _firestore.collection('complaints')
    .where('isDone', isEqualTo: isDone)
    .withConverter<Complaint>(
      fromFirestore: (snapshot, _) => Complaint.fromJson(snapshot.data()!),
      toFirestore: (complaint, _) => complaint.toJson(),
    ).snapshots();
}

  Stream<QuerySnapshot> getComplaints() {
    return _complaintsRef.snapshots();
  }

  Future<void> addComplaint(Complaint complaint) {
    return _complaintsRef.add(complaint);
  }

  Future<void> updateComplaint(String id, Complaint updatedComplaint) {
    return _complaintsRef.doc(id).update(updatedComplaint.toJson());
  }

  Future<void> deleteComplaint(String id) {
    return _complaintsRef.doc(id).delete();
  }
}
