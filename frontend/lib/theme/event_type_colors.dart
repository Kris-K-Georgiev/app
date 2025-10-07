import 'package:flutter/material.dart';

/// Theme extension that can optionally supply explicit colors for certain
/// event type slugs coming from the backend taxonomy. If a slug is not
/// present in the [colors] map, the UI should fall back to:
/// 1) Provided event_type.color hex (if backend sends one)
/// 2) Deterministic hash-based color derived from the slug & scheme
/// The hash approach keeps colors stable between sessions without
/// persisting extra state.
class EventTypeColors extends ThemeExtension<EventTypeColors> {
  final Map<String, Color> colors; // slug -> color
  const EventTypeColors({this.colors = const {}});

  Color? operator [](String slug) => colors[slug];

  @override
  ThemeExtension<EventTypeColors> copyWith({Map<String, Color>? colors}) =>
      EventTypeColors(colors: colors ?? this.colors);

  @override
  ThemeExtension<EventTypeColors> lerp(ThemeExtension<EventTypeColors>? other, double t) {
    if (other is! EventTypeColors) return this;
    // Naive merge (no animation need) – just choose this or other based on t
    if (t < 0.5) {
      return this;
    } else {
      return other;
    }
  }

  static Color hashColor(String slug, ColorScheme scheme) {
    final palette = [
      scheme.primary,
      scheme.secondaryContainer,
      scheme.tertiary,
      scheme.primaryContainer,
      scheme.onTertiaryContainer,
      scheme.onSecondaryContainer,
    ];
    int h = 0;
    for (final c in slug.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return palette[h % palette.length];
  }

  static Color? parseBackendHex(String? hex) {
    if (hex == null || hex.trim().isEmpty) return null;
    var value = hex.trim();
    if (!value.startsWith('#')) value = '#$value';
    try {
      final cleaned = value.substring(1);
      if (cleaned.length == 6) {
        final intVal = int.parse(cleaned, radix: 16);
        return Color(0xFF000000 | intVal);
      } else if (cleaned.length == 8) {
        final intVal = int.parse(cleaned, radix: 16);
        return Color(intVal);
      }
    } catch (_) {}
    return null;
  }

  /// Resolve a color for given slug + optional backend hex using current theme.
  static Color resolve(BuildContext context, {required String slug, String? backendHex}) {
    final scheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<EventTypeColors>();
    final direct = ext?.colors[slug];
    if (direct != null) return direct;
    final parsed = parseBackendHex(backendHex);
    if (parsed != null) return parsed;
    return hashColor(slug, scheme);
  }
}
