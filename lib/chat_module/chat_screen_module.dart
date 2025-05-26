import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  String get _chatId {
    final ids = [widget.volunteerId, widget.organizerId]..sort();
    return '${ids[0]}_${ids[1]}_${widget.eventId}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.volunteerName),
            Text(widget.organizerName, style: const TextStyle(fontSize: 14)),
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
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final message =
                        snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;
                    final isMe = message['senderId'] == widget.organizerId;

                    return _buildMessageBubble(message['text'], isMe);
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

  Widget _buildMessageBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMe ? Colors.white : Colors.green[100],
          border: isMe
              ? Border.all(color: Colors.blue, width: 1.5)
              : Border.all(color: Colors.green[300]!),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isMe ? widget.organizerName : widget.volunteerName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isMe ? Colors.blue[800] : Colors.green[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(text),
            const SizedBox(height: 4),
            Text(
              DateFormat('hh:mm a').format(DateTime.now()),
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.blue[600] : Colors.green[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    await _firestore
        .collection('chats')
        .doc(_chatId)
        .collection('messages')
        .add({
          'text': _messageController.text,
          'senderId': widget.organizerId,
          'timestamp': FieldValue.serverTimestamp(), // Add this line
        });

    _messageController.clear();
  }
}
