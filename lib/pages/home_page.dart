import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/complaint_model.dart';
import '../services/database_service.dart';
import 'new_complaint_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isDone = true;
  final CollectionReference complaintsCollection =
      FirebaseFirestore.instance.collection('complaints');
  TextEditingController _nameController = TextEditingController(); 

// Method to show the dialog box for entering the name of the person who completed the service
  Future<void> _showCompletionDialog(Complaint complaint, String id) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Service Completed'),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Done'),
              onPressed: () {
                String completedBy = _nameController.text.trim();
                if (completedBy.isNotEmpty) {
                  Navigator.of(context).pop();
                  _markComplaintAsDone(complaint, completedBy, id);
                } else {
                  Navigator.of(context).pop();
// Handle case when name field is empty
// You can show a snackbar or display an error message
                }
              },
            ),
          ],
        );
      },
    );
  }

// Method to mark the complaint as done with the provided name
  void _markComplaintAsDone(Complaint complaint, String completedBy,String id) {
    Complaint updatedComplaint = complaint.copyWith(
      isDone: true,
      updatedOn: Timestamp.now(),
      completedBy: completedBy,
    );
    _databaseService.updateComplaint(id, updatedComplaint);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skynet Complaint Service'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Cable'),
            Tab(text: 'Internet'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildComplaintList('Cable TV'),
          _buildComplaintList('Internet'),
          _buildCompletedList(isDone),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToNewComplaint();
        },
        child: Icon(Icons.add),
      ),
    );
  }
//main ui view method
  Widget _buildComplaintList(String serviceType) {
    return StreamBuilder<QuerySnapshot<Complaint>>(
      stream: _databaseService.getComplaintsByServiceType(serviceType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }
        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Nothing Found'));
        }
        List<DocumentSnapshot<Complaint>> complaints = snapshot.data!.docs;
        complaints
            .sort((a, b) => b.data()!.createdOn.compareTo(a.data()!.createdOn));
        return ListView.builder(
          itemCount: complaints.length,
          itemBuilder: (context, index) {
            Complaint complaint = complaints[index].data()!;
            String id = complaints[index].id;
            return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                elevation: 8,
                shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        complaint.isDone ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Icon(
                      complaint.isDone
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      color: complaint.isDone ? Colors.green : Colors.red,
                      size: 30,
                    ),
                    title: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(complaint.name),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               Text(
                                "Created On :- ${DateFormat('dd-MMM-yy hh:mm a').format(complaint.createdOn.toDate())}",
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Update On :- ${DateFormat('dd-MMM-yy hh:mm a').format(complaint.updatedOn.toDate())}",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                    onTap: () => _showComplaintDetailsDialog(complaint),
                    trailing: Checkbox(
                      value: complaint.isDone,
                      onChanged: (value) {
                        Complaint updatedComplaint = complaint.copyWith(
                            isDone: value!, updatedOn: Timestamp.now());
                        // _databaseService.updateComplaint(id, updatedComplaint);
                        _showCompletionDialog(updatedComplaint, id);
                      },
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ));
          },
        );
      },
    );
  }


  ///Completed Tab
  Widget _buildCompletedList(bool isDone) {
    return StreamBuilder<QuerySnapshot<Complaint>>(
      stream: _databaseService.getCompletedCollection(isDone),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }
        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Nothing Found'));
        }

        List<DocumentSnapshot<Complaint>> complaints = snapshot.data!.docs;
        complaints
            .sort((a, b) => b.data()!.createdOn.compareTo(a.data()!.createdOn));
        return ListView.builder(
          itemCount: complaints.length,
          itemBuilder: (context, index) {
            Complaint complaint = complaints[index].data()!;
            String id = complaints[index].id;
            return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                elevation: 8,
                shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        complaint.isDone ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Icon(
                      complaint.isDone
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      color: complaint.isDone ? Colors.green : Colors.red,
                      size: 30,
                    ),
                    title: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(complaint.name),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               Text(
                                "Created On :- ${DateFormat('dd-MMM-yy hh:mm a').format(complaint.createdOn.toDate())}",
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Update On :- ${DateFormat('dd-MMM-yy hh:mm a').format(complaint.updatedOn.toDate())}",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                    onTap: () => _showComplaintDetailsDialog(complaint),
                    trailing: Checkbox(
                      value: complaint.isDone,
                      onChanged: (value) {
                        Complaint updatedComplaint = complaint.copyWith(
                            isDone: value!, updatedOn: Timestamp.now());
                        // _databaseService.updateComplaint(id, updatedComplaint);
                        _showCompletionDialog(updatedComplaint, id);
                      },
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ));
          },
        );
      },
    );
  }

  void _navigateToNewComplaint() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => NewComplaintPage(),
    ));
  }

  void _showComplaintDetailsDialog(Complaint complaint) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${complaint.serviceType} Request',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue, // Adjust color as needed
                  ),
                ),
                SizedBox(height: 10),
                _buildDetailRow('Service Type:', complaint.requestType),
                _buildDetailRow('Name:', complaint.name),
                _buildDetailRow('Phone Number:', complaint.phoneNumber),
                _buildDetailRow('Address:', complaint.address),
                _buildDetailRow(
                    'Issue:', complaint.issueDescription ?? 'No description'),
                    _buildDetailRow(
                    'Attendant:', complaint.completedBy ?? 'No Attendee'),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue, // Adjust color as needed
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87, // Adjust color as needed
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87, // Adjust color as needed
              ),
            ),
          ),
        ],
      ),
    );
  }
}
