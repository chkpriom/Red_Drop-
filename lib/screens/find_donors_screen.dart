import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FindDonorsScreen extends StatefulWidget {
  @override
  _FindDonorsScreenState createState() => _FindDonorsScreenState();
}

class _FindDonorsScreenState extends State<FindDonorsScreen> {
  String _searchQuery = '';

  void _showSearchDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        String tempSearch = _searchQuery;
        return AlertDialog(
          title: Text('Search Donors'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: 'Enter name or blood group'),
            onChanged: (value) {
              tempSearch = value;
            },
            controller: TextEditingController(text: _searchQuery),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(tempSearch),
              child: Text('Search'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _searchQuery = result.trim().toLowerCase();
      });
    }
  }

  Future<void> _refreshData() async {
    // Clear search query on refresh
    setState(() {
      _searchQuery = '';
    });
    await Future.delayed(Duration(milliseconds: 200)); // Optional delay
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Donors'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _showSearchDialog,
            tooltip: 'Search donors',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('donations')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error loading donors'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            final filteredDocs = _searchQuery.isEmpty
                ? docs
                : docs.where((doc) {
              final donorData = doc.data()! as Map<String, dynamic>;
              final name = (donorData['name'] ?? '').toString().toLowerCase();
              final bloodGroup = (donorData['bloodGroup'] ?? '').toString().toLowerCase();
              return name.contains(_searchQuery) || bloodGroup.contains(_searchQuery);
            }).toList();

            if (filteredDocs.isEmpty) {
              return Center(child: Text('No donors found'));
            }

            return ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: filteredDocs.length,
              itemBuilder: (context, index) {
                final donorData = filteredDocs[index].data()! as Map<String, dynamic>;
                final name = donorData['name'] ?? 'Anonymous';
                final bloodGroup = donorData['bloodGroup'] ?? 'Unknown';
                final units = donorData['units'] ?? '';
                final location = donorData['location'] ?? 'Unknown city';
                final phone = donorData['phone'] ?? 'No phone provided';
                final timestamp = donorData['timestamp'] as Timestamp?;

                String timeAgo = '';
                if (timestamp != null) {
                  final diff = DateTime.now().difference(timestamp.toDate());
                  if (diff.inMinutes < 60) {
                    timeAgo = '${diff.inMinutes} mins ago';
                  } else if (diff.inHours < 24) {
                    timeAgo = '${diff.inHours} hrs ago';
                  } else {
                    timeAgo = '${diff.inDays} days ago';
                  }
                }

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    leading: CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 28,
                      child: Text(
                        bloodGroup,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    title: Text(
                      name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(
                      '$units units - $location\nPhone: $phone\nLast updated: $timeAgo',
                      style: TextStyle(fontSize: 14),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
