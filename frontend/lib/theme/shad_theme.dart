import 'package:flutter/material.dart';
import 'design_tokens.dart';
import 'event_type_colors.dart';

/// A lightweight shadcn-inspired design system for Flutter.
/// Focus: neutral surfaces, subtle borders, consistent radius, semantic colors.
class ShadTheme {
  static const double radius = 14;
  static const double gutter = 20; // base horizontal spacing
  static const double maxContentWidth = 1100; // shell constraint for large screens

  // Palette with neutral base + accent colors (light: orange, dark: light blue)
  static const Color _black = Color(0xFF000000);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _grayLight = Color(0xFFE6E6E6);
  static const Color _grayMid = Color(0xFFB3B3B3);
  static const Color _grayDark = Color(0xFF262626);
  static const Color _accentLight = Color(0xFFFC6A03); // Modern orange accent
  static const Color _accentDark = Color(0xFF2196F3);  // Modern blue accent

  static ThemeData light() {
    final base = ThemeData(useMaterial3: true, fontFamily: 'Roboto');
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
  primary: _accentLight,
  onPrimary: _white,
  secondary: _black,
  onSecondary: _white,
    error: Colors.red.shade700,
    onError: _white,
    surface: Color(0xFFF7F7FA),
    onSurface: Color(0xFF222222),
    surfaceContainerHighest: Color(0xFFEDEDED),
    onSurfaceVariant: Color(0xFF444444),
    outline: Color(0xFFCCCCCC),
    shadow: Colors.black.withOpacity(.18),
    tertiary: Color(0xFFB3B3B3),
    onTertiary: _black,
    inversePrimary: _white,
    inverseSurface: _black,
    tertiaryContainer: Color(0xFFF2F2F2),
    onTertiaryContainer: _black,
    primaryContainer: _accentLight,
    onPrimaryContainer: _white,
    secondaryContainer: Color(0xFFF2F2F2),
    onSecondaryContainer: _black,
    errorContainer: Colors.red.shade50,
    onErrorContainer: Colors.red.shade900,
    scrim: Colors.black38,
    );
    return base.copyWith(
      colorScheme: colorScheme,
      splashColor: _accentLight.withOpacity(.10),
      highlightColor: _accentLight.withOpacity(.05),
      scaffoldBackgroundColor: const Color(0xFFF9F9F9),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        selectedColor: colorScheme.primary.withOpacity(.15),
        side: BorderSide(color: colorScheme.outline.withOpacity(.6)),
        labelStyle: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        backgroundColor: colorScheme.surface,
        brightness: Brightness.light,
        secondarySelectedColor: colorScheme.primary.withOpacity(.25),
        disabledColor: colorScheme.surfaceContainerHighest,
      ),
      extensions: const [
        SemanticColors(
          info: _black,
          success: _black,
          warning: _black,
          danger: _black,
          borderSubtle: _grayLight,
          borderStrong: _grayDark,
          badgeBg: _grayLight,
        ),
        EventTypeColors(colors: {
          // Provide a starter palette for well-known slugs (can grow via future config):
          'conference': Color(0xFF2563EB),
          'workshop': Color(0xFF7C3AED),
          'meetup': Color(0xFF059669),
          'webinar': Color(0xFFDC2626),
        })
      ],
      textTheme: base.textTheme.copyWith(
        headlineMedium: base.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.5),
        titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.3, color: colorScheme.onSurface),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -.3,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
      cardTheme: CardThemeData(
        color: _white,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: _grayLight),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: false,
        filled: true,
        fillColor: _white.withOpacity(.94),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppTokens.space4, vertical: AppTokens.space3 + 2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: _grayLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: _grayLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: colorScheme.primary, width: 2.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: colorScheme.error, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: colorScheme.error, width: 2.2),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(.72)),
        floatingLabelStyle: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600),
        hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(.46)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          foregroundColor: colorScheme.secondary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white.withOpacity(.92),
        elevation: 0,
        selectedItemColor: _accentLight,
        unselectedItemColor: colorScheme.onSurfaceVariant.withOpacity(.65),
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: DividerThemeData(
        color: _grayLight,
        thickness: 1,
        space: 24,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: _white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  static ThemeData dark() {
  final base = ThemeData.dark(useMaterial3: true);
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
  primary: _accentDark,
  onPrimary: _black,
  secondary: _white,
  onSecondary: _black,
      error: Colors.red.shade400,
      onError: _black,
      surface: const Color(0xFF0F0F0F),
      onSurface: _white,
      surfaceContainerHighest: const Color(0xFF1A1A1A),
      onSurfaceVariant: _grayMid,
      outline: Colors.white12,
      shadow: Colors.black,
      tertiary: _grayMid,
      onTertiary: _black,
      inversePrimary: _black,
      inverseSurface: _white,
      tertiaryContainer: const Color(0xFF222222),
      onTertiaryContainer: _white,
  primaryContainer: const Color(0xFF1D1D1D),
  onPrimaryContainer: _accentDark,
      secondaryContainer: _grayDark,
      onSecondaryContainer: _white,
      errorContainer: Color(0xFF3B0000),
      onErrorContainer: _white,
      scrim: Colors.black54,
    );
    return base.copyWith(
      colorScheme: colorScheme,
      splashColor: _accentDark.withOpacity(.10),
      highlightColor: _accentDark.withOpacity(.05),
      scaffoldBackgroundColor: const Color(0xFF101010),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        selectedColor: colorScheme.primary.withOpacity(.25),
        side: BorderSide(color: Colors.white.withOpacity(.12)),
        labelStyle: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        backgroundColor: const Color(0xFF1E1E1E),
        brightness: Brightness.dark,
        secondarySelectedColor: colorScheme.primary.withOpacity(.35),
        disabledColor: const Color(0xFF222222),
      ),
      textTheme: base.textTheme.copyWith(
        headlineMedium: base.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.5),
        titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.3),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -.3,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF161616).withOpacity(.94),
        elevation: 0,
        selectedItemColor: _accentDark,
        unselectedItemColor: colorScheme.onSurfaceVariant.withOpacity(.65),
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1A1A),
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: Colors.white.withOpacity(.07)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E).withOpacity(.97),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppTokens.space4, vertical: AppTokens.space3 + 2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: Colors.white.withOpacity(.08), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: Colors.white.withOpacity(.10), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: colorScheme.primary, width: 2.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: colorScheme.error, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: colorScheme.error, width: 2.2),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(.72)),
        floatingLabelStyle: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600),
        hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(.46)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius - 4)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      // extensions already supplied above in both light/dark; keep existing ones implicit
    );
  }
}

// (Removed gradient extension placeholder; can be reintroduced when gradient usage is added in widgets.)

class ShadCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  const ShadCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap, this.color});
  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(ShadTheme.radius),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(.4)),
      ),
      padding: padding,
      child: child,
    );
    if(onTap!=null) {
      return InkWell(
        borderRadius: BorderRadius.circular(ShadTheme.radius),
        onTap: onTap,
        child: card,
      );
    }
    return card;
  }
}

/// A responsive application shell providing max-width constraint, side padding,
/// and optional sidebar/header slots to mimic shadcn/ui layout structure.
class ShadShell extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? sidebar; // rendered on large widths
  final Widget? bottomBar;
  final Color? background;
  final EdgeInsetsGeometry? padding;
  const ShadShell({super.key, required this.body, this.appBar, this.sidebar, this.bottomBar, this.background, this.padding});
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final showSidebar = sidebar!=null && width >= 1000;
    final content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: ShadTheme.maxContentWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.symmetric(horizontal: width < 600? 16 : 32, vertical: 16),
          child: body,
        ),
      ),
    );
    final hideBottom = showSidebar; // if sidebar shown (wide screen) hide bottom bar
    return Scaffold(
      backgroundColor: background ?? Theme.of(context).colorScheme.surface,
      appBar: appBar,
      bottomNavigationBar: hideBottom? null : bottomBar,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(showSidebar) SizedBox(width: 240, child: sidebar),
          Expanded(child: content),
        ],
      ),
    );
  }
}
