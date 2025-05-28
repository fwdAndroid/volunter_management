import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:readmore/readmore.dart';
import 'package:uuid/uuid.dart';
import 'package:volunter_management/widgets/noimage_widget.dart';
import 'package:volunter_management/widgets/save_button.dart';

class ViewEventsVolunteer extends StatefulWidget {
  final String? description,
      image,
      organizationUid,
      organizationName,
      titleName,
      uuid,
      eventDate,
      eventTime; // Make nullable
  final dateTime;

  const ViewEventsVolunteer({
    super.key,
    required this.description,
    required this.image,
    required this.organizationUid,
    required this.titleName,
    required this.organizationName,
    required this.eventDate,
    required this.eventTime,
    required this.uuid,
    required this.dateTime,
  });

  @override
  State<ViewEventsVolunteer> createState() => _ViewEventsVolunteerState();
}

class _ViewEventsVolunteerState extends State<ViewEventsVolunteer> {
  var uuid = Uuid().v4();
  bool _isLoading = false; // Add loading state
  TextEditingController _hoursController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.titleName ?? "No Title",
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("joinevents")
            .where(
              "volunteerId",
              isEqualTo: FirebaseAuth.instance.currentUser!.uid,
            )
            .where("eventId", isEqualTo: widget.uuid)
            .snapshots()
            .map(
              (snapshot) =>
                  snapshot.docs.isNotEmpty ? snapshot.docs.first : null,
            ),
        builder: (context, AsyncSnapshot<DocumentSnapshot?> snapshot) {
          final bool requestExists = snapshot.hasData && snapshot.data != null;
          return StreamBuilder(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.image != null && widget.image!.isNotEmpty)
                    Image.network(
                      widget.image!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          noImageWidget(),
                    )
                  else
                    noImageWidget(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.titleName ?? "No Title",
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ReadMoreText(
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
                      widget.description ?? "No description available",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Published Date: ${getFormattedDateTime(widget.dateTime)}",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Event Start Time: ${(widget.eventTime)}",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Event Date: ${(widget.dateTime)}",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Spacer(),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _isLoading
                          ? CircularProgressIndicator() // Show loader when loading
                          : SaveButton(
                              title: requestExists
                                  ? "Request Sent"
                                  : "Join Request",
                              onTap: requestExists
                                  ? null
                                  : () async {
                                      // Show the dialog first

                                      try {
                                        final uuid = Uuid().v4();
                                        await FirebaseFirestore.instance
                                            .collection("joinevents")
                                            .doc(uuid)
                                            .set({
                                              "uuid": uuid,
                                              "hours": 0,
                                              "isJoined": false,
                                              "eventName": widget.titleName,
                                              "eventDescription":
                                                  widget.description,
                                              "eventDate": widget.eventDate,
                                              "organizerId":
                                                  widget.organizationUid,
                                              "eventId": widget.uuid,
                                              "eventTime": widget.eventTime,
                                              "volunteerName": snap['fullName'],
                                              "volunteerId": FirebaseAuth
                                                  .instance
                                                  .currentUser!
                                                  .uid,
                                              "organizationUid":
                                                  widget.organizationUid,
                                              "organizationName":
                                                  widget.organizationName,
                                              "timestamp":
                                                  FieldValue.serverTimestamp(),
                                              "eventImage": widget.image,
                                              "status": "pending",
                                            });

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text("Join request sent!"),
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Error: ${e.toString()}",
                                            ),
                                          ),
                                        );
                                      } finally {
                                        setState(() => _isLoading = false);
                                      }
                                    },
                            ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

String getFormattedDateTime(dynamic dateTime) {
  if (dateTime == null) return "Unknown Date";

  // Ensure it's a DateTime object
  DateTime parsedDate;
  if (dateTime is Timestamp) {
    parsedDate = dateTime.toDate(); // If it's a Firestore Timestamp
  } else if (dateTime is String) {
    parsedDate = DateTime.tryParse(dateTime) ?? DateTime.now();
  } else if (dateTime is DateTime) {
    parsedDate = dateTime;
  } else {
    return "Invalid Date";
  }

  return DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate);
}
