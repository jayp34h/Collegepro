import 'package:flutter/material.dart';
import 'drawer_screen_wrapper.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData titleIcon;
  final VoidCallback? onSearchPressed;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? additionalActions;

  const GradientAppBar({
    super.key,
    required this.title,
    required this.titleIcon,
    this.onSearchPressed,
    this.showBackButton = true,
    this.onBackPressed,
    this.additionalActions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: showBackButton
          ? Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: onBackPressed ?? () => DrawerScreenWrapper.openDrawer(context),
              ),
            )
          : null,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              titleIcon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        if (onSearchPressed != null)
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 22,
              ),
              onPressed: onSearchPressed,
            ),
          ),
        if (additionalActions != null) ...additionalActions!,
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2E5BBA), // Blue
              Color(0xFF6B46C1), // Purple
            ],
            stops: [0.0, 1.0],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
