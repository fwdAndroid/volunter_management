import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:volunter_management/uitls/colors.dart';

class ChatScreenModule extends StatefulWidget {
  final String volunteerId;
  final String volunteerName;
  final String eventId;
  final String organizerId;
  final String organizerName;

  const ChatScreenModule({
    super.key,
    required this.volunteerId,
    required this.volunteerName,
    required this.eventId,
    required this.organizerId,
    required this.organizerName,
  });

  @override
  State<ChatScreenModule> createState() => _ChatScreenModuleState();
}

class _ChatScreenModuleState extends State<ChatScreenModule> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Add FirebaseAuth instance

  String get _chatId {
    // Sort by ID to ensure consistency regardless of who initiates the chat or views it
    final ids = [widget.volunteerId, widget.organizerId]..sort();
    return '${ids[0]}_${ids[1]}_${widget.eventId}';
  }

  @override
  Widget build(BuildContext context) {
    // Determine the name of the chat partner for the AppBar title
    // String chatPartnerName = "";
    // final currentUser = _auth.currentUser;
    // if (currentUser != null) {
    //   if (currentUser.uid == widget.organizerId) {
    //     chatPartnerName = widget.volunteerName;
    //   } else if (currentUser.uid == widget.volunteerId) {
    //     chatPartnerName = widget.organizerName;
    //   }
    // }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: colorWhite),
        backgroundColor: mainColor,
        // title: Text(chatPartnerName.isNotEmpty ? "Chat with $chatPartnerName" : "Chat"), // Alternative title
        title: Column(
          // Keeping your original title structure
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Org: ${widget.organizerName}",
              style: TextStyle(color: colorWhite),
            ), // Prefixing for clarity
            Text(
              "Vol: ${widget.volunteerName}",
              style: TextStyle(fontSize: 14, color: colorWhite),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(_chatId)
                  .collection('messages')
                  .orderBy(
                    'timestamp',
                    descending: false,
                  ) // Show oldest messages first
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No messages yet."));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final messageDoc = snapshot.data!.docs[index];
                    final messageData =
                        messageDoc.data() as Map<String, dynamic>;

                    // Determine if the message was sent by the organizer
                    final bool isOrganizerMessage =
                        messageData['senderId'] == widget.organizerId;

                    return _buildMessageBubble(messageData, isOrganizerMessage);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    Map<String, dynamic> messageData,
    bool isOrganizerMessage,
  ) {
    final String textContent =
        messageData['text'] as String? ?? ''; // Message text
    final Timestamp? firestoreTimestamp =
        messageData['timestamp'] as Timestamp?; // Firestore timestamp

    // Organizer messages on the LEFT, Volunteer messages on the RIGHT
    final Alignment bubbleAlignment = isOrganizerMessage
        ? Alignment.centerLeft
        : Alignment.centerRight;

    // Determine display name based on who sent the message
    final String displayName = isOrganizerMessage
        ? widget.organizerName
        : widget.volunteerName;

    // Define styling based on the sender
    // Original styling: Organizer (was 'isMe'): White bg, Blue border. Volunteer: Green[100] bg, Green[300] border.
    final Color bubbleColor = isOrganizerMessage
        ? Colors.white
        : Colors.green[100]!;
    final Border bubbleBorder = isOrganizerMessage
        ? Border.all(color: Colors.blue, width: 1.5)
        : Border.all(color: Colors.green[300]!);

    final Color nameColor = isOrganizerMessage
        ? Colors.blue[800]!
        : Colors.green[800]!;
    final Color timeColor = isOrganizerMessage
        ? Colors.blue[600]!
        : Colors.green[600]!;

    // Align text within the bubble (start for left-aligned bubbles, end for right-aligned bubbles)
    final CrossAxisAlignment textAlignmentInsideBubble = isOrganizerMessage
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.end;

    return Align(
      alignment: bubbleAlignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width * 0.75, // Max width of bubble
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          border: bubbleBorder,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: textAlignmentInsideBubble,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              displayName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: nameColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              textContent,
              // textAlign: isOrganizerMessage ? TextAlign.start : TextAlign.end, // Optional: explicit text align
            ),
            const SizedBox(height: 4),
            if (firestoreTimestamp != null)
              Text(
                DateFormat('hh:mm a').format(
                  firestoreTimestamp.toDate(),
                ), // Format the actual message timestamp
                style: TextStyle(fontSize: 10, color: timeColor),
              )
            else // Fallback for timestamp if not available (e.g., message sending)
              Text(
                "sending...",
                style: TextStyle(
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  color: timeColor.withOpacity(0.7),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      // Handle error: user not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: You are not logged in.")),
      );
      return;
    }

    final String currentUserId = currentUser.uid;

    // It's crucial that senderId is the ID of the person actually sending the message
    await _firestore.collection('chats').doc(_chatId).collection('messages').add({
      'text': messageText,
      'senderId': currentUserId, // Use the ID of the currently logged-in user
      'timestamp':
          FieldValue.serverTimestamp(), // Use server timestamp for consistency
    });

    _messageController.clear();
  }
}
