import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watermangment/theme.dart';
import 'package:watermangment/widgets/glass_container.dart';
import 'package:watermangment/services/gemini_service.dart';
import 'package:watermangment/providers/user_provider.dart';

Future<void> showCivicAIModal(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return const CivicAIModal();
    },
  );
}

class CivicAIModal extends StatefulWidget {
  const CivicAIModal({super.key});

  @override
  State<CivicAIModal> createState() => _CivicAIModalState();
}

class _CivicAIModalState extends State<CivicAIModal> {
  final TextEditingController _inputController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final user = Provider.of<UserProvider>(context, listen: false);

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _inputController.clear();
      _isTyping = true;
    });

    // Ask Gemini AI Agent
    final aiReply = await GeminiService.askGemini(text, user.area);

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({'sender': 'ai', 'text': aiReply});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      duration: const Duration(milliseconds: 100),
      child: GlassContainer(
        borderRadius: 30,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 10),
              
              // Close Button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),
              
              // Logo Image
              Image.asset(
                'assets/images/logo.png',
                height: 55,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              
              // Title
              const Text(
                "AquaSense Gemini AI Agent",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              
              // Subtitle
              const Text(
                "Smart AI assistant for urban water services.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textGrey,
                ),
              ),
              const SizedBox(height: 14),

              // Messages history
              if (_messages.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ..._messages.map((m) {
                          bool isUser = m['sender'] == 'user';
                          return Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isUser ? AppTheme.primaryBlue : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                m['text']!,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
                            ),
                          );
                        }),
                        if (_isTyping)
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.cyanAccent),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Gemini Agent thinking...', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              
              // Prompt List
              if (_messages.isEmpty) ...[
                _buildPromptTile(Icons.waves, "Is water supply normal in my area?"),
                const SizedBox(height: 6),
                _buildPromptTile(Icons.access_time, "When will water supply arrive?"),
                const SizedBox(height: 6),
                _buildPromptTile(Icons.speed, "Why is water pressure low?"),
                const SizedBox(height: 6),
                _buildPromptTile(Icons.assignment, "Report a water problem"),
                const SizedBox(height: 12),
              ],
              
              // Input Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppTheme.cyanAccent, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        onSubmitted: _sendMessage,
                        decoration: const InputDecoration(
                          hintText: 'Ask Gemini Agent anything...',
                          hintStyle: TextStyle(color: Colors.white54, fontSize: 13),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: AppTheme.cyanAccent, size: 18),
                      onPressed: () => _sendMessage(_inputController.text),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromptTile(IconData icon, String text) {
    return GestureDetector(
      onTap: () => _sendMessage(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
  }
}
