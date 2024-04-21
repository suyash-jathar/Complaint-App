import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/complaint_model.dart';

class NewComplaintPage extends StatefulWidget {
  @override
  _NewComplaintPageState createState() => _NewComplaintPageState();
}

class _NewComplaintPageState extends State<NewComplaintPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _issueController = TextEditingController();

  String _selectedService = 'Cable TV'; // default or first item in dropdown
  String _requestType = 'New Connection'; // default or first item in dropdown

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Complaint'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _selectedService,
                decoration: InputDecoration(labelText: 'Service Type'),
                items: <String>['Cable TV', 'Internet'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedService = newValue!;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _requestType,
                decoration: InputDecoration(labelText: 'Request Type'),
                items: <String>['New Connection', 'Complaint'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _requestType = newValue!;
                  });
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Please enter a phone number' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) => value!.isEmpty ? 'Please enter an address' : null,
              ),
              TextFormField(
                controller: _issueController,
                decoration: InputDecoration(labelText: 'Issue Description'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Please describe the issue' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit Complaint'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      var newComplaint = Complaint(
        serviceType: _selectedService,
        requestType: _requestType,
        name: _nameController.text,
        phoneNumber: _phoneController.text,
        address: _addressController.text,
        issueDescription: _issueController.text,
        createdOn: Timestamp.now(),
        updatedOn: Timestamp.now(),
        isDone: false,
      );

      // Here you would typically call a service to save the complaint to Firestore
      FirebaseFirestore.instance.collection('complaints').add(newComplaint.toJson())
        .then((result) {
          Navigator.of(context).pop(); // Navigate back after submission
        })
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add complaint: $error'))
          );
        });
    }
  }
}
