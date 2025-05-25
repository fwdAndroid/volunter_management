import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:volunter_management/screens/volunteer_pages/volunteer_setting/edit_profile.dart';
import 'package:volunter_management/uitls/colors.dart';
import 'package:volunter_management/widgets/logout_widget.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        automaticallyImplyLeading: false,
        title: Text("Setting", style: TextStyle(color: colorWhite)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset("assets/logo.png", height: 100),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return Center(child: Text('No data available'));
              }
              var snap = snapshot.data;

              return Column(
                children: [
                  Text(
                    snap['fullName'],
                    style: GoogleFonts.workSans(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                ],
              );
            },
          ),
          Card(
            child: ListTile(
              trailing: Icon(Icons.arrow_forward_ios),
              title: Text("Favourite"),
              leading: Icon(Icons.favorite),
            ),
          ),

          Card(
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (builder) => EditProfile()),
                );
              },
              trailing: Icon(Icons.arrow_forward_ios),
              title: Text("Edit Profile"),
              leading: Icon(Icons.person),
            ),
          ),

          Card(
            child: ListTile(
              onTap: () {
                shareApp();
              },
              trailing: Icon(Icons.arrow_forward_ios),
              title: Text("Invite Friends"),
              leading: Icon(Icons.share),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return LogoutWidget();
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // <-- Radius
                  ),
                  backgroundColor: mainColor,
                  fixedSize: const Size(320, 60),
                ),
                child: Text("Log Out", style: TextStyle(color: colorWhite)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void shareApp() {
    String appLink =
        "https://play.google.com/store/apps/details?id=com.example.yourapp";
    Share.share("Hey, check out this amazing app: $appLink");
  }
}
