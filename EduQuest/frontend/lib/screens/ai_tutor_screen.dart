import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../ui/app_components.dart';
import '../ui/eduquest_theme.dart';

class AITutorScreen extends StatefulWidget {
  final int userId;
  final String contextStr;

  const AITutorScreen({
    required this.userId,
    required this.contextStr,
    super.key,
  });

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
      'text':
          'Hello. I am your AI Tutor for ${widget.contextStr}. Ask for a hint, a simpler explanation, or a step-by-step way to approach the topic.',
    });
  }

  Future<void> _sendMessage() async {
    if (_ctl.text.trim().isEmpty || _isTyping) return;

    final prompt = _ctl.text.trim();
    setState(() {
      _messages.add({'role': 'user', 'text': prompt});
      _isTyping = true;
      _ctl.clear();
    });

    final aiResponse = await ApiService.getAiHint(
      widget.userId,
      prompt,
      context: widget.contextStr,
    );
    if (!mounted) return;

    setState(() {
      _messages.add({'role': 'ai', 'text': aiResponse});
      _isTyping = false;
    });
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Tutor')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: AppSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppInfoChip(
                    label: 'Guided support',
                    color: EduQuestColors.info,
                    icon: Icons.smart_toy_outlined,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.contextStr,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Use the tutor for hints, simpler explanations, or help with the next step in your learning path.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) return _buildTypingIndicator();
                final m = _messages[index];
                final isUser = m['role'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isUser
                              ? EduQuestColors.primary
                              : EduQuestColors.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft:
                            isUser ? const Radius.circular(20) : Radius.zero,
                        bottomRight:
                            isUser ? Radius.zero : const Radius.circular(20),
                      ),
                    ),
                    child: Text(
                      m['text']!,
                      style: const TextStyle(fontSize: 15, height: 1.45),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.transparent,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctl,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Ask for a hint or explanation...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isTyping ? null : _sendMessage,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(Icons.send),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'AI Tutor is thinking...',
          style: TextStyle(color: EduQuestColors.textMuted),
        ),
      ),
    );
  }
}
