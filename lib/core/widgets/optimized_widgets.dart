import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Optimized widgets to prevent UI blocking and improve performance
class OptimizedWidgets {
  /// Optimized container with RepaintBoundary for expensive widgets
  static Widget optimizedContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Decoration? decoration,
    double? width,
    double? height,
    AlignmentGeometry? alignment,
    bool useRepaintBoundary = true,
  }) {
    Widget container = Container(
      padding: padding,
      margin: margin,
      decoration: decoration,
      width: width,
      height: height,
      alignment: alignment,
      child: child,
    );

    return useRepaintBoundary ? RepaintBoundary(child: container) : container;
  }

  /// Optimized card widget with const constructor where possible
  static Widget optimizedCard({
    required Widget child,
    EdgeInsetsGeometry? margin,
    double? elevation,
    Color? color,
    ShapeBorder? shape,
    bool useRepaintBoundary = true,
  }) {
    Widget card = Card(
      margin: margin,
      elevation: elevation,
      color: color,
      shape: shape,
      child: child,
    );

    return useRepaintBoundary ? RepaintBoundary(child: card) : card;
  }

  /// Optimized list tile with performance considerations
  static Widget optimizedListTile({
    Widget? leading,
    Widget? title,
    Widget? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool useRepaintBoundary = true,
  }) {
    Widget listTile = ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
    );

    return useRepaintBoundary ? RepaintBoundary(child: listTile) : listTile;
  }

  /// Optimized image widget with caching and error handling
  static Widget optimizedImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit? fit,
    Widget? placeholder,
    Widget? errorWidget,
    bool useRepaintBoundary = true,
  }) {
    Widget image = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? const Icon(Icons.error);
      },
    );

    return useRepaintBoundary ? RepaintBoundary(child: image) : image;
  }

  /// Optimized text widget with const constructor
  static Widget optimizedText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool useRepaintBoundary = false,
  }) {
    Widget textWidget = Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );

    return useRepaintBoundary ? RepaintBoundary(child: textWidget) : textWidget;
  }

  /// Optimized animated container that doesn't rebuild unnecessarily
  static Widget optimizedAnimatedContainer({
    required Widget child,
    required Duration duration,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Decoration? decoration,
    Curve curve = Curves.linear,
    bool useRepaintBoundary = true,
  }) {
    Widget animatedContainer = AnimatedContainer(
      duration: duration,
      curve: curve,
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: decoration,
      child: child,
    );

    return useRepaintBoundary ? RepaintBoundary(child: animatedContainer) : animatedContainer;
  }

  /// Optimized builder for expensive widgets
  static Widget optimizedBuilder({
    required Widget Function(BuildContext) builder,
    bool useRepaintBoundary = true,
  }) {
    return Builder(
      builder: (context) {
        Widget child = builder(context);
        return useRepaintBoundary ? RepaintBoundary(child: child) : child;
      },
    );
  }

  /// Optimized grid view for large datasets
  static Widget optimizedGridView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    required SliverGridDelegate gridDelegate,
    ScrollController? controller,
    EdgeInsetsGeometry? padding,
    bool shrinkWrap = false,
  }) {
    return GridView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      gridDelegate: gridDelegate,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: itemBuilder(context, index),
        );
      },
    );
  }

  /// Optimized list view for large datasets
  static Widget optimizedListView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    ScrollController? controller,
    EdgeInsetsGeometry? padding,
    bool shrinkWrap = false,
    Widget? separator,
  }) {
    if (separator != null) {
      return ListView.separated(
        controller: controller,
        padding: padding,
        shrinkWrap: shrinkWrap,
        itemCount: itemCount,
        separatorBuilder: (context, index) => separator,
        itemBuilder: (context, index) {
          return RepaintBoundary(
            child: itemBuilder(context, index),
          );
        },
      );
    }

    return ListView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: itemBuilder(context, index),
        );
      },
    );
  }

  /// Optimized future builder that handles loading states properly
  static Widget optimizedFutureBuilder<T>({
    required Future<T> future,
    required Widget Function(BuildContext, T) builder,
    Widget? loadingWidget,
    Widget Function(BuildContext, Object?)? errorBuilder,
  }) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ?? const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return errorBuilder?.call(context, snapshot.error) ?? 
                 Center(child: Text('Error: ${snapshot.error}'));
        }
        
        if (snapshot.hasData) {
          return RepaintBoundary(
            child: builder(context, snapshot.data!),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  /// Optimized stream builder for real-time data
  static Widget optimizedStreamBuilder<T>({
    required Stream<T> stream,
    required Widget Function(BuildContext, T) builder,
    Widget? loadingWidget,
    Widget Function(BuildContext, Object?)? errorBuilder,
    T? initialData,
  }) {
    return StreamBuilder<T>(
      stream: stream,
      initialData: initialData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return loadingWidget ?? const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return errorBuilder?.call(context, snapshot.error) ?? 
                 Center(child: Text('Error: ${snapshot.error}'));
        }
        
        if (snapshot.hasData) {
          return RepaintBoundary(
            child: builder(context, snapshot.data!),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }
}

/// Mixin for widgets that need performance optimization
mixin PerformanceOptimizedWidget on Widget {
  /// Override this to add RepaintBoundary automatically
  Widget buildOptimized(BuildContext context);

  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: buildOptimized(context),
    );
  }
}

/// Const widgets for better performance
class ConstWidgets {
  static const Widget loadingIndicator = Center(
    child: CircularProgressIndicator(),
  );

  static const Widget errorIcon = Icon(
    Icons.error,
    color: Colors.red,
  );

  static const Widget emptyBox = SizedBox.shrink();

  static const Widget verticalSpacing8 = SizedBox(height: 8);
  static const Widget verticalSpacing16 = SizedBox(height: 16);
  static const Widget verticalSpacing24 = SizedBox(height: 24);

  static const Widget horizontalSpacing8 = SizedBox(width: 8);
  static const Widget horizontalSpacing16 = SizedBox(width: 16);
  static const Widget horizontalSpacing24 = SizedBox(width: 24);

  static Widget divider({double height = 1, Color? color}) {
    return Divider(height: height, color: color);
  }

  static Widget spacer({int flex = 1}) {
    return Spacer(flex: flex);
  }
}
