import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:volunter_management/chat_module/chat_screen_module.dart';

class JoinVolunteerEvents extends StatefulWidget {
  const JoinVolunteerEvents({super.key});

  @override
  State<JoinVolunteerEvents> createState() => _JoinVolunteerEventsState();
}

class _JoinVolunteerEventsState extends State<JoinVolunteerEvents> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  final int _pageSize = 15;
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreRequests();
    }
  }

  Future<void> _loadMoreRequests() async {
    if (_isLoadingMore || _lastDocument == null) return;
    setState(() => _isLoadingMore = true);

    final query = _firestore
        .collection('joinevents')
        .where('volunteerId', isEqualTo: _auth.currentUser?.uid)
        .where('isJoined', isEqualTo: true)
        .orderBy('processedAt', descending: true)
        .startAfterDocument(_lastDocument!)
        .limit(_pageSize);

    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      _lastDocument = snapshot.docs.last;
    }

    setState(() => _isLoadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('joinevents')
            .where('volunteerId', isEqualTo: _auth.currentUser?.uid)
            .where('isJoined', isEqualTo: true)
            .orderBy('processedAt', descending: true)
            .limit(_pageSize)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_alt, size: 50, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No accepted requests yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final requests = snapshot.data!.docs;
          _lastDocument = requests.last;

          return ListView.builder(
            controller: _scrollController,
            itemCount: requests.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= requests.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final request = requests[index].data() as Map<String, dynamic>;
              return _AcceptedRequestCard(
                request: request,
                onChat: () => _openChat(context, request),
              );
            },
          );
        },
      ),
    );
  }

  void _openChat(BuildContext context, Map<String, dynamic> request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreenModule(
          organizerName: request['organizationName'],
          volunteerId: request['volunteerId'],
          volunteerName: request['volunteerName'],
          eventId: request['eventId'],
          organizerId: request['organizerId'],
        ),
      ),
    );
  }
}

class _AcceptedRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback onChat;

  const _AcceptedRequestCard({required this.request, required this.onChat});

  @override
  Widget build(BuildContext context) {
    final bool isTimeSent = request['status'] == 'send';

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Volunteer: ${request['volunteerName']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Organizer: ${request['organizationName']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Event Name: ${request['eventName']}'),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: onChat,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat),
                      SizedBox(width: 8),
                      Text('Open Chat'),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (request['status'] != 'send' &&
                    request['status'] != 'approved')
                  TextButton(
                    onPressed: () async {
                      TextEditingController _hoursController =
                          TextEditingController();

                      await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Commitment Hours"),
                          content: TextField(
                            controller: _hoursController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText:
                                  "Enter number of hours you'll volunteer",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {
                                if (_hoursController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Please enter hours"),
                                    ),
                                  );
                                  return;
                                }
                                if (int.tryParse(_hoursController.text) ==
                                    null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Invalid number format"),
                                    ),
                                  );
                                  return;
                                }
                                await FirebaseFirestore.instance
                                    .collection("joinevents")
                                    .doc(request['uuid'])
                                    .update({
                                      "hours": int.parse(_hoursController.text),
                                      "status": "send",
                                    });
                                Navigator.pop(context, true);
                              },
                              child: Text("Send"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.insert_chart_outlined_sharp),
                        SizedBox(width: 8),
                        Text('Add Work Time'),
                      ],
                    ),
                  )
                else if (request['status'] == 'approved')
                  const Text(
                    "Time Approved",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else if (request['status'] == "cancel")
                  Text(
                    "Not Approved",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  const Text(
                    "Time Sent To Approved",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
