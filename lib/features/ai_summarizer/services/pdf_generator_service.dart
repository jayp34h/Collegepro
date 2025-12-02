import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import '../models/summary_model.dart';

class PdfGeneratorService {
  /// Generate PDF from summary model
  Future<File> generateSummaryPdf(SummaryModel summary) async {
    try {
      if (kDebugMode) print('📄 Generating PDF for summary: ${summary.title}');
      
      final pdf = pw.Document();
      
      // Add page with summary content
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 20),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(
                      color: PdfColors.blue,
                      width: 2,
                    ),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'AI Generated Summary',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      summary.title,
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Generated on: ${_formatDate(summary.createdAt)}',
                          style: const pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.Text(
                          'Word Count: ${summary.wordCount}',
                          style: const pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 24),
              
              // Summary Content
              if (summary.summarizedContent.isNotEmpty) ...[
                pw.Text(
                  'Summary',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.blue200),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: _buildWrappedText(summary.summarizedContent, 12),
                  ),
                ),
                pw.SizedBox(height: 24),
              ],
              
              // Key Points
              if (summary.keyPoints.isNotEmpty) ...[
                pw.Text(
                  'Key Points',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.SizedBox(height: 12),
                ...summary.keyPoints.asMap().entries.map((entry) {
                  final index = entry.key;
                  final point = entry.value;
                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 8),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          width: 20,
                          height: 20,
                          decoration: pw.BoxDecoration(
                            color: PdfColors.blue,
                            borderRadius: pw.BorderRadius.circular(10),
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              '${index + 1}',
                              style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 12),
                        pw.Expanded(
                          child: pw.Text(
                            point,
                            style: const pw.TextStyle(
                              fontSize: 12,
                              lineSpacing: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                pw.SizedBox(height: 24),
              ],
              
              // Source Information
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Source Information',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Source Type: ${summary.sourceType.toUpperCase()}',
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                    if (summary.fileName != null) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'File Name: ${summary.fileName}',
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
              
              pw.SizedBox(height: 32),
              
              // Footer
              pw.Container(
                padding: const pw.EdgeInsets.only(top: 16),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(
                      color: PdfColors.grey300,
                      width: 1,
                    ),
                  ),
                ),
                child: pw.Center(
                  child: pw.Text(
                    'Generated by CollegePro AI Summarizer',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontStyle: pw.FontStyle.italic,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
              ),
            ];
          },
        ),
      );
      
      // Save PDF to device
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'summary_${summary.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      
      final pdfBytes = await pdf.save();
      await file.writeAsBytes(pdfBytes);
      
      if (kDebugMode) print('✅ PDF generated successfully: ${file.path}');
      return file;
    } catch (e) {
      if (kDebugMode) print('❌ PDF generation failed: $e');
      throw Exception('Failed to generate PDF: $e');
    }
  }

  /// Share PDF using system share
  Future<void> sharePdf(File pdfFile, String title) async {
    try {
      await Printing.sharePdf(
        bytes: await pdfFile.readAsBytes(),
        filename: '${title.replaceAll(' ', '_')}.pdf',
      );
    } catch (e) {
      if (kDebugMode) print('❌ PDF sharing failed: $e');
      throw Exception('Failed to share PDF: $e');
    }
  }

  /// Preview PDF before saving
  Future<void> previewPdf(SummaryModel summary) async {
    try {
      final pdf = pw.Document();
      
      // Add the same content as generateSummaryPdf but for preview
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              pw.Text(
                summary.title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(summary.summarizedContent),
              pw.SizedBox(height: 20),
              ...summary.keyPoints.map((point) => pw.Text('• $point')).toList(),
            ];
          },
        ),
      );
      
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      if (kDebugMode) print('❌ PDF preview failed: $e');
      throw Exception('Failed to preview PDF: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Build wrapped text to prevent overflow in PDF
  List<pw.Widget> _buildWrappedText(String text, double fontSize) {
    // Split text into paragraphs and sentences to prevent overflow
    final paragraphs = text.split('\n\n');
    final List<pw.Widget> widgets = [];
    
    for (int i = 0; i < paragraphs.length; i++) {
      final paragraph = paragraphs[i].trim();
      if (paragraph.isEmpty) continue;
      
      // Split long paragraphs into smaller chunks
      final sentences = paragraph.split('. ');
      String currentChunk = '';
      
      for (int j = 0; j < sentences.length; j++) {
        final sentence = sentences[j].trim();
        if (sentence.isEmpty) continue;
        
        final testChunk = currentChunk.isEmpty ? sentence : '$currentChunk. $sentence';
        
        // If chunk gets too long (>500 chars), create a text widget and start new chunk
        if (testChunk.length > 500) {
          if (currentChunk.isNotEmpty) {
            widgets.add(
              pw.Text(
                currentChunk,
                style: pw.TextStyle(
                  fontSize: fontSize,
                  lineSpacing: 1.4,
                ),
                textAlign: pw.TextAlign.justify,
              ),
            );
            widgets.add(pw.SizedBox(height: 8));
          }
          currentChunk = sentence;
        } else {
          currentChunk = testChunk;
        }
      }
      
      // Add remaining chunk
      if (currentChunk.isNotEmpty) {
        widgets.add(
          pw.Text(
            currentChunk,
            style: pw.TextStyle(
              fontSize: fontSize,
              lineSpacing: 1.4,
            ),
            textAlign: pw.TextAlign.justify,
          ),
        );
        
        // Add spacing between paragraphs (except for last paragraph)
        if (i < paragraphs.length - 1) {
          widgets.add(pw.SizedBox(height: 12));
        }
      }
    }
    
    return widgets;
  }
}
