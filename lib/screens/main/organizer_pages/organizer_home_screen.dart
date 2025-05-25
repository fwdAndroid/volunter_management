import 'package:flutter/material.dart';
import 'package:volunter_management/screens/main/organizer_pages/events/add_event.dart';
import 'package:volunter_management/uitls/colors.dart';

class OrganizerHomeScreen extends StatefulWidget {
  const OrganizerHomeScreen({super.key});

  @override
  State<OrganizerHomeScreen> createState() => _OrganizerHomeScreenState();
}

class _OrganizerHomeScreenState extends State<OrganizerHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: mainColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (builder) => AddEvent()),
          );
        },
        child: Icon(Icons.add, color: colorWhite),
      ),
    );
  }
}
