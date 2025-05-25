import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:volunter_management/screens/main/organizer_main_dashboard.dart';
import 'package:volunter_management/uitls/colors.dart';
import 'package:volunter_management/uitls/show_message_bar.dart';
import 'package:volunter_management/widgets/save_button.dart';

class OrganizerEditProfile extends StatefulWidget {
  const OrganizerEditProfile({super.key});

  @override
  State<OrganizerEditProfile> createState() => _OrganizerEditProfileState();
}

class _OrganizerEditProfileState extends State<OrganizerEditProfile> {
  TextEditingController nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    setState(() {
      nameController.text = data['fullName'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(centerTitle: true, title: Text("Editar perfil")),
        body: Column(
          children: [
            // Profile Image Section
            Image.asset("assets/logo.png", height: 200),
            // Full Name Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TextFormField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(8),
                  filled: true,
                  hintStyle: GoogleFonts.nunitoSans(fontSize: 16),
                  hintText: "Full Name",
                ),
                controller: nameController,
              ),
            ),

            Spacer(),

            // Save Button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: mainColor))
                  : SaveButton(
                      title: "Edit Profile",
                      onTap: () async {
                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          await FirebaseFirestore.instance
                              .collection("users")
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .update({"fullName": nameController.text});
                          showMessageBar(
                            "Successfully Updated Profile",
                            context,
                          );
                        } catch (e) {
                          print("Error updating profile: $e");
                          showMessageBar(
                            "Profile could not be updated",
                            context,
                          );
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (builder) => OrganizerMainDashboard(),
                            ),
                          );
                        }
                      },
                    ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
