import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';

class ModernBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ModernBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<ModernBottomNav> createState() => _ModernBottomNavState();
}

class _ModernBottomNavState extends State<ModernBottomNav>
    with TickerProviderStateMixin {
  late AnimationController _selectedController;
  late AnimationController _rippleController;
  late Animation<double> _selectedAnimation;
  late Animation<double> _rippleAnimation;
  late List<AnimationController> _iconControllers;
  late List<Animation<double>> _iconAnimations;

  @override
  void initState() {
    super.initState();
    
    _selectedController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _selectedAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _selectedController, curve: Curves.elasticOut),
    );
    
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOutCirc),
    );

    _iconControllers = List.generate(4, (index) => AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    ));
    
    _iconAnimations = _iconControllers.map((controller) => 
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.bounceOut),
      ),
    ).toList();

    _selectedController.forward();
    _iconControllers[widget.currentIndex].forward();
  }

  @override
  void didUpdateWidget(ModernBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _iconControllers[oldWidget.currentIndex].reverse();
      _iconControllers[widget.currentIndex].forward();
      _rippleController.forward().then((_) => _rippleController.reset());
    }
  }

  @override
  void dispose() {
    _selectedController.dispose();
    _rippleController.dispose();
    for (var controller in _iconControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      height: 100,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      child: Stack(
        children: [
          // Main curved container
          CustomPaint(
            size: Size(math.max(0, MediaQuery.of(context).size.width - 40), 100),
            painter: CurvedBottomNavPainter(
              selectedIndex: widget.currentIndex,
              isDark: isDark,
              animation: _selectedAnimation,
              rippleAnimation: _rippleAnimation,
            ),
          ),
          // Navigation items
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(Icons.home_rounded, 'Home', 0, isDark),
                _buildNavItem(Icons.menu_book_rounded, 'Papers', 1, isDark),
                _buildNavItem(Icons.school_rounded, 'Mentor', 2, isDark),
                _buildNavItem(Icons.account_circle_rounded, 'Profile', 3, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, bool isDark) {
    final isSelected = widget.currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        child: Container(
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              AnimatedBuilder(
                animation: _iconAnimations[index],
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, isSelected ? -8 : 0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isSelected ? 56 : 48,
                      height: isSelected ? 56 : 48,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF2E5BBA), // Educational Blue (Primary)
                                  const Color(0xFF1565C0), // Darker Educational Blue
                                  const Color(0xFF7B68EE), // Medium Slate Blue (Educational Purple)
                                ],
                              )
                            : null,
                        color: isSelected ? null : Colors.transparent,
                        shape: BoxShape.circle,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF2E5BBA).withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: const Color(0xFF7B68EE).withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Transform.scale(
                        scale: 1.0 + (_iconAnimations[index].value * 0.1),
                        child: Icon(
                          icon,
                          size: isSelected ? 28 : 24,
                          color: isSelected 
                              ? Colors.white 
                              : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: GoogleFonts.poppins(
                  fontSize: isSelected ? 12 : 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected 
                      ? const Color(0xFF2E5BBA)
                      : (isDark ? Colors.grey[500] : Colors.grey[600]),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CurvedBottomNavPainter extends CustomPainter {
  final int selectedIndex;
  final bool isDark;
  final Animation<double> animation;
  final Animation<double> rippleAnimation;

  CurvedBottomNavPainter({
    required this.selectedIndex,
    required this.isDark,
    required this.animation,
    required this.rippleAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark 
            ? [
                const Color(0xFF1E1E1E),
                const Color(0xFF2D2D2D),
                const Color(0xFF1A1A1A),
              ]
            : [
                Colors.white,
                const Color(0xFFF8F9FF), // Very light blue tint
                const Color(0xFFF1F3FF), // Educational light blue background
              ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final shadowPaint = Paint()
      ..color = isDark 
          ? Colors.black.withOpacity(0.4)
          : const Color(0xFF2E5BBA).withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    // Draw shadow
    final shadowPath = _createCurvedPath(size, 2);
    canvas.drawPath(shadowPath, shadowPaint);

    // Draw main curved background
    final path = _createCurvedPath(size, 0);
    canvas.drawPath(path, paint);

    // Draw border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF2E5BBA).withOpacity(0.3),
          const Color(0xFF1565C0).withOpacity(0.2),
          const Color(0xFF7B68EE).withOpacity(0.2),
          const Color(0xFF2E5BBA).withOpacity(0.3),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawPath(path, borderPaint);

    // Draw ripple effect
    if (rippleAnimation.value > 0) {
      final ripplePaint = Paint()
        ..color = const Color(0xFF2E5BBA).withOpacity(0.1 * (1 - rippleAnimation.value))
        ..style = PaintingStyle.fill;
      
      final itemWidth = size.width / 4;
      final centerX = (selectedIndex * itemWidth) + (itemWidth / 2);
      final radius = 30 * rippleAnimation.value;
      
      canvas.drawCircle(Offset(centerX, 40), radius, ripplePaint);
    }

    // Draw educational pattern overlay
    _drawEducationalPattern(canvas, size);
  }

  Path _createCurvedPath(Size size, double offset) {
    final path = Path();
    final itemWidth = size.width / 4;
    final curveHeight = 25.0;
    final curveWidth = 60.0;
    
    // Start from top-left with rounded corner
    path.moveTo(20 + offset, 20 + offset);
    
    // Top edge with curve for selected item
    for (int i = 0; i < 4; i++) {
      final startX = i * itemWidth + offset;
      final endX = (i + 1) * itemWidth + offset;
      final centerX = startX + (itemWidth / 2);
      
      if (i == selectedIndex) {
        // Create upward curve for selected item
        path.lineTo(centerX - curveWidth / 2, 20 + offset);
        path.quadraticBezierTo(
          centerX, 20 - curveHeight + offset,
          centerX + curveWidth / 2, 20 + offset,
        );
      } else {
        path.lineTo(endX, 20 + offset);
      }
    }
    
    // Top-right rounded corner
    path.lineTo(size.width - 20 + offset, 20 + offset);
    path.quadraticBezierTo(
      size.width + offset, 20 + offset,
      size.width + offset, 40 + offset,
    );
    
    // Right edge
    path.lineTo(size.width + offset, size.height - 20 + offset);
    
    // Bottom-right rounded corner
    path.quadraticBezierTo(
      size.width + offset, size.height + offset,
      size.width - 20 + offset, size.height + offset,
    );
    
    // Bottom edge
    path.lineTo(20 + offset, size.height + offset);
    
    // Bottom-left rounded corner
    path.quadraticBezierTo(
      0 + offset, size.height + offset,
      0 + offset, size.height - 20 + offset,
    );
    
    // Left edge
    path.lineTo(0 + offset, 40 + offset);
    
    // Top-left rounded corner
    path.quadraticBezierTo(
      0 + offset, 20 + offset,
      20 + offset, 20 + offset,
    );
    
    path.close();
    return path;
  }

  void _drawEducationalPattern(Canvas canvas, Size size) {
    final patternPaint = Paint()
      ..color = const Color(0xFF2E5BBA).withOpacity(0.08)
      ..style = PaintingStyle.fill;

    // Draw subtle educational icons pattern
    for (int i = 0; i < 3; i++) {
      final x = (size.width / 4) * (i + 0.5);
      final y = size.height - 15;
      
      // Draw small dots pattern
      canvas.drawCircle(Offset(x, y), 2, patternPaint);
      canvas.drawCircle(Offset(x - 8, y), 1, patternPaint);
      canvas.drawCircle(Offset(x + 8, y), 1, patternPaint);
    }
  }

  @override
  bool shouldRepaint(CurvedBottomNavPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
           oldDelegate.animation.value != animation.value ||
           oldDelegate.rippleAnimation.value != rippleAnimation.value;
  }
}
