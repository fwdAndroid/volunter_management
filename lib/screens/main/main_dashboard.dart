import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:volunter_management/screens/main/volunteer_pages/pages/account_screen.dart';
import 'package:volunter_management/screens/main/volunteer_pages/pages/chat_screen.dart';
import 'package:volunter_management/screens/main/volunteer_pages/pages/home_screen.dart';
import 'package:volunter_management/screens/main/volunteer_pages/pages/search_screen.dart';
import 'package:volunter_management/uitls/colors.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(), // Replace with your screen widgets
    SearchScreen(),
    ChatScreen(),
    AccountScreen(),
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
                  ? Icon(Icons.search, size: 25, color: mainColor)
                  : Icon(Icons.search, color: secondaryColor, size: 25),
              label: 'Search',
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
