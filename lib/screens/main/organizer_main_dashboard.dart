import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:volunter_management/screens/organizer_pages/organizer_account_screen.dart';
import 'package:volunter_management/screens/organizer_pages/organizer_chat_screen.dart';
import 'package:volunter_management/screens/organizer_pages/organizer_home_screen.dart';
import 'package:volunter_management/screens/organizer_pages/organizer_search_screen.dart';
import 'package:volunter_management/uitls/colors.dart';

class OrganizerMainDashboard extends StatefulWidget {
  const OrganizerMainDashboard({super.key});

  @override
  State<OrganizerMainDashboard> createState() => _OrganizerMainDashboardState();
}

class _OrganizerMainDashboardState extends State<OrganizerMainDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    OrganizerHomeScreen(), // Replace with your screen widgets
    OrganizerSearchScreen(),
    OrganizerChatScreen(),
    OrganizerAcountScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await _showExitDialog(context);
        return shouldPop ?? false;
      },
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          selectedLabelStyle: TextStyle(color: mainColor),
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: _currentIndex == 0
                  ? Icon(Icons.home_outlined, size: 25, color: mainColor)
                  : Icon(Icons.home_outlined, color: secondaryColor, size: 25),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _currentIndex == 1
                  ? Icon(Icons.event, size: 25, color: mainColor)
                  : Icon(Icons.event, color: secondaryColor, size: 25),
              label: 'Event',
            ),

            BottomNavigationBarItem(
              label: "Chats",
              icon: _currentIndex == 2
                  ? Icon(Icons.chat_bubble, size: 25, color: mainColor)
                  : Icon(Icons.chat_bubble, size: 25, color: secondaryColor),
            ),
            BottomNavigationBarItem(
              label: "Account",
              icon: _currentIndex == 3
                  ? Icon(Icons.person, size: 25, color: mainColor)
                  : Icon(Icons.person),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit App'),
        content: Text('Do you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              if (Platform.isAndroid) {
                SystemNavigator.pop(); // For Android
              } else if (Platform.isIOS) {
                exit(0); // For iOS
              }
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }
}
