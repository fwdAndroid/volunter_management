import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:volunter_management/chat_module/chat_screen_module.dart';
import 'package:volunter_management/uitls/colors.dart';

class OrganizerChatScreen extends StatefulWidget {
  const OrganizerChatScreen({super.key});

  @override
  State<OrganizerChatScreen> createState() => _OrganizerChatScreenState();
}

class _OrganizerChatScreenState extends State<OrganizerChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat with Volunteers',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: mainColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('joinevents')
            .where('organizerId', isEqualTo: _auth.currentUser?.uid)
            .where('isJoined', isEqualTo: true)
            .orderBy('processedAt', descending: true)
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
                  Icon(Icons.forum, size: 50, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No active chats yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index].data() as Map<String, dynamic>;
              return _buildChatListItem(request, requests[index].id);
            },
          );
        },
      ),
    );
  }

  Widget _buildChatListItem(Map<String, dynamic> request, String requestId) {
    return Card(
      child: ListTile(
        title: Text(request['volunteerName']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(request['eventName']),
            Text(
              'Accepted on ${_formatDate(request['processedAt'])}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: const Icon(Icons.chat),
        onTap: () => _openChat(context, request),
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

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown date';
    try {
      final date = (timestamp as Timestamp).toDate();
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }
}
