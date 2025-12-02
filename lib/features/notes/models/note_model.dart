class NoteModel {
  final String id;
  final String title;
  final String subject;
  final String driveUrl;
  final String fileName;
  final String fileExtension;
  final String? localPath;
  final bool isDownloaded;
  final DateTime? downloadedAt;

  const NoteModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.driveUrl,
    required this.fileName,
    required this.fileExtension,
    this.localPath,
    this.isDownloaded = false,
    this.downloadedAt,
  });

  NoteModel copyWith({
    String? id,
    String? title,
    String? subject,
    String? driveUrl,
    String? fileName,
    String? fileExtension,
    String? localPath,
    bool? isDownloaded,
    DateTime? downloadedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      driveUrl: driveUrl ?? this.driveUrl,
      fileName: fileName ?? this.fileName,
      fileExtension: fileExtension ?? this.fileExtension,
      localPath: localPath ?? this.localPath,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      downloadedAt: downloadedAt ?? this.downloadedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'driveUrl': driveUrl,
      'fileName': fileName,
      'fileExtension': fileExtension,
      'localPath': localPath,
      'isDownloaded': isDownloaded,
      'downloadedAt': downloadedAt?.millisecondsSinceEpoch,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      driveUrl: map['driveUrl'] ?? '',
      fileName: map['fileName'] ?? '',
      fileExtension: map['fileExtension'] ?? '',
      localPath: map['localPath'],
      isDownloaded: map['isDownloaded'] ?? false,
      downloadedAt: map['downloadedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['downloadedAt'])
          : null,
    );
  }

  @override
  String toString() {
    return 'NoteModel(id: $id, title: $title, subject: $subject, driveUrl: $driveUrl, fileName: $fileName, fileExtension: $fileExtension, localPath: $localPath, isDownloaded: $isDownloaded, downloadedAt: $downloadedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is NoteModel &&
      other.id == id &&
      other.title == title &&
      other.subject == subject &&
      other.driveUrl == driveUrl &&
      other.fileName == fileName &&
      other.fileExtension == fileExtension &&
      other.localPath == localPath &&
      other.isDownloaded == isDownloaded &&
      other.downloadedAt == downloadedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      title.hashCode ^
      subject.hashCode ^
      driveUrl.hashCode ^
      fileName.hashCode ^
      fileExtension.hashCode ^
      localPath.hashCode ^
      isDownloaded.hashCode ^
      downloadedAt.hashCode;
  }
}
