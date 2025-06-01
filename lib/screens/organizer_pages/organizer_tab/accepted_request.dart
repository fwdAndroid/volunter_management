import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:volunter_management/chat_module/chat_screen_module.dart';

class AcceptedRequest extends StatefulWidget {
  const AcceptedRequest({super.key});

  @override
  State<AcceptedRequest> createState() => _AcceptedRequestState();
}

class _AcceptedRequestState extends State<AcceptedRequest> {
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
        .where('organizationUid', isEqualTo: _auth.currentUser?.uid)
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
            .where('organizationUid', isEqualTo: _auth.currentUser?.uid)
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
            // ✅ Conditional status message or view button
            // if (request['status'] == 'approved') ...[
            //   const Text(
            //     "Request Accepted",
            //     style: TextStyle(
            //       color: Colors.green,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ] else if (request['status'] == 'cancel') ...[
            //   const Text(
            //     "Request Cancelled",
            //     style: TextStyle(
            //       color: Colors.red,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ] else ...[
            TextButton(
              onPressed: () => showRequestDetails(context),
              child: const Text("View Request"),
            ),
          ],
          // ],
        ),
      ),
    );
  }

  void showRequestDetails(BuildContext context) {
    final List<dynamic> hoursListRaw = request['hours'] ?? [];
    List<Map<String, dynamic>> hoursList = hoursListRaw
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          void updateHourStatus(int index, String newStatus) async {
            hoursList[index]['status'] = newStatus;

            // Update hours array in Firestore
            await FirebaseFirestore.instance
                .collection('joinevents')
                .doc(request['uuid'])
                .update({'hours': hoursList});

            // Check if at least one hour is approved
            final bool hasApproved = hoursList.any(
              (h) => h['status'] == 'approved',
            );
            final bool allDeclined = hoursList.every(
              (h) => h['status'] == 'declined',
            );

            // Update overall request status
            String requestStatus = hasApproved
                ? 'approved'
                : (allDeclined ? 'declined' : request['status']);
            await FirebaseFirestore.instance
                .collection('joinevents')
                .doc(request['uuid'])
                .update({'status': requestStatus});

            setState(() {});
          }

          return AlertDialog(
            title: const Text("Request Details"),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Volunteer: ${request['volunteerName']}"),
                  const SizedBox(height: 8),
                  Text("Event: ${request['eventName']}"),
                  const SizedBox(height: 12),
                  const Text("Logged Hours:"),
                  const SizedBox(height: 8),
                  if (hoursList.isEmpty) const Text("No hours submitted."),
                  for (int i = 0; i < hoursList.length; i++)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "⏰ ${hoursList[i]['startTime']} - ${hoursList[i]['endTime']} (${hoursList[i]['hr']} hr)",
                      ),
                      subtitle: Text(
                        "Status: ${hoursList[i]['status'] ?? 'pending'}",
                        style: TextStyle(
                          color: hoursList[i]['status'] == 'approved'
                              ? Colors.green
                              : hoursList[i]['status'] == 'declined'
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            onPressed: () => updateHourStatus(i, 'approved'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => updateHourStatus(i, 'declined'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          );
        },
      ),
    );
  }
}
