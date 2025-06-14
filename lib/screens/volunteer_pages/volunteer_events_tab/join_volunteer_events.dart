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
                  child: Center(child: Text("")),
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
}

class _AcceptedRequestCard extends StatefulWidget {
  final Map<String, dynamic> request;
  final VoidCallback? onChat;

  const _AcceptedRequestCard({
    Key? key,
    required this.request,
    required this.onChat,
  }) : super(key: key);

  @override
  State<_AcceptedRequestCard> createState() => _AcceptedRequestCardState();
}

class _AcceptedRequestCardState extends State<_AcceptedRequestCard> {
  List<Map<String, dynamic>> timeLogs = [];
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  final TextEditingController _descController = TextEditingController();

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          selectedStartTime = picked;
        } else {
          selectedEndTime = picked;
        }
      });
    }
  }

  void _addTimeLog() {
    if (selectedStartTime == null ||
        selectedEndTime == null ||
        _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields.")),
      );
      return;
    }

    final start = Duration(
      hours: selectedStartTime!.hour,
      minutes: selectedStartTime!.minute,
    );
    final end = Duration(
      hours: selectedEndTime!.hour,
      minutes: selectedEndTime!.minute,
    );

    if (end <= start) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("End time must be after start time.")),
      );
      return;
    }

    final totalMinutes = end.inMinutes - start.inMinutes;
    final hours = double.parse((totalMinutes / 60).toStringAsFixed(2));
    final now = Timestamp.now();

    setState(() {
      timeLogs.add({
        'startTime': selectedStartTime!.format(context),
        'endTime': selectedEndTime!.format(context),
        'hr': hours,
        'timestamp': now,
        'description': _descController.text.trim(),
        'isJoined': false,
        'status': "send",
      });
      selectedStartTime = null;
      selectedEndTime = null;
      _descController.clear();
    });
  }

  Future<void> _saveLogs() async {
    if (timeLogs.isEmpty) return;

    await FirebaseFirestore.instance
        .collection("joinevents")
        .doc(widget.request['uuid'])
        .update({"hours": FieldValue.arrayUnion(timeLogs), "status": "send"});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Request sent, wait for approval.")),
    );

    setState(() {
      timeLogs.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final List<dynamic> submittedLogs = request['hours'] ?? [];

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Event Name: ${request['eventName'] ?? 'N/A'}"),
            Text("Date: ${request['eventDate'] ?? 'N/A'}"),
            Text("Time: ${request['eventTime'] ?? 'N/A'}"),
            Text("Organizer Name: ${request['organizationName'] ?? 'N/A'}"),
            Text("Status: ${request['status'] ?? ''}"),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              icon: const Icon(Icons.chat),
              label: const Text("Chat"),
              onPressed: widget.onChat,
            ),

            const SizedBox(height: 16),

            // Time log input UI
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: "Start Time",
                      ),
                      child: Text(
                        selectedStartTime?.format(context) ?? "Select",
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: "End Time"),
                      child: Text(selectedEndTime?.format(context) ?? "Select"),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),

            const SizedBox(height: 8),

            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add Time Log"),
              onPressed: _addTimeLog,
            ),

            const SizedBox(height: 8),

            ...timeLogs.map(
              (log) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  "${log['startTime']} - ${log['endTime']}: ${log['hr']} hrs | ${log['description']}",
                ),
              ),
            ),

            if (timeLogs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Save"),
                  onPressed: _saveLogs,
                ),
              ),

            if (submittedLogs.isNotEmpty) ...[
              const Divider(),
              const Text(
                "Submitted Time Logs:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...submittedLogs.map(
                (log) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    "${log['startTime']} - ${log['endTime']}: ${log['hr']} hrs | ${log['description'] ?? ''} (Status: ${log['status']})",
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
