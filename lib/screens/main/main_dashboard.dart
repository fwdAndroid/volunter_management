import 'package:flutter/material.dart';
import 'package:volunter_management/screens/main/organizer_pages/event_organizer_screen.dart';
import 'package:volunter_management/screens/main/organizer_pages/organizer_account_screen.dart';
import 'package:volunter_management/screens/main/organizer_pages/organizer_chat_screen.dart';
import 'package:volunter_management/screens/main/organizer_pages/organizer_home_screen.dart';
import 'package:volunter_management/screens/main/organizer_pages/organizer_search_screen.dart';
import 'package:volunter_management/screens/main/pages/account_screen.dart';
import 'package:volunter_management/screens/main/pages/chat_screen.dart';
import 'package:volunter_management/screens/main/pages/home_screen.dart';
import 'package:volunter_management/screens/main/pages/search_screen.dart';
import 'package:volunter_management/uitls/colors.dart';
import 'package:volunter_management/wrapper/enum.dart';

class MainDashboard extends StatefulWidget {
  final UserType userType;

  const MainDashboard({super.key, required this.userType});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _initializeScreens();
  }

  void _initializeScreens() {
    switch (widget.userType) {
      case UserType.organizer:
        _screens = const [
          OrganizerHomeScreen(),
          OrganizerSearchScreen(),
          OrganizerChatScreen(),
          EventOrganizerScreen(),
          OrganizerAcountScreen(),
        ];
        break;
      case UserType.validator:
        _screens = const [
          OrganizerHomeScreen(),
          OrganizerSearchScreen(),
          OrganizerChatScreen(),
          EventOrganizerScreen(),
          OrganizerAcountScreen(),
          // HomeValidate(),
          // SearchValidate(),
          // ChatValidate(),
          // EventValidate(),
          // AccountValidate(),
        ];
        break;
      case UserType.volunteer:
        _screens = const [
          HomeScreen(),
          SearchScreen(),
          ChatScreen(),
          AccountScreen(),
        ];
        break;
    }
  }

  List<BottomNavigationBarItem> _getNavItems() {
    switch (widget.userType) {
      case UserType.organizer:
        return _organizerNavItems();
      case UserType.validator:
        return _validatorNavItems();
      case UserType.volunteer:
        return _volunteerNavItems();
    }
  }

  List<BottomNavigationBarItem> _organizerNavItems() {
    return [
      _buildNavItem(Icons.home_outlined, 'Home', 0),
      _buildNavItem(Icons.search, 'Search', 1),
      _buildNavItem(Icons.chat_bubble, 'Chats', 2),
      _buildNavItem(Icons.event, 'Events', 3),
      _buildNavItem(Icons.person, 'Account', 4),
    ];
  }

  List<BottomNavigationBarItem> _validatorNavItems() {
    return [
      _buildNavItem(Icons.verified_user, 'Validate', 0),
      _buildNavItem(Icons.search, 'Search', 1),
      _buildNavItem(Icons.chat_bubble, 'Chats', 2),
      _buildNavItem(Icons.event, 'Events', 3),
      _buildNavItem(Icons.person, 'Account', 4),
    ];
  }

  List<BottomNavigationBarItem> _volunteerNavItems() {
    return [
      _buildNavItem(Icons.home_outlined, 'Home', 0),
      _buildNavItem(Icons.search, 'Search', 1),
      _buildNavItem(Icons.chat_bubble, 'Chats', 2),
      _buildNavItem(Icons.person, 'Account', 3),
    ];
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    String label,
    int index,
  ) {
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: _currentIndex == index ? mainColor : secondaryColor,
      ),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: _getNavItems(),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: mainColor,
        unselectedItemColor: secondaryColor,
      ),
    );
  }
}
