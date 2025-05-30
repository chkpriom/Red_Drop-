import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonateBloodScreen extends StatefulWidget {
  @override
  _DonateBloodScreenState createState() => _DonateBloodScreenState();
}

class _DonateBloodScreenState extends State<DonateBloodScreen> {
  final _formKey = GlobalKey<FormState>();
  String? bloodGroup;
  String? units;
  String? location;
  String? phone;

  void submitDonation() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        await FirebaseFirestore.instance.collection('donations').add({
          'bloodGroup': bloodGroup,
          'units': units,
          'location': location,
          'phone': phone,
          'timestamp': Timestamp.now(),
          'name': 'Anonymous',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Donation submitted!')),
        );

        _formKey.currentState!.reset();

        // Navigate to Donation History screen
        Navigator.pushNamed(context, '/donation_history');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit donation: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donate Blood'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            tooltip: 'View Donation History',
            onPressed: () {
              Navigator.pushNamed(context, '/donation_history');
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Blood Group'),
                items: [
                  'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
                ].map((group) {
                  return DropdownMenuItem(value: group, child: Text(group));
                }).toList(),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please select blood group' : null,
                onSaved: (value) => bloodGroup = value,
                onChanged: (_) {},
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Units'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter units' : null,
                onSaved: (value) => units = value,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter location' : null,
                onSaved: (value) => location = value,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  final phoneRegExp = RegExp(r'^\+?\d{7,15}$');
                  if (!phoneRegExp.hasMatch(value)) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
                onSaved: (value) => phone = value,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: submitDonation,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
