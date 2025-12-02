import 'package:flutter/material.dart';
import '../../../core/widgets/drawer_screen_wrapper.dart';
import 'package:provider/provider.dart';
import '../providers/ai_interview_provider.dart';
import '../widgets/job_role_selection_widget.dart';
import '../widgets/interview_question_widget.dart';
import '../widgets/answer_input_widget.dart';
import '../widgets/feedback_display_widget.dart';
import '../widgets/interview_summary_widget.dart';
import '../widgets/language_selection_dialog.dart';

class AIInterviewScreen extends StatefulWidget {
  const AIInterviewScreen({super.key});

  @override
  State<AIInterviewScreen> createState() => _AIInterviewScreenState();
}

class _AIInterviewScreenState extends State<AIInterviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _hasGreeted = false;
  bool _hasShownLanguageDialog = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();

    // Show language selection dialog first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_hasShownLanguageDialog) {
          _showLanguageSelectionDialog();
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DrawerScreenWrapper(
      title: 'AI Interview',
      child: Consumer<AIInterviewProvider>(
        builder: (context, provider, child) {
          return PopScope(
            canPop: !provider.isInterviewCompleted,
            onPopInvokedWithResult: (didPop, result) async {
              if (!didPop && provider.isInterviewCompleted) {
                _showCompletedInterviewExitConfirmation(context, provider);
              }
            },
            child: Scaffold(
              backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('AI Interview', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => DrawerScreenWrapper.openDrawer(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
                Color(0xFF6C5CE7),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFF6C5CE7),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<AIInterviewProvider>(
            builder: (context, provider, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: _buildContent(context, provider),
              );
            },
          ),
        ),
      ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, AIInterviewProvider provider) {
    // Show error if any
    if (provider.error != null) {
      return _buildErrorWidget(context, provider);
    }

    // Show job role selection if no session
    if (provider.currentSession == null) {
      return _buildJobRoleSelection(context, provider);
    }

    // Show interview completed summary
    if (provider.isInterviewCompleted) {
      return const InterviewSummaryWidget();
    }

    // Show interview in progress
    return _buildInterviewInProgress(context, provider);
  }

  Widget _buildJobRoleSelection(BuildContext context, AIInterviewProvider provider) {
    return Column(
      children: [
        _buildAppBar(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAryaIntroduction(provider),
                const SizedBox(height: 30),
                const JobRoleSelectionWidget(),
                const SizedBox(height: 30),
                _buildVoiceIntroductionButton(provider),
                const SizedBox(height: 16),
                _buildStartInterviewButton(provider),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInterviewInProgress(BuildContext context, AIInterviewProvider provider) {
    return Column(
      children: [
        _buildInterviewAppBar(context, provider),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const InterviewQuestionWidget(),
                const SizedBox(height: 20),
                if (provider.hasCurrentQuestionBeenAnswered && provider.currentFeedback != null)
                  const FeedbackDisplayWidget()
                else
                  const AnswerInputWidget(),
                const SizedBox(height: 20),
                if (provider.hasCurrentQuestionBeenAnswered)
                  _buildNextQuestionButton(provider),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: const Text(
              'AI Interview with Arya',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Consumer<AIInterviewProvider>(
            builder: (context, provider, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Language Toggle Button
                  IconButton(
                    onPressed: () async {
                      String newLang = provider.currentLanguage == 'en-US' ? 'hi-IN' : 'en-US';
                      await provider.setLanguage(newLang);
                    },
                    icon: Icon(
                      Icons.translate,
                      color: provider.currentLanguage == 'hi-IN' ? Colors.orange : Colors.white,
                      size: 24,
                    ),
                    tooltip: provider.currentLanguage == 'hi-IN' ? 'Switch to English' : 'Switch to Hindi',
                  ),
                  // Auto-speak Toggle Button
                  IconButton(
                    onPressed: () => provider.toggleAutoSpeak(),
                    icon: Icon(
                      provider.autoSpeakEnabled ? Icons.record_voice_over : Icons.voice_over_off,
                      color: provider.autoSpeakEnabled ? Colors.greenAccent : Colors.white,
                      size: 24,
                    ),
                    tooltip: provider.autoSpeakEnabled ? 'Disable Auto Voice' : 'Enable Auto Voice',
                  ),
                  // TTS Toggle Button
                  IconButton(
                    onPressed: () => provider.toggleTTS(),
                    icon: Icon(
                      provider.isTTSEnabled ? Icons.volume_up : Icons.volume_off,
                      color: Colors.white,
                      size: 24,
                    ),
                    tooltip: provider.isTTSEnabled ? 'Disable Arya Voice' : 'Enable Arya Voice',
                  ),
                  // Speaking indicator with auto-speak status
                  if (provider.isAryaSpeaking)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                provider.autoSpeakEnabled ? Colors.greenAccent : Colors.white
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            provider.autoSpeakEnabled ? 'Arya Speaking...' : 'Speaking...',
                            style: TextStyle(
                              color: provider.autoSpeakEnabled 
                                  ? Colors.greenAccent.withOpacity(0.9)
                                  : Colors.white.withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: provider.autoSpeakEnabled ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInterviewAppBar(BuildContext context, AIInterviewProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              _showExitConfirmation(context, provider);
            },
            icon: const Icon(Icons.close, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Interview: ${provider.selectedJobRole?.title ?? 'Unknown'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Question ${provider.getQuestionProgress()} • ${provider.getCurrentDifficulty()}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              provider.getQuestionProgress(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAryaIntroduction(AIInterviewProvider provider) {
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
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Arya',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'AI Interviewer',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            provider.getIntroductionMessage(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceIntroductionButton(AIInterviewProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: provider.isTTSEnabled && !provider.autoSpeakEnabled && !provider.isAryaSpeaking
            ? () => provider.speakIntroduction()
            : provider.isAryaSpeaking
                ? () => provider.stopAryaSpeaking()
                : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: provider.isAryaSpeaking
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(
                provider.isTTSEnabled ? Icons.play_arrow : Icons.volume_off,
                size: 20,
              ),
        label: Text(
          provider.isAryaSpeaking
              ? 'Stop Arya Speaking'
              : provider.autoSpeakEnabled
                  ? 'Auto Voice Enabled'
                  : provider.isTTSEnabled
                      ? 'Hear Arya\'s Introduction'
                      : 'Voice Disabled',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStartInterviewButton(AIInterviewProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: provider.selectedJobRole != null && !provider.isLoadingQuestions
            ? () => provider.startInterview()
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF667eea),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: provider.isLoadingQuestions
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                ),
              )
            : const Text(
                'Start Interview with Arya',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildNextQuestionButton(AIInterviewProvider provider) {
    final isLastQuestion = provider.currentQuestionIndex >= 
        (provider.currentSession?.questions.length ?? 0) - 1;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => provider.nextQuestion(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF667eea),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          isLastQuestion ? 'Complete Interview' : 'Next Question',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, AIInterviewProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Something went wrong',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearError();
                      provider.resetInterview();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF667eea),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context, AIInterviewProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Exit Interview?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to exit the interview? Your progress will be lost.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF667eea)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                provider.resetInterview();
                Navigator.pop(context);
              },
              child: const Text(
                'Exit',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCompletedInterviewExitConfirmation(BuildContext context, AIInterviewProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.celebration,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Interview Complete!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Congratulations! You\'ve successfully completed your AI interview with Arya.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF667eea).withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Color(0xFF667eea),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your performance data has been saved. Review your results before leaving.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'What would you like to do?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Stay & Review',
                style: TextStyle(color: Color(0xFF667eea)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                provider.resetInterview();
              },
              child: const Text(
                'New Interview',
                style: TextStyle(color: Colors.orange),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                provider.resetInterview();
                _navigateBackToDashboard(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Go to Dashboard',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageSelectionDialog() {
    _hasShownLanguageDialog = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LanguageSelectionDialog(
          onLanguageSelected: (String languageCode, String languageName) async {
            final provider = context.read<AIInterviewProvider>();
            
            // Set the selected language
            await provider.setLanguage(languageCode);
            
            // Show a brief confirmation
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Language set to $languageName',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFF667eea),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
            
            // Auto-greet after language selection
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (mounted && !_hasGreeted) {
                if (provider.isTTSEnabled) {
                  _hasGreeted = true;
                  provider.speakIntroduction();
                }
              }
            });
          },
        );
      },
    );
  }

  void _navigateBackToDashboard(BuildContext context) {
    // Use the DrawerScreenWrapper method for consistent navigation
    DrawerScreenWrapper.navigateToDashboard(context);
  }
}
