import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AITutorScreen extends StatefulWidget {
  final int userId;
  final String contextStr;

  const AITutorScreen({required this.userId, required this.contextStr, super.key});

  @override
  State<AITutorScreen> createState() => _AITutorScreenState();
}

class _AITutorScreenState extends State<AITutorScreen> {
  final TextEditingController _ctl = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messages.add({
      'role': 'ai',
      'text': 'Hello! I am your AI Tutor. Let\'s talk about ${widget.contextStr}. What are you stuck on?'
    });
  }

  Future<void> _sendMessage() async {
    if (_ctl.text.trim().isEmpty) return;
    
    final prompt = _ctl.text.trim();
    setState(() {
      _messages.add({'role': 'user', 'text': prompt});
      _isTyping = true;
      _ctl.clear();
    });

    final aiResponse = await ApiService.getAiHint(widget.userId, prompt);
    
    setState(() {
      _messages.add({'role': 'ai', 'text': aiResponse});
      _isTyping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Tutor'),
        backgroundColor: const Color(0xFF1E1E2E),
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) return _buildTypingIndicator();
                final m = _messages[index];
                final isUser = m['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? Theme.of(context).primaryColor : const Color(0xFF282A36),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
                        bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
                      ),
                    ),
                    child: Text(m['text']!, style: const TextStyle(fontSize: 16, height: 1.4)),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF282A36),
            child: Row(
               children: [
                 Expanded(
                   child: TextField(
                     controller: _ctl,
                     decoration: InputDecoration(
                        hintText: "Ask for a hint...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: const Color(0xFF1E1E2E),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)
                     ),
                   ),
                 ),
                 const SizedBox(width: 8),
                 CircleAvatar(
                   radius: 24,
                   backgroundColor: Theme.of(context).primaryColor,
                   child: IconButton(
                     icon: const Icon(Icons.send, color: Colors.white, size: 20),
                     onPressed: _isTyping ? null : _sendMessage,
                   ),
                 )
               ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 16, top: 8),
        child: Text('AI Tutor is typing...', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
      ),
    );
  }
}
