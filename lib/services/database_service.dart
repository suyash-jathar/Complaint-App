// import 'package:cloud_firestore/cloud_firestore.dart';

// import '../models/todo.dart';

// const String TODO_COLLECTION_REF = 'todos';

// class DatabaseService {
//   final _firestore = FirebaseFirestore.instance;

//   late final CollectionReference _todosRef;

//   DatabaseService() {
//     _todosRef = _firestore.collection(TODO_COLLECTION_REF).withConverter<Todo>(
//       fromFirestore: (snapshot, _) => Todo.fromJson(snapshot.data()!),
//       toFirestore: (todo, _) => todo.toJson(),
//     );
//   }

//   Stream<QuerySnapshot> getTodos() {
//     return _todosRef.snapshots();
//   }

//   void addTodo(Todo todo) {
//     _todosRef.add(todo);
//   }

//   void updateTodo({
//     required String id,
//     required Todo todo,
//   }) {
//     _todosRef.doc(id).update(todo.toJson());
//   }

//   void deleteTodo({
//     required String id,
//   }) {
//     _todosRef.doc(id).delete();
//   }

// }
// import 'package:cloud_firestore/cloud_firestore.dart';

// import '../models/complaint_model.dart';

// const String COMPLAINT_COLLECTION_REF = 'complaints';

// class DatabaseService {
//   final _firestore = FirebaseFirestore.instance;

//   late final CollectionReference _complaintsRef;

//   DatabaseService() {
//     _complaintsRef = _firestore.collection(COMPLAINT_COLLECTION_REF).withConverter<Complaint>(
//       fromFirestore: (snapshot, _) => Complaint.fromJson(snapshot.data()!),
//       toFirestore: (complaint, _) => complaint.toJson(),
//     );
//   }

//   Stream<QuerySnapshot> getComplaints() {
//     return _complaintsRef.snapshots();
//   }

//   void addComplaint(Complaint complaint) {
//     _complaintsRef.add(complaint);
//   }

//   void updateComplaint({
//     required String id,
//     required Complaint complaint,
//   }) {
//     _complaintsRef.doc(id).set(complaint.toJson());
//   }

//   void deleteComplaint({
//     required String id,
//   }) {
//     _complaintsRef.doc(id).delete();
//   }
// }
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
