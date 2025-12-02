import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_interview_provider.dart';
import '../models/interview_models.dart';

class AnswerInputWidget extends StatefulWidget {
  const AnswerInputWidget({super.key});

  @override
  State<AnswerInputWidget> createState() => _AnswerInputWidgetState();
}

class _AnswerInputWidgetState extends State<AnswerInputWidget>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Add listener to text controller to trigger rebuilds when text changes
    _textController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AIInterviewProvider>(
      builder: (context, provider, child) {
        // Update text controller with speech text
        if (provider.inputMode == InputMode.voice && provider.speechText.isNotEmpty) {
          _textController.text = provider.speechText;
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputModeSelector(provider),
              const SizedBox(height: 20),
              if (provider.inputMode == InputMode.text)
                _buildTextInput(provider)
              else
                _buildVoiceInput(provider),
              const SizedBox(height: 20),
              _buildSubmitButton(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputModeSelector(AIInterviewProvider provider) {
    return Row(
      children: [
        Text(
          'Your Answer:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildModeButton(
                icon: Icons.keyboard,
                label: 'Text',
                isSelected: provider.inputMode == InputMode.text,
                onTap: () => provider.setInputMode(InputMode.text),
              ),
              _buildModeButton(
                icon: Icons.mic,
                label: 'Voice',
                isSelected: provider.inputMode == InputMode.voice,
                onTap: provider.isSpeechEnabled
                    ? () => provider.setInputMode(InputMode.voice)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: onTap != null
                  ? (isSelected ? Colors.white : Colors.white.withOpacity(0.7))
                  : Colors.white.withOpacity(0.3),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: onTap != null
                    ? (isSelected ? Colors.white : Colors.white.withOpacity(0.7))
                    : Colors.white.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput(AIInterviewProvider provider) {
    return TextField(
      controller: _textController,
      maxLines: 6,
      onChanged: (value) {
        // Trigger rebuild when text changes to update submit button state
        setState(() {});
      },
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText: 'Type your answer here...',
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 16,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildVoiceInput(AIInterviewProvider provider) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              if (provider.isListening) ...[
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    if (provider.isListening && !_pulseController.isAnimating) {
                      _pulseController.repeat(reverse: true);
                    } else if (!provider.isListening && _pulseController.isAnimating) {
                      _pulseController.stop();
                    }
                    
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667eea).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Listening...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Speak clearly and naturally',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ] else ...[
                GestureDetector(
                  onTap: provider.startListening,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tap to start speaking',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Voice recognition is ready',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (provider.speechText.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Recognized Text:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (provider.speechConfidence > 0)
                      Text(
                        '${(provider.speechConfidence * 100).toInt()}% confident',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  provider.speechText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: provider.clearSpeechText,
                      icon: const Icon(Icons.clear, size: 16, color: Colors.white70),
                      label: const Text(
                        'Clear',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton.icon(
                      onPressed: provider.startListening,
                      icon: const Icon(Icons.refresh, size: 16, color: Colors.white70),
                      label: const Text(
                        'Try Again',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        if (provider.isListening) ...[
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: provider.stopListening,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text('Stop Recording'),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton(AIInterviewProvider provider) {
    final hasAnswer = provider.inputMode == InputMode.text
        ? _textController.text.trim().isNotEmpty
        : provider.speechText.trim().isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: hasAnswer && !provider.isEvaluatingAnswer
            ? () => _submitAnswer(provider)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: hasAnswer ? Colors.white : Colors.white.withOpacity(0.3),
          foregroundColor: hasAnswer ? const Color(0xFF667eea) : Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: hasAnswer ? 2 : 0,
        ),
        child: provider.isEvaluatingAnswer
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                ),
              )
            : Text(
                hasAnswer ? 'Submit Answer' : 'Type your answer first',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: hasAnswer ? const Color(0xFF667eea) : Colors.grey,
                ),
              ),
      ),
    );
  }

  void _submitAnswer(AIInterviewProvider provider) {
    final answer = provider.inputMode == InputMode.text
        ? _textController.text.trim()
        : provider.speechText.trim();

    if (answer.isNotEmpty) {
      provider.submitAnswer(answer);
      _textController.clear();
    }
  }
}
