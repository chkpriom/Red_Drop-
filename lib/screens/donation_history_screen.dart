import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonationHistoryScreen extends StatelessWidget {
  final donations = FirebaseFirestore.instance
      .collection('donations')
      .orderBy('timestamp', descending: true)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donation History'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Donate Blood',
            onPressed: () {
              Navigator.pushNamed(context, '/donate_blood');
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: donations,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(child: Text('No donation records found.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index];
              return ListTile(
                title: Text('Blood Group: ${data['bloodGroup']}'),
                subtitle:
                Text('Location: ${data['location']} - Units: ${data['units']}'),
                trailing: Text(
                  (data['timestamp'] as Timestamp)
                      .toDate()
                      .toLocal()
                      .toString()
                      .split('.')[0],
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
