import 'package:flutter/material.dart';

class SuccessPopup {
  static void show(BuildContext context, {
    required String title,
    required String message,
    String? userName,
    VoidCallback? onComplete,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _SuccessPopupWidget(
          title: title,
          message: message,
          userName: userName,
          onComplete: onComplete,
        );
      },
    );
  }
}

class _SuccessPopupWidget extends StatefulWidget {
  final String title;
  final String message;
  final String? userName;
  final VoidCallback? onComplete;

  const _SuccessPopupWidget({
    required this.title,
    required this.message,
    this.userName,
    this.onComplete,
  });

  @override
  State<_SuccessPopupWidget> createState() => _SuccessPopupWidgetState();
}

class _SuccessPopupWidgetState extends State<_SuccessPopupWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeInOut,
    );

    // Start animations
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _checkController.forward();
    });

    // Auto dismiss after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pop();
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon with Animation
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: AnimatedBuilder(
                  animation: _checkAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _checkAnimation.value,
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3A59),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Welcome message with user name
              if (widget.userName != null) ...[
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(text: 'Welcome back, '),
                      TextSpan(
                        text: widget.userName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF667eea),
                        ),
                      ),
                      const TextSpan(text: '! 🎉'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              
              // Message
              Text(
                widget.message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Loading indicator
              Container(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFF667eea).withOpacity(0.7),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'Taking you to your dashboard...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
