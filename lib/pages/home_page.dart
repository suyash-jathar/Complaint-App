// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:complaint_app/services/database_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter/src/widgets/placeholder.dart';
// import 'package:intl/intl.dart';

// import '../models/todo.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final DatabaseService _databaseService = DatabaseService();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       appBar: _appBar(),
//       body: _buildUI(),

//     );
//   }


//   PreferredSizeWidget _appBar() {
//     return AppBar(
//       backgroundColor: Theme.of(context).primaryColor,
//       title: const Text('Todo App',style: TextStyle(color: Colors.white),),
//     );
//   }

//   Widget _buildUI() {
//     return SafeArea(child:  Column(
//       children: [
//         _messagesListView(),
//       ],
//     ));
//   }

//   Widget _messagesListView() {
//     return SizedBox(
//       height: MediaQuery.of(context).size.height * 0.8,
//       width: MediaQuery.of(context).size.width,
//       child: StreamBuilder(
//         stream: _databaseService.getTodos(),
//         builder: (context, snapshot) {
//           List todos = snapshot.data?.docs ?? [];
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return const Center(child: Text('Something went wrong'));
//           }
//           if (todos.isEmpty) {
//             return const Center(child: Text('No todos found'));
//           }
//           print(todos);
//           return ListView.builder(itemBuilder: (context, index) {
//             Todo todo = todos[index].data();
//             String id = todos[index].id;
//             return Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: ListTile(
//                 tileColor: Theme.of(context).primaryColor.withOpacity(0.5),
//                 title: Text(todo.task),
//                 subtitle: Text(
//                   DateFormat('dd MMM yyyy').format(todo.createdOn.toDate()),
//                 ),
//                 trailing: Checkbox(
//                   value: todo.isDone,
//                   onChanged: (value) {
//                     Todo updatedTodo = todo.copyWith(isDone: !todo.isDone, updatedOn: Timestamp.now());
//                   //  _databaseService.updateTodo(id, todo.copyWith(isDone: value));
//                   _databaseService.updateTodo(id: id, todo: updatedTodo);
//                   },
//               ),
              
//             ),
//             );
//           },
//             itemCount: todos.length,
//           );
//         },
//       )
//     );
//   }
// }

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

class _HomePageState extends State<HomePage> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _buildUI(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNewComplaint,
        tooltip: 'Add Complaint',
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: const Text(
        'Complaint App',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Column(
        children: [
          _complaintsListView(),
        ],
      ),
    );
  }

  Widget _complaintsListView() {
  return SizedBox(
    height: MediaQuery.of(context).size.height * 0.8,
    width: MediaQuery.of(context).size.width,
    child: StreamBuilder(
      stream: _databaseService.getComplaints(),
      builder: (context, snapshot) {
//             String id = todos[index].id;
        List complaints = snapshot.data?.docs ?? [];
       // List Complaint = snapshot.data?.docs ?? [];
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }
        if (complaints.isEmpty) {
          return const Center(child: Text('No complaints found'));
        }
        return ListView.builder(
          itemBuilder: (context, index) {
            Complaint complaint = complaints[index].data();
            String id = complaints[index].id;
            return InkWell(
              onTap: () => _showComplaintDetailsDialog(complaint),
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                elevation: 8,
                shadowColor: Theme.of(context).primaryColor.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: complaint.isDone ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Icon(
                      complaint.isDone ? Icons.check_circle_outline : Icons.error_outline,
                      color: complaint.isDone ? Colors.green : Colors.red,
                      size: 30,
                    ),
                    title: Text(
                      '${complaint.serviceType} - ${complaint.requestType}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      DateFormat('dd MMM yyyy').format(complaint.createdOn.toDate()),
                    ),
                    trailing: Checkbox(
                      value: complaint.isDone,
                      onChanged: (value) {
                        Complaint updatedComplaint = complaint.copyWith(isDone: value!, updatedOn: Timestamp.now());
                        _databaseService.updateComplaint(id, updatedComplaint);
                      },
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            );
          },
          itemCount: complaints.length,
        );
      },
    ),
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
      return AlertDialog(
        title: Text('${complaint.serviceType} Request'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Name: ${complaint.name}'),
              Text('Phone Number: ${complaint.phoneNumber}'),
              Text('Address: ${complaint.address}'),
              Text('Issue: ${complaint.issueDescription ?? 'No description'}'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}


}
