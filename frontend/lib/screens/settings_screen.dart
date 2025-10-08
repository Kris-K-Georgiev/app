import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/content_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/preferences_provider.dart';
import '../ui/typography_scale.dart';
import 'profile_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../icons/app_icons.dart';
import 'change_password_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget { const SettingsScreen({super.key}); @override State<SettingsScreen> createState()=>_SettingsScreenState(); }
class _SettingsScreenState extends State<SettingsScreen>{
  String version='';
  @override
  void initState(){ super.initState(); _load(); }
  Future<void> _load() async { final p = await PackageInfo.fromPlatform(); setState(()=> version='${p.version}+${p.buildNumber}'); await context.read<ContentProvider>().checkVersion(); }
  @override
  Widget build(BuildContext context){
    final content = context.watch<ContentProvider>();
    final auth = context.watch<AuthProvider>();
    final latest = content.latest;
    final outdated = latest!=null && latest.versionName != version.split('+').first;
    final sectionTitleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: .5, color: Theme.of(context).colorScheme.onSurface.withOpacity(.7));
    final width = MediaQuery.of(context).size.width; final contentW = width < 1000? width : 860; final sidePad = (width - contentW)/2;
    Widget sectionCard({required String title, required List<Widget> children}){
      final scheme = Theme.of(context).colorScheme;
      return Padding(
        padding: EdgeInsets.fromLTRB(16+sidePad, 18, 16+sidePad, 4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: scheme.outline.withOpacity(.20)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 10, offset: const Offset(0,4))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
            Padding(padding: const EdgeInsets.fromLTRB(20,18,20,6), child: Text(title.toUpperCase(), style: sectionTitleStyle)),
            const Divider(height:1),
            ...children,
          ]),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки', style: TextStyle(fontWeight: FontWeight.w700))),
      body: CustomScrollView(
        slivers:[
          SliverPadding(padding: EdgeInsets.only(top:8, bottom: 28), sliver: SliverList(delegate: SliverChildListDelegate([
            sectionCard(title: 'Профил', children:[
              ListTile(leading: AppIcons.person(color: Theme.of(context).colorScheme.primary), title: const Text('Акаунт'), subtitle: Text(auth.user?['email']??'Гост'), onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (_)=> const ProfileScreen())); }),
              if(auth.isAuthenticated) ListTile(title: const Text('Изход'), leading: AppIcons.logout(color: Theme.of(context).colorScheme.error), onTap: () async { await auth.logout(); if(!mounted) return; Navigator.of(context).pop(); }),
            ]),
            sectionCard(title: 'Външен вид', children:[
              Consumer<ThemeProvider>(builder: (ctx, tp, _) { return ListTile(leading: AppIcons.settings(color: Theme.of(context).colorScheme.primary), title: const Text('Тема'), subtitle: Text(tp.mode.name), onTap: () async { final choice = await showModalBottomSheet<AppThemeMode>(context: context, builder: (_) => _ThemeSheet(selected: tp.mode)); if(choice!=null){ tp.setMode(choice); } }); }),
              const _TypographyModeTile(),
              const _HapticsTile(),
              const _LocaleTile(),
              const _TypographyPreviewTile(),
            ]),
            sectionCard(title: 'Сигурност', children:[
              SwitchListTile(value: auth.biometricPreferred, onChanged: (v){ auth.setBiometricPreferred(v); }, title: const Text('Биометричен вход')),
              if(auth.isAuthenticated) ListTile(leading: AppIcons.shield(color: Theme.of(context).colorScheme.primary), title: const Text('Смяна на парола'), onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (_)=> const ChangePasswordScreen())); },),
            ]),
            sectionCard(title: 'Известия', children:[ const _NotificationsToggle() ]),
            sectionCard(title: 'Актуализации', children:[
              ListTile(leading: AppIcons.update(color: Theme.of(context).colorScheme.onSurface), title: const Text('Проверка за обновление'), subtitle: Text(latest==null? 'Няма данни' : 'Последна: ${latest.versionName}'), trailing: outdated? AppIcons.warning(color: Theme.of(context).colorScheme.onSurface.withOpacity(.7)) : null, onTap: () async { await context.read<ContentProvider>().checkVersion(); }),
              if(outdated && latest.downloadUrl!=null) ListTile(title: const Text('Изтегли обновление'), onTap: (){ launchUrl(Uri.parse(latest.downloadUrl!)); }),
              ListTile(title: Text('Версия: $version')),
            ]),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 40),
          ])))
        ],
      ),
    );
  }
}

class _ThemeSheet extends StatelessWidget {
  final AppThemeMode selected;
  const _ThemeSheet({required this.selected});
  @override
  Widget build(BuildContext context){
    final options = AppThemeMode.values;
    return SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height:8),
        Container(height:4,width:48, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(4))),
        for(final opt in options)
          RadioListTile<AppThemeMode>(
            value: opt,
            groupValue: selected,
            title: Text(opt.name),
            onChanged: (v)=> Navigator.pop(context, v),
          ),
        const SizedBox(height:12),
      ]),
    );
  }
}

class _NotificationsToggle extends StatefulWidget {
  const _NotificationsToggle();
  @override State<_NotificationsToggle> createState()=> _NotificationsToggleState();
}
class _NotificationsToggleState extends State<_NotificationsToggle>{
  bool _enabled=true; bool _loaded=false;
  @override void initState(){ super.initState(); _load(); }
  Future<void> _load() async { final prefs = await SharedPreferences.getInstance(); setState((){ _enabled = prefs.getBool('notify_enabled') ?? true; _loaded=true; }); }
  Future<void> _set(bool v) async { final prefs = await SharedPreferences.getInstance(); await prefs.setBool('notify_enabled', v); setState(()=> _enabled=v); }
  @override Widget build(BuildContext context){
    if(!_loaded) return const ListTile(title: Text('Известия'), subtitle: Text('Зареждане...'));
    return SwitchListTile(value: _enabled, onChanged: _set, title: const Text('Извести ме за нови събития'));
  }
}

class _TypographyModeTile extends StatelessWidget {
  const _TypographyModeTile();
  @override
  Widget build(BuildContext context){
    return Consumer<PreferencesProvider>(builder: (_, prefs, __){
      final mode = prefs.typographyMode;
      return ListTile(
        title: const Text('Типография'),
        subtitle: Text(mode == TypographyMode.app ? 'App scale' : 'Material scale'),
        onTap: () async {
          final choice = await showModalBottomSheet<TypographyMode>(context: context, builder: (_){
            return SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children:[
              const SizedBox(height:8),
              Container(height:4,width:48, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(4))),
              for(final m in TypographyMode.values)
                RadioListTile<TypographyMode>(value: m, groupValue: mode, title: Text(m.name), onChanged: (v)=> Navigator.pop(context,v)),
              const SizedBox(height:12)
            ]));
          });
          if(choice!=null){ prefs.setTypographyMode(choice); }
        },
      );
    });
  }
}

class _HapticsTile extends StatelessWidget {
  const _HapticsTile();
  static const labels = ['Off','Reduced','Full'];
  @override
  Widget build(BuildContext context){
    return Consumer<PreferencesProvider>(builder: (_, prefs, __){
      return ListTile(
        title: const Text('Хаптична обратна връзка'),
        subtitle: Text(labels[prefs.haptics]),
        onTap: () async {
          final choice = await showModalBottomSheet<int>(context: context, builder: (_){
            return SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children:[
              const SizedBox(height:8),
              Container(height:4,width:48, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(4))),
              for(int i=0;i<labels.length;i++)
                RadioListTile<int>(value: i, groupValue: prefs.haptics, title: Text(labels[i]), onChanged: (v)=> Navigator.pop(context,v)),
              const SizedBox(height:12)
            ]));
          });
          if(choice!=null){ prefs.setHaptics(choice); }
        },
      );
    });
  }
}

class _LocaleTile extends StatelessWidget {
  const _LocaleTile();
  @override
  Widget build(BuildContext context){
    return Consumer<PreferencesProvider>(builder: (_, prefs, __){
      final current = prefs.locale?.languageCode ?? '(system)';
      return ListTile(
        title: const Text('Език / Language'),
        subtitle: Text(current),
        onTap: () async {
          final choice = await showModalBottomSheet<Locale?>(context: context, builder: (_){
            final options = <Locale?>[null, const Locale('bg'), const Locale('en')];
            return SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children:[
              const SizedBox(height:8),
              Container(height:4,width:48, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(4))),
              for(final loc in options)
                RadioListTile<Locale?>(
                  value: loc,
                  groupValue: prefs.locale,
                  title: Text(loc==null? 'System' : loc.languageCode),
                  onChanged: (v)=> Navigator.pop(context, v),
                ),
              const SizedBox(height:12)
            ]));
          });
          if(choice!=null || prefs.locale!=choice){ prefs.setLocale(choice); }
        },
      );
    });
  }
}

class _TypographyPreviewTile extends StatefulWidget { const _TypographyPreviewTile(); @override State<_TypographyPreviewTile> createState()=> _TypographyPreviewTileState(); }
class _TypographyPreviewTileState extends State<_TypographyPreviewTile>{
  bool _tempToggle=false; // ephemeral preview toggle (not persisted)
  @override
  Widget build(BuildContext context){
    return Consumer<PreferencesProvider>(builder: (_, prefs, __){
      final active = _tempToggle ? (prefs.typographyMode==TypographyMode.app? TypographyMode.material : TypographyMode.app) : prefs.typographyMode;
      final style = active==TypographyMode.app ? Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14) : Theme.of(context).textTheme.bodyMedium!;
      return ListTile(
        title: const Text('Преглед на текст / Preview'),
        subtitle: GestureDetector(
          onLongPress: (){ setState(()=> _tempToggle = !_tempToggle); },
          child: Text('Long press to quick toggle typography mode', style: style),
        ),
        trailing: _tempToggle? const Icon(Icons.swap_horiz) : null,
      );
    });
  }
}
