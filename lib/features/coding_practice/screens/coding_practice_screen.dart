import 'package:flutter/material.dart';
import '../../../core/widgets/drawer_screen_wrapper.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/cpp.dart';
import 'package:highlight/languages/javascript.dart';
import '../providers/coding_practice_provider.dart';
import '../models/coding_question.dart';

class CodingPracticeScreen extends StatefulWidget {
  const CodingPracticeScreen({super.key});

  @override
  State<CodingPracticeScreen> createState() => _CodingPracticeScreenState();
}

class _CodingPracticeScreenState extends State<CodingPracticeScreen>
    with TickerProviderStateMixin {
  late CodeController _codeController;
  late TabController _tabController;
  late PageController _pageController;
  final TextEditingController _inputController = TextEditingController();
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();
    _codeController = CodeController(
      text: _getDefaultCode('python'),
      language: python,
    );
    
    // Add listener to sync with provider
    _codeController.addListener(() {
      if (mounted) {
        context.read<CodingPracticeProvider>().updateCode(_codeController.text);
      }
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CodingPracticeProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _tabController.dispose();
    _pageController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _updateCodeController(String language, String code) {
    final languageMap = {
      'python': python,
      'java': java,
      'cpp': cpp,
      'javascript': javascript,
    };
    
    _codeController.dispose();
    _codeController = CodeController(
      text: code.isEmpty ? _getDefaultCode(language) : code,
      language: languageMap[language] ?? python,
    );
    
    _codeController.addListener(() {
      if (mounted) {
        context.read<CodingPracticeProvider>().updateCode(_codeController.text);
      }
    });
    
    // Force rebuild to show the new code
    if (mounted) {
      setState(() {});
    }
  }

  String _getDefaultCode(String language) {
    switch (language) {
      case 'python':
        return 'def solution():\n    """\n    Implement your solution here\n    """\n    # Your code goes here\n    pass';
      case 'java':
        return '''// Write your Java code here
public class Solution {
    public static void main(String[] args) {
        // Your solution goes here
        System.out.println("Hello World");
    }
}''';
      case 'cpp':
        return '''// Write your C++ code here
#include <iostream>
using namespace std;

int main() {
    // Your solution goes here
    cout << "Hello World" << endl;
    return 0;
}''';
      case 'javascript':
        return '''// Write your JavaScript code here
function solution() {
    // Your solution goes here
    return "Hello World";
}

// Test your solution
console.log(solution());''';
      default:
        return '// Start coding here...';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    final isMobile = screenWidth < 600;
    
    return DrawerScreenWrapper(
      title: 'AI Coding Practice',
      child: Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Consumer<CodingPracticeProvider>(
        builder: (context, provider, child) {
          if (provider.currentQuestion == null) {
            return _buildLoadingScreen();
          }

          // Update code controller when needed
          if (_codeController.text != provider.currentCode) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateCodeController(provider.selectedLanguage, provider.currentCode);
            });
          }

          return SafeArea(
            child: Column(
              children: [
                // Modern App Bar
                _buildModernAppBar(provider, context),
                
                // Main Content
                Expanded(
                  child: isMobile 
                    ? _buildMobileLayout(provider, context)
                    : isTablet 
                      ? _buildTabletLayout(provider, context)
                      : _buildDesktopLayout(provider, context),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButtons(context),
    ),
    );
  }

  // Modern Loading Screen
  Widget _buildLoadingScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            SizedBox(height: 24),
            Text(
              '🚀 Loading Coding Challenges...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Preparing your coding environment',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modern App Bar
  Widget _buildModernAppBar(CodingPracticeProvider provider, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => DrawerScreenWrapper.openDrawer(context),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
              const Expanded(
                child: Text(
                  '🚀 AI Coding Practice',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              _buildQuestionSelector(provider),
            ],
          ),
          const SizedBox(height: 16),
          _buildQuestionHeader(provider),
        ],
      ),
    );
  }

  // Question Selector
  Widget _buildQuestionSelector(CodingPracticeProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: PopupMenuButton<CodingQuestion>(
        icon: const Icon(Icons.quiz_outlined, color: Colors.white, size: 24),
        tooltip: 'Select Question',
        onSelected: (question) {
          provider.selectQuestion(question);
          _updateCodeController(provider.selectedLanguage, provider.currentCode);
        },
        itemBuilder: (context) {
          return provider.sampleQuestions.map((question) {
            return PopupMenuItem<CodingQuestion>(
              value: question,
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(question.difficulty),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            question.difficulty,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Wrap(
                            spacing: 4,
                            children: question.tags.take(2).map((tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tag,
                                style: const TextStyle(fontSize: 10),
                              ),
                            )).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList();
        },
      ),
    );
  }

  // Question Header
  Widget _buildQuestionHeader(CodingPracticeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.currentQuestion?.title ?? 'Loading...',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(provider.currentQuestion?.difficulty ?? 'Easy'),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        provider.currentQuestion?.difficulty ?? 'Easy',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ...provider.currentQuestion?.tags.take(2).map((tag) => Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    )) ?? [],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.code,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // Mobile Layout
  Widget _buildMobileLayout(CodingPracticeProvider provider, BuildContext context) {
    return PageView(
      controller: _pageController,
      children: [
        _buildQuestionPage(provider),
        _buildCodeEditorPage(provider),
        _buildOutputPage(provider),
      ],
    );
  }

  // Tablet Layout
  Widget _buildTabletLayout(CodingPracticeProvider provider, BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildQuestionPage(provider),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: _buildCodeEditorPage(provider),
              ),
              Expanded(
                flex: 1,
                child: _buildOutputPage(provider),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Desktop Layout
  Widget _buildDesktopLayout(CodingPracticeProvider provider, BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildQuestionPage(provider),
        ),
        Expanded(
          flex: 2,
          child: _buildCodeEditorPage(provider),
        ),
        Expanded(
          flex: 1,
          child: _buildOutputPage(provider),
        ),
      ],
    );
  }

  // Question Page
  Widget _buildQuestionPage(CodingPracticeProvider provider) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.quiz,
                    color: Color(0xFF667EEA),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Problem Statement',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              provider.currentQuestion?.description ?? '',
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Color(0xFF374151),
              ),
            ),
            if (provider.currentQuestion?.sampleInput.isNotEmpty == true) ...[
              const SizedBox(height: 24),
              _buildSampleSection('Sample Input:', provider.currentQuestion!.sampleInput),
            ],
            if (provider.currentQuestion?.expectedOutput.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              _buildSampleSection('Expected Output:', provider.currentQuestion!.expectedOutput),
            ],
          ],
        ),
      ),
    );
  }

  // Sample Section
  Widget _buildSampleSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF667EEA),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: Color(0xFF374151),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }


  // Code Editor Page
  Widget _buildCodeEditorPage(CodingPracticeProvider provider) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with Language Selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.code,
                    color: Color(0xFF667EEA),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Code Editor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                _buildLanguageSelector(provider),
              ],
            ),
          ),
          
          // Code Editor
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: CodeField(
                controller: _codeController,
                textStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 16,
                  height: 1.6,
                  color: Color(0xFF1F2937), // Dark text color for visibility
                  fontWeight: FontWeight.w500,
                ),
                cursorColor: const Color(0xFF6366F1),
                lineNumberStyle: const LineNumberStyle(
                  textStyle: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 14,
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                ),
                background: Colors.white,
                padding: const EdgeInsets.all(16),
                expands: true,
              ),
            ),
          ),
          
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: provider.isExecuting 
                        ? null 
                        : () => provider.runCode(stdin: _inputController.text),
                    icon: provider.isExecuting 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.play_arrow, size: 20),
                    label: Text(
                      provider.isExecuting ? 'Running...' : 'Run Code',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => provider.resetCurrentQuestion(),
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B7280),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Language Selector
  Widget _buildLanguageSelector(CodingPracticeProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: provider.selectedLanguage,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF667EEA), size: 20),
          items: ['python', 'java', 'cpp', 'javascript'].map((lang) {
            return DropdownMenuItem(
              value: lang,
              child: Text(
                lang.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              provider.selectLanguage(value);
              _updateCodeController(value, '');
            }
          },
        ),
      ),
    );
  }

  // Output Page
  Widget _buildOutputPage(CodingPracticeProvider provider) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.terminal,
                    color: Color(0xFF667EEA),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Output & Results',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    labelColor: const Color(0xFF667EEA),
                    unselectedLabelColor: Colors.grey[600],
                    indicatorColor: const Color(0xFF667EEA),
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    tabs: const [
                      Tab(text: 'Output'),
                      Tab(text: 'AI Feedback'),
                      Tab(text: 'Solution'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildOutputTab(provider),
                        _buildFeedbackTab(provider),
                        _buildSolutionTab(provider),
                      ],
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

  // Floating Action Buttons
  Widget _buildFloatingActionButtons(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    if (!isMobile) return const SizedBox.shrink();
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: "fullscreen",
          onPressed: () {
            setState(() {
              _isFullScreen = !_isFullScreen;
            });
          },
          backgroundColor: const Color(0xFF667EEA),
          child: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: "navigation",
          onPressed: () {
            _showNavigationBottomSheet(context);
          },
          backgroundColor: const Color(0xFF10B981),
          child: const Icon(Icons.navigation),
        ),
      ],
    );
  }

  // Navigation Bottom Sheet
  void _showNavigationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Navigate to Section',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildNavButton(
                    'Problem',
                    Icons.quiz,
                    () {
                      _pageController.animateToPage(0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNavButton(
                    'Code',
                    Icons.code,
                    () {
                      _pageController.animateToPage(1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNavButton(
                    'Output',
                    Icons.terminal,
                    () {
                      _pageController.animateToPage(2,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF667EEA).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF667EEA).withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF667EEA), size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF667EEA),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutputTab(CodingPracticeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: provider.executionResult == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667EEA).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.play_circle_outline,
                      size: 48,
                      color: Color(0xFF667EEA),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Run your code to see output',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Click the "Run Code" button to execute your solution',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (provider.executionResult!['funny_message'] != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: provider.executionResult!['success'] == true
                            ? const Color(0xFF10B981).withOpacity(0.1)
                            : const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: provider.executionResult!['success'] == true
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            provider.executionResult!['success'] == true
                                ? Icons.check_circle
                                : Icons.error,
                            color: provider.executionResult!['success'] == true
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              provider.executionResult!['funny_message'],
                              style: TextStyle(
                                color: provider.executionResult!['success'] == true
                                    ? const Color(0xFF065F46)
                                    : const Color(0xFF991B1B),
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  if (provider.executionResult!['stdout']?.isNotEmpty == true) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.terminal,
                            color: Color(0xFF10B981),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Output:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        provider.executionResult!['stdout'],
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          height: 1.4,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                  
                  if (provider.executionResult!['stderr']?.isNotEmpty == true) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.error_outline,
                            color: Color(0xFFEF4444),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Error:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                      ),
                      child: Text(
                        provider.executionResult!['stderr'],
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          color: Color(0xFFEF4444),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildFeedbackTab(CodingPracticeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: provider.aiFeedback == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667EEA).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.psychology_outlined,
                      size: 48,
                      color: Color(0xFF667EEA),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Get AI-powered feedback on your code',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Run your code first, then get personalized feedback',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: provider.isGettingFeedback || provider.executionResult == null
                        ? null 
                        : provider.checkAnswer,
                    icon: provider.isGettingFeedback 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.psychology, size: 20),
                    label: Text(
                      provider.isGettingFeedback ? 'Getting Feedback...' : 'Get AI Feedback',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'AI Feedback',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Score: ${provider.aiFeedback!['score'] ?? 'N/A'}/10',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      provider.aiFeedback!['feedback'] ?? 'No feedback available',
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  if (provider.aiFeedback!['suggestion'] != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.lightbulb_outline, color: Color(0xFF10B981), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Suggestion',
                                style: TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.aiFeedback!['suggestion'],
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSolutionTab(CodingPracticeProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: provider.solutionData == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667EEA).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline,
                      size: 48,
                      color: Color(0xFF667EEA),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Get AI-generated solution',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'View the optimal solution with detailed explanation',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: provider.isGeneratingSolution
                        ? null
                        : provider.showSolution,
                    icon: provider.isGeneratingSolution
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.lightbulb, size: 20),
                    label: Text(
                      provider.isGeneratingSolution 
                          ? 'Generating...' 
                          : 'Get AI Solution',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                  
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              provider.solutionData?['is_ai_generated'] == true 
                                  ? 'AI Generated Solution' 
                                  : 'Optimal Solution',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Question: ${provider.solutionData?['question_title'] ?? provider.currentQuestion?.title ?? 'Unknown'}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                provider.solutionData?['question_difficulty'] ?? provider.currentQuestion?.difficulty ?? 'Medium',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                provider.selectedLanguage.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.code, color: Color(0xFF667EEA), size: 16),
                            const SizedBox(width: 8),
                            const Text(
                              'Solution Code',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF667EEA),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                  text: provider.solutionData!['code'] ?? '',
                                ));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Solution copied to clipboard!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy, size: 16),
                              tooltip: 'Copy to clipboard',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          child: Text(
                            provider.solutionData!['code']?.isNotEmpty == true 
                                ? provider.solutionData!['code']! 
                                : 'No solution code available. Debug info: ${provider.solutionData.toString()}',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                              height: 1.5,
                              color: provider.solutionData!['code']?.isNotEmpty == true 
                                  ? const Color(0xFF374151)
                                  : Colors.red,
                            ),
                          ),
                        ),
                        if (provider.solutionData!['time_complexity'] != null || provider.solutionData!['space_complexity'] != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              if (provider.solutionData!['time_complexity'] != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    'Time: ${provider.solutionData!['time_complexity']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              if (provider.solutionData!['space_complexity'] != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    'Space: ${provider.solutionData!['space_complexity']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF3B82F6),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (provider.solutionData!['explanation'] != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.description, color: Color(0xFF10B981), size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Explanation',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.solutionData!['explanation'],
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (provider.solutionData!['time_complexity'] != null ||
                      provider.solutionData!['space_complexity'] != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (provider.solutionData!['time_complexity'] != null)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.schedule, color: Color(0xFFF59E0B), size: 16),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Time',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFF59E0B),
                                    ),
                                  ),
                                  Text(
                                    provider.solutionData!['time_complexity'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF374151),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (provider.solutionData!['time_complexity'] != null &&
                            provider.solutionData!['space_complexity'] != null)
                          const SizedBox(width: 12),
                        if (provider.solutionData!['space_complexity'] != null)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.memory, color: Color(0xFF8B5CF6), size: 16),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Space',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF8B5CF6),
                                    ),
                                  ),
                                  Text(
                                    provider.solutionData!['space_complexity'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF374151),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
    );
  }


  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF10B981);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'hard':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

}
