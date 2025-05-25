import 'package:flutter/material.dart';
import 'package:volunter_management/screens/organizer_pages/organizer_setting/organizer_edit_profile.dart';
import 'package:volunter_management/uitls/colors.dart';
import 'package:volunter_management/widgets/logout_widget.dart';
import 'package:share_plus/share_plus.dart';

class OrganizerSetting extends StatefulWidget {
  const OrganizerSetting({super.key});

  @override
  State<OrganizerSetting> createState() => _OrganizerSettingState();
}

class _OrganizerSettingState extends State<OrganizerSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Settings")),
      body: Column(
        children: [
          Image.asset("assets/logo.png", height: 200, fit: BoxFit.cover),
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
                  MaterialPageRoute(
                    builder: (builder) => OrganizerEditProfile(),
                  ),
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
