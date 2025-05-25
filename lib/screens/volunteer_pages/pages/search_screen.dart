import 'package:flutter/material.dart';
import 'package:volunter_management/screens/volunteer_pages/volunteer_events_tab/join_volunteer_events.dart';
import 'package:volunter_management/screens/volunteer_pages/volunteer_events_tab/request_send_volunteer_events.dart';
import 'package:volunter_management/uitls/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: mainColor,
          automaticallyImplyLeading: false,
          bottom: TabBar(
            unselectedLabelColor: black,
            labelColor: colorWhite,
            indicatorColor: colorWhite,
            tabs: [
              Tab(text: "Request Send"),
              Tab(text: "Join Event"),
            ],
          ),
          title: Text('Events', style: TextStyle(color: colorWhite)),
        ),
        body: TabBarView(
          children: [RequestSendVolunteerEvents(), JoinVolunteerEvents()],
        ),
      ),
    );
  }
}
