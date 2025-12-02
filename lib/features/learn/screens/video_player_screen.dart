import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../services/youtube_service.dart';
import '../services/video_history_service.dart';
import '../providers/learn_provider.dart';
import '../../../core/providers/auth_provider.dart';

class VideoPlayerScreen extends StatefulWidget {
  final YouTubeVideo video;

  const VideoPlayerScreen({
    super.key,
    required this.video,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  bool _isFullScreen = false;
  YouTubeVideoDetails? _videoDetails;
  Duration _lastPosition = Duration.zero;
  bool _hasStartedTracking = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _loadVideoDetails();
  }

  void _initializePlayer() {
    _controller = YoutubePlayerController(
      initialVideoId: widget.video.id,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    );
    
    _controller.addListener(_listener);
  }

  void _listener() {
    if (_isPlayerReady && mounted && _controller.value.isFullScreen != _isFullScreen) {
      setState(() {
        _isFullScreen = _controller.value.isFullScreen;
      });
    }
    
    // Track video progress
    if (_isPlayerReady && mounted) {
      final currentPosition = _controller.value.position;
      final totalDuration = _controller.value.metaData.duration;
      
      // Start tracking when video actually starts playing
      if (!_hasStartedTracking && currentPosition.inSeconds > 0) {
        _startVideoTracking();
        _hasStartedTracking = true;
      }
      
      // Update progress every 10 seconds or significant position change
      if ((currentPosition - _lastPosition).inSeconds.abs() >= 10) {
        _updateVideoProgress(currentPosition, totalDuration);
        _lastPosition = currentPosition;
      }
    }
  }

  Future<void> _loadVideoDetails() async {
    final learnProvider = context.read<LearnProvider>();
    final details = await learnProvider.getVideoDetails(widget.video.id);
    if (mounted) {
      setState(() {
        _videoDetails = details;
      });
    }
  }

  Future<void> _startVideoTracking() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid;
    
    if (userId != null) {
      await VideoHistoryService.startWatchSession(
        userId: userId,
        video: widget.video,
        category: 'Educational', // You can make this dynamic based on video content
        tags: [widget.video.channelTitle], // Add relevant tags
      );
    }
  }

  Future<void> _updateVideoProgress(Duration currentPosition, Duration totalDuration) async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid;
    
    if (userId != null) {
      await VideoHistoryService.updateWatchProgress(
        userId: userId,
        videoId: widget.video.id,
        currentPosition: currentPosition,
        totalDuration: totalDuration,
      );
    }
  }

  Future<void> _endVideoTracking() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid;
    
    if (userId != null) {
      final currentPosition = _controller.value.position;
      final totalDuration = _controller.value.metaData.duration;
      
      await VideoHistoryService.endWatchSession(
        userId: userId,
        videoId: widget.video.id,
        finalPosition: currentPosition,
        totalDuration: totalDuration,
      );
    }
  }

  @override
  void dispose() {
    // End video tracking before disposing
    if (_hasStartedTracking) {
      _endVideoTracking();
    }
    _controller.removeListener(_listener);
    _controller.dispose();
    
    // Reset orientation and system UI when leaving the screen
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return YoutubePlayerBuilder(
      onEnterFullScreen: () {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      },
      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: const Color(0xFF6366F1),
        topActions: <Widget>[
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _controller.metadata.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 25.0,
            ),
            onPressed: () {
              // Settings can be handled here
            },
          ),
        ],
        onReady: () {
          _isPlayerReady = true;
        },
        onEnded: (data) {
          // Handle video end
        },
      ),
      builder: (context, player) => Scaffold(
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA),
        appBar: _isFullScreen ? null : AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Watch Video',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.share,
                color: isDark ? Colors.white : Colors.black87,
              ),
              onPressed: () {
                // Share functionality
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Video Player
            player,
            
            if (!_isFullScreen) ...[
              // Video Information
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        widget.video.title,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                          height: 1.3,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Video Stats
                      Row(
                        children: [
                          if (_videoDetails?.formattedViewCount != null) ...[
                            Text(
                              _videoDetails!.formattedViewCount,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white54 : Colors.black54,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            timeago.format(widget.video.publishedAt),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          if (_videoDetails?.formattedDuration != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white54 : Colors.black54,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _videoDetails!.formattedDuration,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Channel Info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                ),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.video.channelTitle,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Educational Content Creator',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: isDark ? Colors.white54 : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description
                      if (widget.video.description.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Description',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.video.description,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    // Add to favorites or playlist
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Added to favorites!'),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.favorite_border,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Add to Favorites',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  // Share functionality
                                },
                                child: Icon(
                                  Icons.share,
                                  color: isDark ? Colors.white : Colors.black87,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
