import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../../../core/models/research_paper.dart';
import '../../../core/services/arxiv_service.dart';

class PaperDetailSheet extends StatefulWidget {
  final ResearchPaper paper;

  const PaperDetailSheet({super.key, required this.paper});

  @override
  State<PaperDetailSheet> createState() => _PaperDetailSheetState();
}

class _PaperDetailSheetState extends State<PaperDetailSheet> {
  final ArxivService _arxivService = ArxivService();
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  Future<void> _downloadPaper() async {
    if (mounted) {
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0.0;
      });
    }

    try {
      final filePath = await _arxivService.downloadPaper(
        pdfUrl: widget.paper.pdfUrl,
        title: widget.paper.title,
        onProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }

      _showSuccessSnackBar('Paper downloaded successfully!');
      
      // Optionally open the downloaded file
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Download Complete'),
          content: const Text('Would you like to open the downloaded paper?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Open'),
            ),
          ],
        ),
      );

      if (result == true && filePath.isNotEmpty) {
        // Try to open the downloaded PDF file
        await _openDownloadedPDF(filePath);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
      _showErrorSnackBar('Download failed: $e');
    }
  }

  Future<void> _openAbstract() async {
    final url = Uri.parse(widget.paper.abstractUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showErrorSnackBar('Could not open abstract URL');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openDownloadedPDF(String filePath) async {
    try {
      // Check if file exists
      final file = File(filePath);
      if (!await file.exists()) {
        _showErrorSnackBar('Downloaded file not found');
        return;
      }

      // Try to open using url_launcher with file:// scheme
      final uri = Uri.file(filePath);
      
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        if (launched) {
          _showSuccessSnackBar('PDF opened in your default PDF viewer!');
        } else {
          _showFileLocationDialog(filePath);
        }
      } else {
        _showFileLocationDialog(filePath);
      }
    } catch (e) {
      _showFileLocationDialog(filePath);
    }
  }

  void _showFileLocationDialog(String filePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.folder_open, color: Colors.blue),
              const SizedBox(width: 8),
              const Text('File Downloaded'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your PDF has been downloaded successfully!',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'File Location:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      filePath,
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'You can open it manually using your device\'s file manager or any PDF viewer app like Adobe Reader, Google PDF Viewer, etc.',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Try to open the downloads folder
                try {
                  final downloadsUri = Uri.parse('content://com.android.externalstorage.documents/document/primary%3ADownload%2FCollegePro');
                  if (await canLaunchUrl(downloadsUri)) {
                    await launchUrl(downloadsUri, mode: LaunchMode.externalApplication);
                  } else {
                    _showSuccessSnackBar('Please check your Downloads/CollegePro folder');
                  }
                } catch (e) {
                  _showSuccessSnackBar('Please check your Downloads/CollegePro folder');
                }
              },
              child: const Text('Open Folder'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              _buildHandle(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(isDark),
                      const SizedBox(height: 24),
                      _buildTitle(isDark),
                      const SizedBox(height: 16),
                      _buildAuthors(isDark),
                      const SizedBox(height: 16),
                      _buildMetadata(isDark),
                      const SizedBox(height: 24),
                      _buildSummary(isDark),
                      const SizedBox(height: 24),
                      _buildCategories(isDark),
                      const SizedBox(height: 32),
                      _buildActions(isDark),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.article_rounded,
            color: Color(0xFF6C63FF),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Research Paper',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
              Text(
                'arXiv:${widget.paper.arxivId}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }

  Widget _buildTitle(bool isDark) {
    return Text(
      widget.paper.title,
      style: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
        height: 1.3,
      ),
    );
  }

  Widget _buildAuthors(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Authors',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.paper.authors.map((author) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                author,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMetadata(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildMetadataItem(
            'Published',
            DateFormat('MMM dd, yyyy').format(widget.paper.publishedDate),
            Icons.calendar_today_rounded,
            isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetadataItem(
            'Updated',
            DateFormat('MMM dd, yyyy').format(widget.paper.updatedDate),
            Icons.update_rounded,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataItem(String label, String value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Abstract',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.paper.summary,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCategories(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.paper.categories.map((category) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                category,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6C63FF),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActions(bool isDark) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isDownloading ? null : _downloadPaper,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isDownloading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          value: _downloadProgress,
                          strokeWidth: 2,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Downloading... ${(_downloadProgress * 100).toInt()}%',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.download_rounded),
                      const SizedBox(width: 8),
                      Text(
                        'Download PDF',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _openAbstract,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6C63FF),
              side: const BorderSide(color: Color(0xFF6C63FF)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.open_in_new_rounded),
                const SizedBox(width: 8),
                Text(
                  'View on arXiv',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
