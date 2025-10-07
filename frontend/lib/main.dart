import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'services/api_client.dart';
import 'theme/shad_theme.dart';
import 'services/content_service.dart';
import 'providers/auth_provider.dart';
import 'providers/content_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth_screens.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'screens/home_screen.dart';
import 'services/biometric_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'screens/update_screen.dart';
import 'services/heartbeat_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/onboarding_completion_screen.dart'; 
import 'screens/onboarding_intro_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/ui_provider.dart';
import 'widgets/global_overlay.dart';
import 'theme/responsive_factors.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AuthGate extends StatelessWidget {
  final Widget child;
  const AuthGate({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (ctx, auth, _) {
        if(!auth.isAuthenticated) {
          // When token lost (logout), push login
          return const LoginScreen();
        }
        return child;
      },
    );
  }
}

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (details){
      // ignore: avoid_print
      print('[flutter-error] ${details.exception}\n${details.stack}');
    };
    runApp(const AppRoot());
    // Defer attaching timing logger to next frame to avoid platform dispatcher race
    WidgetsBinding.instance.addPostFrameCallback((_){
      try {
        ui.PlatformDispatcher.instance.onReportTimings = (List<ui.FrameTiming> timings){
          for(final t in timings){
            final build = t.buildDuration.inMilliseconds;
            final raster = t.rasterDuration.inMilliseconds;
            if(build > 32 || raster > 32){
              // ignore: avoid_print
              print('[perf][frame] build=${build}ms raster=${raster}ms (threshold 32ms)');
            }
          }
        };
      } catch(e,st){
        // ignore: avoid_print
        print('[perf-init-error] $e\n$st');
      }
    });
  }, (error, stack){
    // ignore: avoid_print
    print('[unhandled] $error\n$stack');
  });
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
  // Increase default timeout to 15s to reduce false 408 during first cold start / DB spin-up
  final apiClient = ApiClient(null, timeout: const Duration(seconds:15));
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => ContentProvider(ContentService(apiClient))),
        ChangeNotifierProvider(create: (_) => UiProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (ctx, theme, _) => MaterialApp(
          navigatorKey: navigatorKey,
          title: 'БХСС',
          theme: ShadTheme.light().copyWith(
            iconTheme: const IconThemeData(size: 22),
            navigationBarTheme: const NavigationBarThemeData(indicatorColor: Colors.transparent),
          ),
            darkTheme: ShadTheme.dark().copyWith(
              iconTheme: const IconThemeData(size: 22),
              navigationBarTheme: const NavigationBarThemeData(indicatorColor: Colors.transparent),
            ),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('bg'), Locale('en')],
          routes: {
            OnboardingCompletionScreen.routeName: (_) => const OnboardingCompletionScreen(),
            '/profile': (_) => const ProfileScreen(),
            '/settings': (_) => const SettingsScreen(),
          },
          themeMode: theme.flutterMode,
          home: const SplashScreen(),
          builder: (context, child){
            final width = MediaQuery.of(context).size.width;
            final factors = ResponsiveFactors.fromWidth(width);
            final themeBase = Theme.of(context);
            final merged = themeBase.copyWith(
              extensions: [
                ...themeBase.extensions.values.whereType<ThemeExtension>(),
                factors,
              ],
            );
            return Theme(data: merged, child: GlobalOverlay(child: child ?? const SizedBox.shrink()));
          },
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _version;
  HeartbeatService? _hb;
  bool _optionalShown = false; // avoid duplicate optional update dialog
  bool _routing = false; // prevent double navigation
  bool _failed = false; String? _failMessage; bool _retrying=false;
  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((p){ if(mounted) setState(()=> _version='v${p.version}'); });
    _bootstrap();
  }

  bool _isVersionNewer(String remote, String local){
    List<int> parse(String v)=> v.split('.').map((e){ final n=int.tryParse(e); return n??0; }).toList();
    final r = parse(remote);
    final l = parse(local);
    final len = r.length>l.length? r.length : l.length;
    for(int i=0;i<len;i++){
      final rv = i<r.length? r[i]:0;
      final lv = i<l.length? l[i]:0;
      if(rv>lv) return true;
      if(rv<lv) return false;
    }
    return false; // equal or not newer
  }

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final contentProvider = context.read<ContentProvider>();
    // Wait for auth restoration to finish to avoid routing before token loads
    final authProv = context.read<AuthProvider>();
    final startWait = DateTime.now();
    while(!authProv.initialized && DateTime.now().difference(startWait).inSeconds < 10){
      await Future.delayed(const Duration(milliseconds: 100));
    }
    // Initialize heartbeat once API base is known and before loading content
    if(_hb==null){
      final api = context.read<AuthProvider>().api; // shared ApiClient
      _hb = HeartbeatService(api, interval: const Duration(seconds:25));
      contentProvider.attachHeartbeat(_hb!);
    }
    // Version check first
    final content = contentProvider;
    try {
      await content.checkVersion().timeout(const Duration(seconds:6));
    } catch(e){
      // Non-fatal; mark failure but allow continuing to auth routing
      _failed = true; _failMessage = 'Няма връзка със сървъра';
    }
    final latest = content.latest;
    final package = await PackageInfo.fromPlatform();
    final currentVersionName = package.version;
    bool isNewer = false;
    if(latest!=null){
      isNewer = _isVersionNewer(latest.versionName, currentVersionName);
    }
    if(isNewer && latest!=null && latest.isMandatory) {
      bool stayBlocked = true;
      while(stayBlocked && mounted){
        final action = await showDialog<String>(context: context, barrierDismissible: false, builder: (ctx){
          return AlertDialog(
            title: const Text('Задължителна актуализация'),
            content: Text('Налична е нова версия: ${latest.versionName}\n${latest.releaseNotes ?? ''}'),
            actions: [
              TextButton(
                onPressed: latest.downloadUrl==null? null : () async {
                  final url = latest.downloadUrl!;
                  final uri = Uri.parse(url);
                  if(await canLaunchUrl(uri)){
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                  Navigator.pop(ctx,'external');
                },
                child: Text(latest.downloadUrl==null? 'Unavailable':'Store'),
              ),
              if(latest.downloadUrl!=null) TextButton(onPressed: (){ Navigator.pop(ctx,'internal'); }, child: const Text('In-App')),
            ],
          );
        });
        if(action=='internal' && latest.downloadUrl!=null && mounted){
          await Navigator.of(context).push(MaterialPageRoute(builder: (_)=> UpdateScreen(url: latest.downloadUrl!, version: latest.versionName, notes: latest.releaseNotes)));
        }
        final pkg2 = await PackageInfo.fromPlatform();
        if(!_isVersionNewer(latest.versionName, pkg2.version)){
          stayBlocked = false;
        }
      }
    }
    // Optional (non-mandatory) update prompt (one-time, unless dismissed) BEFORE routing
    if(mounted && latest!=null && isNewer && !latest.isMandatory){
      final prefs = await SharedPreferences.getInstance();
      final dismissed = prefs.getBool('dismiss_version_${latest.versionName}') ?? false;
      if(!dismissed && !_optionalShown){
        _optionalShown = true;
        final action = await showDialog<String>(context: context, builder: (ctx){
          return AlertDialog(
            title: const Text('Налична е нова версия'),
            content: Text('Версия: ${latest.versionName}\n${latest.releaseNotes ?? ''}\nИскаш ли да я свалиш сега?'),
            actions: [
              TextButton(onPressed: (){ Navigator.pop(ctx,'later'); }, child: const Text('По-късно')),
              if(latest.downloadUrl!=null) TextButton(onPressed: (){ Navigator.pop(ctx,'store'); }, child: const Text('Store')),
              if(latest.downloadUrl!=null) ElevatedButton(onPressed: (){ Navigator.pop(ctx,'inapp'); }, child: const Text('Update Now')),
            ],
          );
        });
        if(!mounted) return;
        if(action=='store' && latest.downloadUrl!=null){
          final uri = Uri.parse(latest.downloadUrl!);
          if(await canLaunchUrl(uri)){ await launchUrl(uri, mode: LaunchMode.externalApplication); }
        } else if(action=='inapp' && latest.downloadUrl!=null){
          await Navigator.of(context).push(MaterialPageRoute(builder: (_)=> UpdateScreen(url: latest.downloadUrl!, version: latest.versionName, notes: latest.releaseNotes)));
        } else if(action=='later'){ await prefs.setBool('dismiss_version_${latest.versionName}', true); }
      }
    }
    if(_routing) return; // safety
  final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated) {
      final bio = BiometricHelper();
      final canBio = auth.biometricPreferred && await bio.canCheck();
      if(canBio){
        final ok = await bio.authenticateSystem(reason: 'Влез с биометрия');
        if(!ok){
          auth.logout();
          if(!mounted) return;
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> const LoginScreen()));
          return;
        }
      }
      // Check profile completeness (име + град)
  final u = auth.user; // dynamic map from provider
  final nameVal = (u==null)? null : (u['name'] as String?);
  final cityVal = (u==null)? null : (u['city'] as String?);
  final incomplete = u==null || (nameVal==null || nameVal.trim().isEmpty) || (cityVal==null || cityVal.isEmpty);
      if(mounted){
        if(incomplete){
          _routing = true; Navigator.of(context).pushReplacementNamed(OnboardingCompletionScreen.routeName);
        } else {
          _routing = true; Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AuthGate(child: HomeScreen())));
        }
      }
  } else {
      if(!mounted) return;
      // Decide whether to show multi-page onboarding or go straight to auth
      try {
        final prefs = await SharedPreferences.getInstance();
        final done = prefs.getBool('onboarding_done') ?? false;
        if(done) {
          _routing = true; Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
        } else {
          _routing = true; Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const OnboardingIntroScreen()));
        }
      } catch(_) {
        _routing = true; Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const OnboardingIntroScreen()));
      }
    }
    if(mounted && _failed && !_routing){ setState((){}); }
  }

  @override
  void dispose(){ _hb?.stop(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final logoAsset = brightness==Brightness.dark ? 'assets/logo/dark_logo.png' : 'assets/logo/light_logo.png';
    return Scaffold(
      body: Center(
        child: LayoutBuilder(builder: (ctx, constraints){
          final maxW = constraints.maxWidth;
            final logoSize = (maxW*0.28).clamp(100, 200); // adaptive scaling
            return Stack(children:[
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Try themed logo; fallback to generic if missing
                    Image.asset(logoAsset, width: logoSize.toDouble(), height: logoSize.toDouble(), fit: BoxFit.contain, errorBuilder: (_,__,___)=> Image.asset('assets/logo/logo.png', width: logoSize.toDouble(), height: logoSize.toDouble(), fit: BoxFit.contain)),
                    const SizedBox(height: 24),
                    Text('БХСС', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('Заедно за повече.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 32),
                    if(!_failed) const CircularProgressIndicator(strokeWidth: 2.4)
                    else Column(children:[
                      Text(_failMessage ?? 'Грешка при свързване', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error)),
                      const SizedBox(height:12),
                      ElevatedButton(onPressed: _retrying? null : () async { setState(()=>_retrying=true); _failed=false; _failMessage=null; await _bootstrap(); if(mounted) setState(()=>_retrying=false); }, child: Text(_retrying? '...' : 'Опитай отново'))
                    ]),
                  ],
                ),
              ),
              if(_version!=null) Positioned(
                bottom: 18,
                left: 0,
                right: 0,
                child: Text(_version!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).textTheme.labelMedium?.color?.withOpacity(.65))),
              )
            ]);
        }),
      ),
    );
  }
}

// TODO: New onboarding flow will collect missing profile data (име, град) after login if absent.
// Placeholder removed old marketing pages.
// Onboarding screen extracted to separate file (onboarding_intro_screen.dart)
