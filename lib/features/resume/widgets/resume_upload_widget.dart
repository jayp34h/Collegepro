import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../core/utils/file_utils.dart';

class ResumeUploadWidget extends StatelessWidget {
  final Function(File file, String fileName) onFileSelected;
  final String? uploadedFileName;
  final bool isLoading;

  const ResumeUploadWidget({
    super.key,
    required this.onFileSelected,
    this.uploadedFileName,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Upload Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              uploadedFileName != null ? Icons.check_circle : Icons.cloud_upload,
              size: 40,
              color: uploadedFileName != null ? Colors.green : theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            uploadedFileName != null ? 'Resume Uploaded!' : 'Upload Your Resume',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle with file info
          if (uploadedFileName != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  FileUtils.getFileTypeIcon(uploadedFileName!),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    uploadedFileName!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Ready for AI analysis',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.green[600],
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            Text(
              'Upload PDF, DOCX, or DOC file to get AI-powered analysis',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),

          // Upload Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : _pickFile,
              icon: isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(uploadedFileName != null ? Icons.refresh : Icons.upload_file),
              label: Text(
                isLoading 
                    ? 'Processing...'
                    : uploadedFileName != null 
                        ? 'Upload Different File'
                        : 'Choose File',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          if (uploadedFileName == null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Supported formats',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PDF, DOCX, DOC (Max 10MB)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        onFileSelected(file, fileName);
      }
    } catch (e) {
      // Handle error silently or show a snackbar
      debugPrint('Error picking file: $e');
    }
  }
}
