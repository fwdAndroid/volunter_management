import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreenModule extends StatefulWidget {
  final Map<String, dynamic> request;

  const ChatScreenModule({super.key, required this.request});

  @override
  State<ChatScreenModule> createState() => _ChatScreenModuleState();
}

class _ChatScreenModuleState extends State<ChatScreenModule> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  String get _chatId {
    final ids = [widget.request['volunteerId'], _currentUser!.uid]..sort();
    return '${ids[0]}_${ids[1]}_${widget.request['eventId']}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chat with ${widget.request['volunteerName']}'),
            Text(
              'Event: ${widget.request['eventName']}',
              style: const TextStyle(fontSize: 14),
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
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  reverse: false,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final message =
                        snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;
                    final isMe = message['senderId'] == _currentUser!.uid;

                    return _buildMessageBubble(
                      message['text'],
                      isMe,
                      isMe
                          ? widget.request['organizationName']
                          : widget.request['volunteerName'],
                    );
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

  Widget _buildMessageBubble(String text, bool isMe, String senderName) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              senderName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isMe ? Colors.blue[800] : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(text),
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
          'senderId': _currentUser!.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });

    _messageController.clear();
  }
}
