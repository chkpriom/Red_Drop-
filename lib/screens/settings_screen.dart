import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: Icon(Icons.account_circle),
          title: Text('Account'),
          subtitle: Text('Manage your account'),
          onTap: () {
            // Navigate or show account settings
          },
        ),
        ListTile(
          leading: Icon(Icons.notifications),
          title: Text('Notifications'),
          subtitle: Text('Manage notification preferences'),
          onTap: () {
            // Navigate or show notification settings
          },
        ),
        ListTile(
          leading: Icon(Icons.lock),
          title: Text('Privacy'),
          subtitle: Text('Privacy and security settings'),
          onTap: () {
            // Navigate or show privacy settings
          },
        ),
        ListTile(
          leading: Icon(Icons.info),
          title: Text('About'),
          subtitle: Text('App info and version'),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'RedDrop',
              applicationVersion: '1.0.0',
              applicationIcon: Icon(Icons.bloodtype, color: Colors.red),
              children: [
                Text('A blood donation app built with Flutter and Firebase.'),
              ],
            );
          },
        ),
      ],
    );
  }
}
