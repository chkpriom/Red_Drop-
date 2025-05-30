import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _selectedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _loadUserPhone(user.uid);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No authenticated user. Please log in.')),
        );
        Navigator.pop(context);
      });
    }
  }

  Future<void> _loadUserPhone(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          _phoneController.text = data['phone'] ?? '';
        }
      }
    } catch (e) {
      print('Failed to load phone number: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToStorage(File image) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final ext = image.path.split('.').last;
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_photos')
          .child('${user.uid}.$ext');

      final uploadTask = ref.putFile(image);
      await uploadTask; // wait for upload to complete
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Image upload error: $e');
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No authenticated user found. Please log in again.')),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      String? photosUrl;

      if (_selectedImage != null) {
        final uploadedUrl = await _uploadImageToStorage(_selectedImage!);
        if (uploadedUrl != null) {
          photosUrl = uploadedUrl;
        }
      } else {
        photosUrl = user.photoURL; // fallback to current photoURL
      }

      // Update Firebase Auth display name and photoURL (optional)
      await user.updateDisplayName(_nameController.text.trim());
      if (photosUrl != null) {
        await user.updatePhotoURL(photosUrl);
      }

      // Save to Firestore, using 'Photos' field for image URL
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'Photos': photosUrl,
        'email': user.email,
      }, SetOptions(merge: true));

      await user.reload(); // reload user profile

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    ImageProvider? imageProvider;
    if (_selectedImage != null) {
      imageProvider = FileImage(_selectedImage!);
    } else if (user?.photoURL != null && user!.photoURL!.isNotEmpty) {
      imageProvider = NetworkImage(user.photoURL!);
    }

    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: imageProvider,
                      backgroundColor: Colors.grey[300],
                      child: imageProvider == null
                          ? Icon(Icons.person, size: 50, color: Colors.grey[700])
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: _pickImage,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Display Name'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter a name' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter phone number' : null,
              ),
              SizedBox(height: 30),
              _isSaving
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _saveProfile,
                child: Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
