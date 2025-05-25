import 'package:flutter/material.dart';
import 'package:volunter_management/screens/organizer_pages/organizer_tab/accepted_request.dart';
import 'package:volunter_management/screens/organizer_pages/organizer_tab/recived_request.dart';
import 'package:volunter_management/uitls/colors.dart';

class OrganizerSearchScreen extends StatefulWidget {
  const OrganizerSearchScreen({super.key});

  @override
  State<OrganizerSearchScreen> createState() => _OrganizerSearchScreenState();
}

class _OrganizerSearchScreenState extends State<OrganizerSearchScreen> {
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
              Tab(text: "Request Recived"),
              Tab(text: "Accepted Request"),
            ],
          ),
          title: Text('Events', style: TextStyle(color: colorWhite)),
        ),
        body: TabBarView(children: [RecivedRequest(), AcceptedRequest()]),
      ),
    );
  }
}
