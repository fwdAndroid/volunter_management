import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:volunter_management/screens/main/organizer_main_dashboard.dart';
import 'package:volunter_management/uitls/colors.dart';
import 'package:volunter_management/uitls/image.dart';
import 'package:volunter_management/uitls/show_message_bar.dart';

class AddEvent extends StatefulWidget {
  const AddEvent({super.key});

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  TextEditingController serviceNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  Uint8List? _image;
  bool isLoading = false;

  var uuid = Uuid().v4();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: colorWhite),
        backgroundColor: mainColor,
        centerTitle: true,
        title: Text("Add Event", style: TextStyle(color: colorWhite)),
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () => selectImage(),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 59,
                  backgroundImage: _image != null
                      ? MemoryImage(_image!)
                      : const AssetImage('assets/logo.png') as ImageProvider,
                ),
                Positioned(
                  bottom: -10,
                  left: 70,
                  child: IconButton(
                    onPressed: () => selectImage(),
                    icon: const Icon(Icons.add_a_photo, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: TextFormField(
              controller: serviceNameController,
              decoration: InputDecoration(
                hintText: 'Event Name',
                hintStyle: GoogleFonts.poppins(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                contentPadding: const EdgeInsets.only(left: 8, top: 15),
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  borderSide: BorderSide(color: mainColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: mainColor),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: mainColor),
                ),
                fillColor: textColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter Event Description',
                hintStyle: GoogleFonts.poppins(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                contentPadding: const EdgeInsets.only(left: 8, top: 15),
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  borderSide: BorderSide(color: mainColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: mainColor),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: mainColor),
                ),
                fillColor: textColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
            child: TextFormField(
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  borderSide: BorderSide(color: mainColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: mainColor),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: mainColor),
                ),
                fillColor: textColor,
                labelText: 'Select Event Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              controller: dateController,
              validator: (value) {
                if (selectedDate == null) return 'Please select a date';
                return null;
              },
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8),
            child: TextFormField(
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  borderSide: BorderSide(color: mainColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: mainColor),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: mainColor),
                ),
                fillColor: textColor,
                labelText: 'Select Event Time',
                suffixIcon: Icon(Icons.access_time),
              ),
              controller: timeController,
              validator: (value) {
                if (selectedTime == null) return 'Please select a time';
                return null;
              },
              readOnly: true,
              onTap: () => _selectTime(context),
            ),
          ),
          const Spacer(),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      final uid = FirebaseAuth.instance.currentUser!.uid;
                      final userDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .get();
                      if (!userDoc.exists) {
                        showMessageBar("User info not found!", context);
                        setState(() => isLoading = false);
                        return;
                      }

                      final userData = userDoc.data()!;

                      String? imageUrl;
                      if (_image != null) {
                        imageUrl = await uploadImageToFirebase(_image!);
                      }

                      await FirebaseFirestore.instance
                          .collection('communitiesPost')
                          .doc(uuid)
                          .set({
                            'eventId': uuid,
                            'eventName': serviceNameController.text,
                            'description': descriptionController.text,
                            'image': imageUrl, // Save only if available
                            'date': DateTime.now(),
                            'uuid': uuid,
                            'uid': FirebaseAuth.instance.currentUser!.uid,
                            'volunteer': [],

                            // Add user metadata
                            'userName': userData['fullName'] ?? '',
                            'userEmail': userData['email'] ?? '',
                            'userImage': userData['image'] ?? '',
                          });

                      setState(() {
                        isLoading = false;
                      });

                      showMessageBar("Feed Posted in Communities", context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (builder) => OrganizerMainDashboard(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: mainColor,
                      fixedSize: const Size(320, 60),
                    ),
                    child: const Text(
                      "Add Event",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        timeController.text = picked.format(context);
      });
    }
  }

  Future<void> selectImage() async {
    Uint8List ui = await pickImage(ImageSource.gallery);
    setState(() {
      _image = ui;
    });
  }

  Future<String> uploadImageToFirebase(Uint8List file) async {
    Reference ref = FirebaseStorage.instance.ref().child(
      'feed_images/${Uuid().v4()}',
    );
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snap = await uploadTask;
    return await snap.ref.getDownloadURL();
  }
}

//Functions
