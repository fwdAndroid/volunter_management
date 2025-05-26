import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecivedRequest extends StatefulWidget {
  const RecivedRequest({super.key});

  @override
  State<RecivedRequest> createState() => _RecivedRequestState();
}

class _RecivedRequestState extends State<RecivedRequest> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  final int _pageSize = 10;
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreRequests();
    }
  }

  Future<void> _loadMoreRequests() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    final query = _firestore
        .collection('joinevents')
        .where('organizationUid', isEqualTo: _auth.currentUser?.uid)
        .where('isJoined', isEqualTo: false)
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
            .where('isJoined', isEqualTo: false)
            .limit(_pageSize)
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
                  Icon(Icons.person_off, size: 50),
                  SizedBox(height: 16),
                  Text('No pending requests'),
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
                return const Center(child: CircularProgressIndicator());
              }

              final request = requests[index].data() as Map<String, dynamic>;
              return _buildRequestCard(request, requests[index].id);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request, String requestId) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () => _showVolunteerProfile(request['volunteerId']),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: request['volunteerImage'] != null
                        ? NetworkImage(request['volunteerImage'])
                        : null,
                    child: request['volunteerImage'] == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['volunteerName'] ?? 'Unknown Volunteer',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Event: ${request['eventName'] ?? 'Unknown Event'}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // _buildDetailRow(
              //   Icons.date_range,
              //   _formatDate(request['timestamp']),
              // ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionButton(
                    'Delete',
                    Colors.red,
                    Icons.delete,
                    () => _handleRequest(requestId, false),
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    'Accept',
                    Colors.green,
                    Icons.check,
                    () => _handleRequest(requestId, true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showVolunteerProfile(String volunteerId) async {
    final doc = await _firestore.collection('users').doc(volunteerId).get();
    if (!doc.exists) return;

    final volunteer = doc.data()!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(volunteer['fullName']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: volunteer['image'] != null
                      ? NetworkImage(volunteer['image'])
                      : null,
                  child: volunteer['image'] == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              _buildProfileDetail('Email', volunteer['email']),
              _buildProfileDetail(
                'Phone',
                volunteer['phone'] ?? 'Not provided',
              ),
              _buildProfileDetail(
                'Joined',
                _formatDate(volunteer['joinDate'] ?? Timestamp.now()),
              ),
              if (volunteer['skills'] != null)
                _buildProfileDetail(
                  'Skills',
                  (volunteer['skills'] as List).join(', '),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 14),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRequest(String requestId, bool accept) async {
    try {
      if (accept) {
        await _firestore.collection('joinevents').doc(requestId).update({
          'isJoined': true,
          'processedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _firestore.collection('joinevents').doc(requestId).delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(accept ? 'Request accepted' : 'Request deleted'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown date';
    try {
      final date = (timestamp as Timestamp).toDate();
      return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  Widget _buildActionButton(
    String text,
    Color color,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
      ),
      icon: Icon(icon, size: 20),
      label: Text(text),
      onPressed: onPressed,
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
        ],
      ),
    );
  }
}
