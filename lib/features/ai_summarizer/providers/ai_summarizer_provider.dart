import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/summary_model.dart';
import '../services/openrouter_api_service.dart';
import '../services/pdf_generator_service.dart';

class AiSummarizerProvider extends ChangeNotifier {
  final OpenRouterApiService _openRouterService = OpenRouterApiService();
  final PdfGeneratorService _pdfService = PdfGeneratorService();
  final Uuid _uuid = const Uuid();

  List<SummaryModel> _summaries = [];
  bool _isLoading = false;
  bool _isGenerating = false;
  String? _errorMessage;
  String _inputText = '';
  SummaryModel? _currentSummary;

  // Getters
  List<SummaryModel> get summaries => _summaries;
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  String? get errorMessage => _errorMessage;
  String get inputText => _inputText;
  SummaryModel? get currentSummary => _currentSummary;

  /// Update input text
  void updateInputText(String text) {
    _inputText = text;
    _clearError();
    notifyListeners();
  }



  /// Generate summary from text input
  Future<void> generateSummaryFromText() async {
    if (_inputText.trim().isEmpty) {
      _setError('Please enter some text to summarize');
      return;
    }

    await _generateSummary(_inputText, 'text', null);
  }


  /// Core summary generation method
  Future<void> _generateSummary(String content, String sourceType, String? fileName) async {
    try {
      _setGenerating(true);
      _clearError();

      if (kDebugMode) print('🧠 Generating summary for ${content.length} characters');

      // Generate title
      final title = await _openRouterService.generateTitle(content);
      
      // Generate summary
      final result = await _openRouterService.summarizeText(content);
      
      if (result['success'] == true) {
        final summary = SummaryModel(
          id: _uuid.v4(),
          title: title,
          originalContent: content,
          summarizedContent: result['summary'] ?? '',
          sourceType: sourceType,
          fileName: fileName,
          createdAt: DateTime.now(),
          wordCount: result['wordCount'] ?? content.split(' ').length,
          keyPoints: List<String>.from(result['keyPoints'] ?? []),
        );

        _summaries.insert(0, summary);
        _currentSummary = summary;
        
        // Clear inputs after successful generation
        _inputText = '';
        
        if (kDebugMode) print('✅ Summary generated successfully: ${summary.title}');
      } else {
        _setError('Failed to generate summary');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error generating summary: $e');
      _setError('Failed to generate summary. Please try again.');
    } finally {
      _setGenerating(false);
    }
  }

  /// Generate and download PDF
  Future<void> downloadSummaryAsPdf(SummaryModel summary) async {
    try {
      _setLoading(true);
      _clearError();

      final pdfFile = await _pdfService.generateSummaryPdf(summary);
      
      // Show success message or handle file opening
      if (kDebugMode) print('✅ PDF downloaded: ${pdfFile.path}');
      
    } catch (e) {
      _setError('Failed to download PDF: $e');
      if (kDebugMode) print('❌ PDF download error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Share summary as PDF
  Future<void> shareSummaryAsPdf(SummaryModel summary) async {
    try {
      _setLoading(true);
      _clearError();

      final pdfFile = await _pdfService.generateSummaryPdf(summary);
      await _pdfService.sharePdf(pdfFile, summary.title);
      
    } catch (e) {
      _setError('Failed to share PDF: $e');
      if (kDebugMode) print('❌ PDF share error: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Preview PDF
  Future<void> previewSummaryPdf(SummaryModel summary) async {
    try {
      _clearError();
      await _pdfService.previewPdf(summary);
    } catch (e) {
      _setError('Failed to preview PDF: $e');
      if (kDebugMode) print('❌ PDF preview error: $e');
    }
  }

  /// Delete summary
  void deleteSummary(String summaryId) {
    _summaries.removeWhere((summary) => summary.id == summaryId);
    notifyListeners();
  }

  /// Clear all summaries
  void clearAllSummaries() {
    _summaries.clear();
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setGenerating(bool generating) {
    _isGenerating = generating;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Save current summary to permanent list
  void saveSummary(SummaryModel summary) {
    if (!_summaries.contains(summary)) {
      _summaries.insert(0, summary);
    }
    notifyListeners();
  }

  /// Clear current summary display
  void clearCurrentSummary() {
    _currentSummary = null;
    notifyListeners();
  }

  /// Clear all data
  void clearAll() {
    _inputText = '';
    _currentSummary = null;
    _clearError();
    notifyListeners();
  }
}
