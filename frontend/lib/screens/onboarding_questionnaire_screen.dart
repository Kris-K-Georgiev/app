import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/ui_provider.dart';
import '../widgets/city_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../onboarding/onboarding_utils.dart';
import '../l10n/l10n.dart';

// Simple model for interests (could be fetched from backend later)
const _kInterests = <String>[
  'STEM','Art','Music','Sports','Debate','Volunteer','Languages','Robotics'
];

class OnboardingQuestionnaireScreen extends StatefulWidget {
  static const routeName = '/onboarding/questionnaire';
  const OnboardingQuestionnaireScreen({super.key});
  @override State<OnboardingQuestionnaireScreen> createState()=> _OnboardingQuestionnaireScreenState();
}

class _OnboardingQuestionnaireScreenState extends State<OnboardingQuestionnaireScreen>{
  String? _city; final Set<String> _interests = {};
  bool _saving=false; String? _error;
  bool _loadingLocal=true;

  static const _kDraftCityKey = 'onboarding_draft_city';
  static const _kDraftInterestsKey = 'onboarding_draft_interests';

  @override
  void initState(){
    super.initState();
    _restoreDraft();
  }

  Future<void> _restoreDraft() async {
    final auth = context.read<AuthProvider>();
    // If user somehow navigated here authenticated and already complete -> skip
    if(!mounted) return;
    if(!auth.isAuthenticated){
      // proceed with draft restore only
    } else {
      if(!isProfileIncompleteFull(auth.user, interestsRequired: kInterestsMandatory)){
        // Already complete -> pop / navigate away
        WidgetsBinding.instance.addPostFrameCallback((_){
          if(!mounted) return; Navigator.pop(context); });
        return;
      }
    }
    final prefs = await SharedPreferences.getInstance();
    _city = prefs.getString(_kDraftCityKey);
    final interestList = prefs.getStringList(_kDraftInterestsKey) ?? [];
    _interests.addAll(interestList);
    if(mounted) setState(()=> _loadingLocal=false);
  }

  Future<void> _persistDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDraftCityKey, _city ?? '');
    await prefs.setStringList(_kDraftInterestsKey, _interests.toList());
  }

  Future<void> _finish() async {
    if(_city==null || _city!.isEmpty){
      setState(()=> _error=AppLocalizations.of(context).t('error_select_city'));
      return;
    }
    final auth = context.read<AuthProvider>();
    final ui = context.read<UiProvider>();
    setState(()=>{_saving=true,_error=null});
    ui.showBlocking(AppLocalizations.of(context).t('saving'));
    try {
      // Update core profile first
      // Capture pre-update state for rollback if interests fail
      final beforeUser = auth.user;
      await auth.updateProfile(city: _city);
      if(_interests.isNotEmpty){
        try {
          await auth.setInterests(_interests.toList());
        } catch(e){
          // Rollback (best-effort) city change if interests considered atomic with city for your flow
          if(beforeUser!=null){
            // Shallow revert only fields we touched
            if(beforeUser['city'] != null){ auth.user?['city'] = beforeUser['city']; }
          }
          // Surface user feedback about failure
          if(mounted){
            final loc = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(loc.t('rollback_error')))
            );
          }
          rethrow;
        }
      }
  // Mark onboarding complete locally
  final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    // Clear draft upon success
    await prefs.remove(_kDraftCityKey); await prefs.remove(_kDraftInterestsKey);
      if(!mounted) return; Navigator.pushReplacementNamed(context, '/');
    } catch(e){ setState(()=> _error=e.toString()); }
    finally { ui.hideBlocking(); if(mounted) setState(()=> _saving=false); }
  }

  @override
  Widget build(BuildContext context){
    final theme = Theme.of(context);
    if(_loadingLocal){
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).t('onboarding_step2_title'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal:24, vertical:16),
          children: [
            // Step progress (simple linear bar 2/2 completed state disabled until finish)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: 1.0, minHeight: 6, backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(.4)),
            ),
            const SizedBox(height:24),
            Text(AppLocalizations.of(context).t('complete_profile_title'), style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height:12),
            Text(AppLocalizations.of(context).t('complete_profile_sub'), style: theme.textTheme.bodyMedium),
            const SizedBox(height:24),
            CityDropdown(value:_city, onChanged:(v)=> setState(()=> {_city=v; _persistDraft();}), validator: (_)=> null),
            const SizedBox(height:24),
            Text(AppLocalizations.of(context).t('interests'), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height:8),
            Wrap(spacing:10, runSpacing:10, children: [
              for(final interest in _kInterests) _InterestChip(
                label: interest,
                selected: _interests.contains(interest),
                onTap: (){ setState(()=> _interests.contains(interest)? _interests.remove(interest) : _interests.add(interest)); _persistDraft(); },
              )
            ]),
            const SizedBox(height:32),
            if(_error!=null) Padding(padding: const EdgeInsets.only(bottom:12), child: Text(_error!, style: TextStyle(color: theme.colorScheme.error))),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _saving? null : _finish, child: Text(_saving? '...' : AppLocalizations.of(context).t('done'))),
            ),
          ],
        ),
      ),
    );
  }
}

class _InterestChip extends StatelessWidget {
  final String label; final bool selected; final VoidCallback onTap;
  const _InterestChip({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context){
    final cs = Theme.of(context).colorScheme;
    final bg = selected? cs.primary : cs.surface;
    final fg = selected? cs.onPrimary : cs.onSurface;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: AnimatedContainer(
        duration: const Duration(milliseconds:180),
        padding: const EdgeInsets.symmetric(horizontal:16, vertical:10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: selected? cs.primary : cs.outline.withOpacity(.5)),
          boxShadow: selected? [BoxShadow(color: cs.primary.withOpacity(.28), blurRadius: 12, offset: const Offset(0,4))] : null,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children:[
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: fg)),
          if(selected) ...[
            const SizedBox(width:6),
            Icon(Icons.check, size:16, color: fg)
          ]
        ]),
      ),
    );
  }
}

// Legacy _t helper removed in favor of AppLocalizations
