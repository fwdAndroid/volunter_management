import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
          color: isMe ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text),
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
          'timestamp': FieldValue.serverTimestamp(),
        });

    _messageController.clear();
  }
}
