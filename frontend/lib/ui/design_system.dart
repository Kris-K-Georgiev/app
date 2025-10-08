import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/design_tokens.dart';
import '../theme/shad_theme.dart';
import '../theme/design_tokens.dart';
import 'typography.dart';
import 'typography_scale.dart';
import 'package:provider/provider.dart';
import '../providers/preferences_provider.dart';

/// Lightweight in‑app design system layer mapping the provided UI kit
/// (screenshots) to Flutter widgets while keeping existing color palette.
/// Only structural / spacing / states are defined here; colors come from
/// the current Theme / ColorScheme so palette stays intact.

// ============================= Core tokens ============================= //

enum DsButtonVariant { primary, secondary, tertiary }
enum DsTone { info, success, warning, danger }
enum AvatarSize { small, medium, large }

class DsSpacing { // semantic gaps
  static const double xs = AppTokens.space1;
  static const double sm = AppTokens.space2;
  static const double md = AppTokens.space3;
  static const double lg = AppTokens.space5;
  static const double xl = AppTokens.space8;
}

// ============================= Buttons ============================= //

class DsButton extends StatefulWidget {
  final DsButtonVariant variant; final VoidCallback? onPressed; final Widget child; final bool expanded; final Widget? leading; final Widget? trailing; final EdgeInsets? padding; final double? height; final bool busy;
  const DsButton.primary({super.key, required this.onPressed, required this.child, this.leading, this.trailing, this.expanded=false, this.padding, this.height, this.busy=false}) : variant = DsButtonVariant.primary;
  const DsButton.secondary({super.key, required this.onPressed, required this.child, this.leading, this.trailing, this.expanded=false, this.padding, this.height, this.busy=false}) : variant = DsButtonVariant.secondary;
  const DsButton.tertiary({super.key, required this.onPressed, required this.child, this.leading, this.trailing, this.expanded=false, this.padding, this.height, this.busy=false}) : variant = DsButtonVariant.tertiary;
  @override State<DsButton> createState()=> _DsButtonState(); }
class _DsButtonState extends State<DsButton>{ bool _hover=false; bool _pressed=false; bool _focus=false; @override Widget build(BuildContext context){ final cs = Theme.of(context).colorScheme; final acc = Theme.of(context).extension<AccessibilityColors>(); final ringColor = acc?.focusRing ?? cs.primary; final radius = BorderRadius.circular(12); Color bg; Color fg; BoxBorder? border; Color hoverLayer=Colors.transparent; Color pressLayer=Colors.transparent; switch(widget.variant){ case DsButtonVariant.primary: bg = cs.primary; fg = cs.onPrimary; hoverLayer = cs.onPrimary.withOpacity(.08); pressLayer = cs.onPrimary.withOpacity(.18); break; case DsButtonVariant.secondary: bg = cs.surface; fg = cs.onSurface; border = Border.all(color: cs.outline.withOpacity(.6)); hoverLayer = cs.primary.withOpacity(.05); pressLayer = cs.primary.withOpacity(.10); break; case DsButtonVariant.tertiary: bg = Colors.transparent; fg = cs.primary; hoverLayer = cs.primary.withOpacity(.08); pressLayer = cs.primary.withOpacity(.14); break; } final overlayColor = _pressed? pressLayer : _hover? hoverLayer : Colors.transparent; final focusRing = _focus? BoxDecoration(borderRadius: radius, boxShadow:[BoxShadow(color: ringColor.withOpacity(.65), blurRadius: 0, spreadRadius: 2.2)]) : null; final inner = AnimatedContainer(duration: AppTokens.fast, height: widget.height ?? 48, padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 20), decoration: BoxDecoration(color: bg, borderRadius: radius, border: border), child: Stack(children:[ Center(child: Row(mainAxisSize: MainAxisSize.min, children:[ if(widget.leading!=null) ...[widget.leading!, const SizedBox(width:8)], AnimatedOpacity(duration: AppTokens.fast, opacity: widget.busy? .0 : 1, child: DefaultTextStyle.merge(style: DsTextStyles.actionL(context).copyWith(color: fg), child: widget.child)), if(widget.trailing!=null) ...[const SizedBox(width:8), widget.trailing!], if(widget.busy) SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: widget.variant==DsButtonVariant.tertiary? cs.primary : fg)), ])), AnimatedContainer(duration: AppTokens.fast, decoration: BoxDecoration(color: overlayColor, borderRadius: radius)) ])); final focusWrap = AnimatedContainer(duration: AppTokens.fast, decoration: focusRing, child: inner); final gesture = FocusableActionDetector(onShowFocusHighlight: (v)=> setState(()=> _focus=v), mouseCursor: SystemMouseCursors.click, child: MouseRegion(onEnter: (_)=> setState(()=> _hover=true), onExit: (_)=> setState(()=> _hover=false), child: GestureDetector(onTapDown: (_)=> setState(()=> _pressed=true), onTapCancel: (){ if(_pressed) setState(()=> _pressed=false); }, onTapUp: (_){ if(_pressed) setState(()=> _pressed=false); }, onTap: widget.busy? null : (){ final prefs = context.read<PreferencesProvider?>(); final level = prefs?.haptics ?? 2; if(level>0){ if(widget.variant==DsButtonVariant.primary && level==2) HapticFeedback.mediumImpact(); else HapticFeedback.selectionClick(); } widget.onPressed?.call(); }, child: focusWrap))); return widget.expanded? SizedBox(width: double.infinity, child: gesture) : gesture; } }

// ============================= Avatar ============================= //

class DsAvatar extends StatelessWidget {
  final AvatarSize size; final String? imageUrl; final IconData placeholderIcon; final String? semanticsLabel; final Color? tint;
  const DsAvatar({super.key, this.size=AvatarSize.medium, this.imageUrl, this.placeholderIcon=Icons.person, this.semanticsLabel, this.tint});
  @override
  Widget build(BuildContext context){
    final cs = Theme.of(context).colorScheme; final bg = (tint ?? cs.primary).withOpacity(.08);
    final double px; switch(size){ case AvatarSize.small: px=36; break; case AvatarSize.medium: px=52; break; case AvatarSize.large: px=72; break; }
    Widget child;
    if(imageUrl!=null && imageUrl!.isNotEmpty){
      child = ClipRRect(borderRadius: BorderRadius.circular(px), child: Image.network(imageUrl!, width: px, height: px, fit: BoxFit.cover));
    } else {
      child = Container(
        width: px, height: px,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(px)),
        child: Icon(placeholderIcon, size: px * .52, color: tint ?? cs.primary),
      );
    }
    return Semantics(label: semanticsLabel, child: child);
  }
}

// ============================= Tag ============================= //

class DsTag extends StatelessWidget {
  final String label; final bool filled; final Color? color; final IconData? icon; final EdgeInsets padding;
  const DsTag(this.label,{super.key, this.filled=false, this.color, this.icon, this.padding=const EdgeInsets.symmetric(horizontal:10, vertical:6)});
  @override
  Widget build(BuildContext context){ final cs = Theme.of(context).colorScheme; final bg = filled? (color?? cs.primary).withOpacity(.13) : cs.surface; final fg = filled? (color?? cs.primary) : cs.onSurface.withOpacity(.75); return Container(decoration: BoxDecoration(color: bg, border: Border.all(color: (color?? cs.outline).withOpacity(.5)), borderRadius: BorderRadius.circular(999)), padding: padding, child: Row(mainAxisSize: MainAxisSize.min, children:[ if(icon!=null)...[Icon(icon, size: 14, color: fg), const SizedBox(width:4)], Text(label, style: DsTextStyles.actionM(context).copyWith(color: fg)) ])); }
}

// ============================= Banner ============================= //

class DsBanner extends StatelessWidget { final DsTone tone; final String title; final String? description; final Widget? action; final IconData? icon; const DsBanner({super.key, required this.tone, required this.title, this.description, this.action, this.icon});
  Color _toneColor(BuildContext c){ final cs = Theme.of(c).colorScheme; switch(tone){ case DsTone.info: return cs.primary; case DsTone.success: return Colors.green; case DsTone.warning: return Colors.orange; case DsTone.danger: return Colors.red; } }
  @override Widget build(BuildContext context){ final toneColor = _toneColor(context); return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: toneColor.withOpacity(.06), borderRadius: BorderRadius.circular(16), border: Border.all(color: toneColor.withOpacity(.28))), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children:[ if(icon!=null)...[Icon(icon, color: toneColor), const SizedBox(width:12)], Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[ Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)), if(description!=null) Padding(padding: const EdgeInsets.only(top:4), child: Text(description!, style: Theme.of(context).textTheme.bodySmall)), if(action!=null) Padding(padding: const EdgeInsets.only(top:8), child: action!) ])) ])); }
}

// ============================= Toast ============================= //

enum ToastPosition { bottom, top }
enum ToastStackDirection { up, down }

/// Global toast configuration (externally adjustable)
class ToastConfig {
  static int maxVisible = 3; // maximum simultaneously visible toasts
  static Duration minGap = const Duration(milliseconds: 250); // rate limiting between spawns
  static Duration entranceDuration = const Duration(milliseconds: 300);
  static Duration exitDuration = const Duration(milliseconds: 220);
  static Duration reflowDuration = const Duration(milliseconds: 300);
  static Curve reflowCurve = Curves.easeOutCubic;
  static double verticalSpacing = 72; // approx toast height + gap
  static double edgePadding = 16; // distance from top/bottom edge
}

class DsToast {
  static final _entries = <OverlayEntry>[]; // active overlay entries
  static final _queue = <_ToastRequest>[];  // pending requests
  static DateTime _lastShown = DateTime.fromMillisecondsSinceEpoch(0);

  static void show(
    BuildContext context,
    String title, {
    DsTone tone = DsTone.info,
    String? description,
    Duration duration = const Duration(seconds: 3),
    ToastPosition position = ToastPosition.bottom,
    ToastStackDirection stackDirection = ToastStackDirection.up,
  }) {
    _queue.add(_ToastRequest(context, title, tone, description, duration, position, stackDirection));
    _tryProcess();
  }

  static void _tryProcess() {
    if (_queue.isEmpty) return;
    if (_entries.length >= ToastConfig.maxVisible) return;
    if (DateTime.now().difference(_lastShown) < ToastConfig.minGap) {
      Future.delayed(ToastConfig.minGap, _tryProcess);
      return;
    }
    final req = _queue.removeAt(0);
    _spawn(req);
  }

  static void _spawn(_ToastRequest req) {
    final overlay = Overlay.of(req.context, rootOverlay: true);
    if (overlay == null) return;
    final theme = Theme.of(req.context);
    final toastTheme = theme.extension<ToastTheme>();
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    Color base;
    switch (req.tone) {
      case DsTone.info:
        base = cs.primary;
        break;
      case DsTone.success:
        base = Colors.green;
        break;
      case DsTone.warning:
        base = Colors.orange;
        break;
      case DsTone.danger:
        base = Colors.red;
        break;
    }
    final bgOpacity = isDark ? .18 : .1;
    final borderOpacity = isDark ? .50 : .35;
    late OverlayEntry entry;
    entry = OverlayEntry(builder: (_) {
      final idx = _entries.indexOf(entry);
      return AnimatedPositionedToast(
        entry: entry,
        index: idx,
        position: req.position,
        direction: req.stackDirection,
        child: _ToastBody(
          base: base,
            title: req.title,
            description: req.description,
            onClosed: () {
              _entries.remove(entry);
              entry.remove();
              _reflow();
              _tryProcess();
            },
            duration: req.duration,
            bgOpacity: bgOpacity,
            borderOpacity: borderOpacity,
        ),
      );
    });
    _entries.add(entry);
    overlay.insert(entry);
    _lastShown = DateTime.now();
    // Adaptive haptic based on tone severity
    switch(req.tone){
      case DsTone.danger: HapticFeedback.heavyImpact(); break;
      case DsTone.warning: HapticFeedback.mediumImpact(); break;
      default: HapticFeedback.selectionClick();
    }
  }

  static void _reflow() {
    for (final e in _entries) {
      e.markNeedsBuild();
    }
  }
}

class _ToastRequest {
  final BuildContext context;
  final String title;
  final DsTone tone;
  final String? description;
  final Duration duration;
  final ToastPosition position;
  final ToastStackDirection stackDirection;
  _ToastRequest(this.context, this.title, this.tone, this.description, this.duration, this.position, this.stackDirection);
}

class AnimatedPositionedToast extends StatefulWidget {
  final Widget child;
  final int index;
  final OverlayEntry entry;
  final ToastPosition position;
  final ToastStackDirection direction;
  const AnimatedPositionedToast({super.key, required this.child, required this.index, required this.entry, required this.position, required this.direction});
  @override
  State<AnimatedPositionedToast> createState() => _AnimatedPositionedToastState();
}

class _AnimatedPositionedToastState extends State<AnimatedPositionedToast> {
  @override
  Widget build(BuildContext context) {
    final total = DsToast._entries.length;
    // Recompute offset every build for proper reflow (esp. for direction=down)
    double ordinal = widget.index.toDouble();
    if (widget.direction == ToastStackDirection.down) {
      ordinal = (total - 1 - widget.index).toDouble();
    }
  final toastTheme = Theme.of(context).extension<ToastTheme>();
  final vSpacing = toastTheme?.verticalSpacing ?? ToastConfig.verticalSpacing;
  final offset = ToastConfig.edgePadding + (ordinal * vSpacing);
    final bottom = widget.position == ToastPosition.bottom ? offset : null;
    final top = widget.position == ToastPosition.top ? offset : null;
    return AnimatedPositioned(
      duration: (toastTheme?.reflowDuration ?? ToastConfig.reflowDuration),
      curve: (toastTheme?.reflowCurve ?? ToastConfig.reflowCurve),
      left: 16,
      right: 16,
      bottom: bottom,
      top: top,
      child: widget.child,
    );
  }
}

class _ToastBody extends StatefulWidget {
  final Color base;
  final String title;
  final String? description;
  final VoidCallback onClosed;
  final Duration duration;
  final double bgOpacity;
  final double borderOpacity;
  const _ToastBody({super.key, required this.base, required this.title, this.description, required this.onClosed, required this.duration, required this.bgOpacity, required this.borderOpacity});
  @override
  State<_ToastBody> createState() => _ToastBodyState();
}

class _ToastBodyState extends State<_ToastBody> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  bool _closing = false;
  bool _paused = false;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    final toastTheme = Theme.of(context).extension<ToastTheme>();
    _c = AnimationController(
      vsync: this,
      duration: toastTheme?.entranceDuration ?? ToastConfig.entranceDuration,
      reverseDuration: toastTheme?.exitDuration ?? ToastConfig.exitDuration,
    );
    _c.forward();
    _remaining = widget.duration;
    _scheduleTimer();
    // Accessibility announce (screen readers)
    SemanticsService.announce(widget.title + (widget.description!=null? ': ' + widget.description! : ''), Directionality.of(context));
  }

  void _scheduleTimer(){
    if(_paused) return; Future.delayed(const Duration(milliseconds:200),(){
      if(!mounted || _paused || _closing) return; // prevented
      _remaining -= const Duration(milliseconds:200);
      if(_remaining <= Duration.zero){ _dismiss(); } else { _scheduleTimer(); }
    });
  }

  void _dismiss() {
    if (_closing) return;
    _closing = true;
    if (mounted) {
      _c.reverse().then((_) => widget.onClosed());
    }
    HapticFeedback.selectionClick();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final toastTheme = Theme.of(context).extension<ToastTheme>();
    final content = MouseRegion(
      onEnter: (_){ setState(()=> _paused=true); },
      onExit: (_){ setState(()=> _paused=false); _scheduleTimer(); },
      child: Material(
      elevation: 0,
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.base.withOpacity(widget.bgOpacity),
          borderRadius: BorderRadius.circular(toastTheme?.radius ?? 20),
          border: Border.all(width: toastTheme?.borderWidth ?? 1, color: widget.base.withOpacity(widget.borderOpacity)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(color: widget.base, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: DsTextStyles.actionL(context).copyWith(color: cs.onSurface)),
                  if (widget.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(widget.description!, style: DsTextStyles.bodyS(context)),
                    )
                ],
              ),
            ),
            InkWell(onTap: _dismiss, child: Icon(Icons.close, size: 18, color: cs.onSurface.withOpacity(.6)))
          ],
        ),
      ),
    ));
    double dragDy = 0;
    final verticalDrag = GestureDetector(
      onVerticalDragUpdate: (d){ setState(()=> dragDy += d.delta.dy); },
      onVerticalDragEnd: (d){
        final velocity = d.primaryVelocity ?? 0;
        if(velocity.abs()>350 || dragDy.abs()>40){ _dismiss(); }
        dragDy = 0;
      },
      child: content,
    );

    return Dismissible(
      key: ValueKey(hashCode),
      direction: DismissDirection.horizontal,
      onDismissed: (_){ if(!_closing){ _closing=true; widget.onClosed(); HapticFeedback.selectionClick(); } },
      child: FadeTransition(
        opacity: CurvedAnimation(parent: _c, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween(begin: const Offset(0, .15), end: Offset.zero).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut)),
          child: GestureDetector(onTap: _dismiss, child: verticalDrag),
        ),
      ),
    );
  }
}

// ============================= Form Field Wrapper (unified) ============================= //

class DsFormFieldWrapper extends StatelessWidget {
  final String? label; final Widget child; final String? helper; final String? error; final bool dense; final EdgeInsets? margin;
  const DsFormFieldWrapper({super.key, this.label, required this.child, this.helper, this.error, this.dense=false, this.margin});
  @override
  Widget build(BuildContext context){ final textTheme = Theme.of(context).textTheme; final colorScheme = Theme.of(context).colorScheme; final err = (error!=null && error!.isNotEmpty); return Padding(padding: margin ?? EdgeInsets.only(bottom: dense? AppTokens.space3 : AppTokens.space4), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[ if(label!=null) Padding(padding: const EdgeInsets.only(bottom:4), child: Text(label!, style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing:.3))), child, if(helper!=null && !err) Padding(padding: const EdgeInsets.only(top:4), child: Text(helper!, style: textTheme.bodySmall?.copyWith(fontSize:11, color: colorScheme.onSurface.withOpacity(.55)))), if(err) Padding(padding: const EdgeInsets.only(top:4), child: Text(error!, style: textTheme.bodySmall?.copyWith(fontSize:11, color: colorScheme.error))) ])); }
}

// ============================= Dialog helper ============================= //

Future<T?> dsDialog<T>({required BuildContext context, required String title, String? description, List<Widget>? actions, int maxButtonsPerRow=2}){
  final buttons = actions ?? [TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('Close'))];
  Widget actionLayout;
  if(buttons.length <= maxButtonsPerRow){
    actionLayout = Row(mainAxisAlignment: MainAxisAlignment.end, children: buttons.map((b)=> Padding(padding: const EdgeInsets.only(left:8), child: b)).toList());
  } else {
    actionLayout = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: buttons.map((b)=> Padding(padding: const EdgeInsets.only(top:8), child: b)).toList());
  }
  return showDialog<T>(context: context, builder: (_)=> AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), content: description!=null? Text(description): null, actions: [actionLayout]));
}

// ============================= Content Switcher (Segmented) ============================= //

class ContentSwitcher extends StatelessWidget { final List<String> segments; final int index; final ValueChanged<int> onChanged; const ContentSwitcher({super.key, required this.segments, required this.index, required this.onChanged});
  @override Widget build(BuildContext context){ final cs = Theme.of(context).colorScheme; return Container(decoration: BoxDecoration(color: cs.surface, border: Border.all(color: cs.outline.withOpacity(.5)), borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.all(4), child: Row(children:[ for(int i=0;i<segments.length;i++) Expanded(child: _Segment(label: segments[i], selected: i==index, onTap: ()=> onChanged(i))) ])); }
}
class _Segment extends StatelessWidget { final String label; final bool selected; final VoidCallback onTap; const _Segment({required this.label, required this.selected, required this.onTap}); @override Widget build(BuildContext context){ final cs = Theme.of(context).colorScheme; return AnimatedContainer(duration: AppTokens.fast, curve: Curves.easeOut, decoration: BoxDecoration(color: selected? cs.primary : Colors.transparent, borderRadius: BorderRadius.circular(10)), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(10), child: Padding(padding: const EdgeInsets.symmetric(vertical:10), child: Center(child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: selected? cs.onPrimary : cs.onSurface.withOpacity(.75))))))); }
}

// ============================= Tabs ============================= //

class DsTabBar extends StatelessWidget implements PreferredSizeWidget { final TabController controller; final List<String> tabs; const DsTabBar({super.key, required this.controller, required this.tabs}); @override Size get preferredSize => const Size.fromHeight(48); @override Widget build(BuildContext context){ final cs = Theme.of(context).colorScheme; return TabBar(controller: controller, labelColor: cs.onSurface, unselectedLabelColor: cs.onSurfaceVariant, indicator: UnderlineTabIndicator(borderSide: BorderSide(color: cs.primary, width: 3), insets: const EdgeInsets.symmetric(horizontal:12)), tabs: [for(final t in tabs) Tab(child: Align(alignment: Alignment.centerLeft, child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600))))]); } }

// ============================= Filter Button ============================= //

class DsFilterButton extends StatefulWidget { final bool active; final VoidCallback? onTap; final String label; const DsFilterButton({super.key, required this.label, this.active=false, this.onTap}); @override State<DsFilterButton> createState()=> _DsFilterButtonState(); }
class _DsFilterButtonState extends State<DsFilterButton>{ bool _hover=false; bool _focus=false; @override Widget build(BuildContext context){ final cs = Theme.of(context).colorScheme; final acc = Theme.of(context).extension<AccessibilityColors>(); final ringColor = acc?.focusRing ?? cs.primary; final baseBorder = widget.active? cs.primary : cs.outline.withOpacity(.6); final bg = widget.active? cs.primary : cs.surface; final fg = widget.active? cs.onPrimary : cs.onSurface; final ringShadow = _focus? [BoxShadow(color: ringColor.withOpacity(.65), blurRadius: 0, spreadRadius: 2.2)] : null; return FocusableActionDetector(onShowFocusHighlight: (v)=> setState(()=> _focus=v), mouseCursor: SystemMouseCursors.click, child: MouseRegion(onEnter: (_)=> setState(()=> _hover=true), onExit: (_)=> setState(()=> _hover=false), child: InkWell(onTap: widget.onTap, borderRadius: BorderRadius.circular(999), child: AnimatedContainer(duration: AppTokens.fast, padding: const EdgeInsets.symmetric(horizontal:14, vertical:8), decoration: BoxDecoration(color: _hover && !widget.active? cs.primary.withOpacity(.05) : bg, borderRadius: BorderRadius.circular(999), border: Border.all(color: baseBorder), boxShadow: ringShadow), child: Row(mainAxisSize: MainAxisSize.min, children:[ Icon(Icons.filter_list, size:14, color: widget.active? cs.onPrimary : cs.primary), const SizedBox(width:6), Text(widget.label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: fg)) ])))); } }

// ============================= Toggle (wrapper) ============================= //

class DsToggle extends StatelessWidget { final bool value; final ValueChanged<bool>? onChanged; const DsToggle({super.key, required this.value, this.onChanged}); @override Widget build(BuildContext context){ return Switch(value: value, onChanged: onChanged); } }

// ============================= Progress Bar / Loader ============================= //

class DsProgressBar extends StatelessWidget { final double progress; const DsProgressBar({super.key, required this.progress}); @override Widget build(BuildContext context){ final cs = Theme.of(context).colorScheme; return Container(height: 6, decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(6)), child: FractionallySizedBox(widthFactor: progress.clamp(0,1), alignment: Alignment.centerLeft, child: Container(decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(6))))); } }

class DsLoader extends StatelessWidget { final double size; const DsLoader({super.key, this.size=40}); @override Widget build(BuildContext context){ final cs = Theme.of(context).colorScheme; return SizedBox(width:size, height:size, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation(cs.primary))); } }

// ============================= Pagination Dots ============================= //

class DsPaginationDots extends StatelessWidget { final int count; final int index; const DsPaginationDots({super.key, required this.count, required this.index}); @override Widget build(BuildContext context){ final cs = Theme.of(context).colorScheme; return Row(mainAxisSize: MainAxisSize.min, children:[ for(int i=0;i<count;i++) AnimatedContainer(duration: AppTokens.fast, margin: const EdgeInsets.symmetric(horizontal:4), width: 8, height: 8, decoration: BoxDecoration(color: i==index? cs.primary : cs.outline.withOpacity(.4), borderRadius: BorderRadius.circular(6))) ]); } }

// ============================= Accordion ============================= //

class DsAccordion extends StatefulWidget { final String title; final Widget child; final bool initiallyExpanded; const DsAccordion({super.key, required this.title, required this.child, this.initiallyExpanded=false}); @override State<DsAccordion> createState()=> _DsAccordionState(); }
class _DsAccordionState extends State<DsAccordion>{ bool open=false; @override void initState(){ super.initState(); open = widget.initiallyExpanded; } @override Widget build(BuildContext context){ final cs = Theme.of(context).colorScheme; return Container(decoration: BoxDecoration(border: Border.all(color: cs.outline.withOpacity(.5)), borderRadius: BorderRadius.circular(16)), child: Column(children:[ InkWell(borderRadius: BorderRadius.circular(16), onTap: ()=> setState(()=> open=!open), child: Padding(padding: const EdgeInsets.symmetric(horizontal:16, vertical:14), child: Row(children:[ Expanded(child: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w600))), Icon(open? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down) ]))), AnimatedCrossFade(firstChild: const SizedBox.shrink(), secondChild: Padding(padding: const EdgeInsets.fromLTRB(16,0,16,16), child: widget.child), crossFadeState: open? CrossFadeState.showSecond : CrossFadeState.showFirst, duration: AppTokens.medium) ])); } }

// ============================= Simple Calendar (inline) ============================= //

class DsCalendar extends StatelessWidget { final DateTime month; final DateTime? selected; final ValueChanged<DateTime>? onSelect; const DsCalendar({super.key, required this.month, this.selected, this.onSelect});
  List<DateTime> _daysInMonth(DateTime m){ final first = DateTime(m.year, m.month, 1); final daysBefore = first.weekday % 7; final last = DateTime(m.year, m.month+1, 0); final total = daysBefore + last.day; final rows = (total/7).ceil(); return List.generate(rows*7, (i){ final day = i - daysBefore + 1; if(day<1 || day>last.day) return DateTime(0); return DateTime(m.year, m.month, day); }); }
  @override Widget build(BuildContext context){ final cs = Theme.of(context).colorScheme; final days = _daysInMonth(month); final now = DateTime.now(); return Column(children:[ GridView.builder(shrinkWrap:true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing:4, crossAxisSpacing:4), itemCount: days.length, itemBuilder: (_,i){ final d = days[i]; if(d.year==0) return const SizedBox.shrink(); final isSel = selected!=null && d.year==selected!.year && d.month==selected!.month && d.day==selected!.day; final isToday = d.year==now.year && d.month==now.month && d.day==now.day; Color fg = Theme.of(context).colorScheme.onSurface; if(isSel) fg = cs.onPrimary; return InkWell(onTap: onSelect==null? null : ()=> onSelect!(d), borderRadius: BorderRadius.circular(12), child: Container(decoration: BoxDecoration(color: isSel? cs.primary : isToday? cs.primary.withOpacity(.1) : cs.surface, borderRadius: BorderRadius.circular(12)), child: Center(child: Text('${d.day}', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: fg)))) ; }), ]); }
}

// ============================= List Title / Item ============================= //

class DsListTitle extends StatelessWidget { final String title; final Widget? trailing; final EdgeInsets padding; const DsListTitle(this.title,{super.key, this.trailing, this.padding=const EdgeInsets.fromLTRB(4,12,4,6)}); @override Widget build(BuildContext context){ return Padding(padding: padding, child: Row(children:[ Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface.withOpacity(.74)))), if(trailing!=null) trailing! ])); } }

class DsListItem extends StatelessWidget { final Widget? leading; final String title; final String? subtitle; final Widget? trailing; final VoidCallback? onTap; final bool selected; const DsListItem({super.key, this.leading, required this.title, this.subtitle, this.trailing, this.onTap, this.selected=false}); @override Widget build(BuildContext context){ final cs = Theme.of(context).colorScheme; return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: Container(padding: const EdgeInsets.symmetric(horizontal:16, vertical:12), decoration: BoxDecoration(color: selected? cs.primary.withOpacity(.08): cs.surface, border: Border.all(color: (selected? cs.primary : cs.outline).withOpacity(.4)), borderRadius: BorderRadius.circular(14)), child: Row(children:[ if(leading!=null)...[leading!, const SizedBox(width:12)], Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[ Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface)), if(subtitle!=null) Padding(padding: const EdgeInsets.only(top:2), child: Text(subtitle!, style: Theme.of(context).textTheme.bodySmall)) ])), if(trailing!=null) trailing! ]))); } }

// ============================= Divider shortcut ============================= //

class DsDivider extends StatelessWidget { final double space; const DsDivider({super.key, this.space=24}); @override Widget build(BuildContext context){ return Padding(padding: EdgeInsets.symmetric(vertical: space/2), child: Divider(height: space)); } }

// ============================= Convenience Card alias ============================= //

class DsCard extends StatelessWidget { final Widget child; final EdgeInsets padding; final VoidCallback? onTap; const DsCard({super.key, required this.child, this.padding=const EdgeInsets.all(16), this.onTap}); @override Widget build(BuildContext context){ return ShadCard(child: child, padding: padding, onTap: onTap); } }
