import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readmore/readmore.dart';
import 'package:volunter_management/screens/volunteer_pages/voluntere_events/view_events_volunteer.dart';
import 'package:volunter_management/uitls/colors.dart';

class RequestSendVolunteerEvents extends StatefulWidget {
  const RequestSendVolunteerEvents({super.key});

  @override
  State<RequestSendVolunteerEvents> createState() =>
      _RequestSendVolunteerEventsState();
}

class _RequestSendVolunteerEventsState
    extends State<RequestSendVolunteerEvents> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('joinevents')
            .where(
              "volunteerId",
              isEqualTo: FirebaseAuth.instance.currentUser!.uid,
            )
            .where("isJoined", isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.join_full, size: 40),
                  Text("No Joined Event Request Send To Admin"),
                ],
              ),
            );
          }
          var posts = snapshot.data!.docs;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var post = posts[index].data() as Map<String, dynamic>;

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      post['eventImage'] != null &&
                              post['eventImage'].toString().isNotEmpty
                          ? Card(
                              child: Image.network(
                                post['eventImage'],
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 200,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            )
                          : Center(
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 100,
                                color: Colors.grey,
                              ),
                            ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              "Event Name: ",
                              style: GoogleFonts.poppins(
                                color: black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              post['eventName'] ?? "Untitled",
                              style: GoogleFonts.poppins(
                                color: black,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              "Event Start Date ",
                              style: GoogleFonts.poppins(
                                color: black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              post['eventDate'].toString(),
                              style: GoogleFonts.poppins(
                                color: black,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ReadMoreText(
                          post['eventDescription'] ??
                              "No description available",
                          trimLines: 3,
                          trimMode: TrimMode.Line,
                          trimCollapsedText: "Read More",
                          trimExpandedText: " Read Less",
                          moreStyle: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                          lessStyle: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (builder) => ViewEventsVolunteer(
                                    uuid: post['eventId'],
                                    description: post['eventDescription'],
                                    titleName: post['eventName'],
                                    image: post['eventImage'],
                                    dateTime: post['eventDate'],
                                    eventTime: post['eventTime'],
                                    eventDate: post['eventDate'],
                                    organizationName: post['userName'],
                                    organizationUid: post['uid'],
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              "View Event",
                              style: TextStyle(color: black),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
