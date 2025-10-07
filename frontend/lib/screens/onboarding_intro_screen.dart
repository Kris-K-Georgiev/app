import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/auth_screens.dart';

class OnboardingIntroScreen extends StatefulWidget {
  const OnboardingIntroScreen({super.key});
  @override
  State<OnboardingIntroScreen> createState() => _OnboardingIntroScreenState();
}

class _OnboardingIntroScreenState extends State<OnboardingIntroScreen> {
  final PageController _pc = PageController();
  int _index = 0;
  bool _saving = false;

  final _pages = const [
    _IntroPage(
  title: 'БХСС',
      body: 'Всичко на едно място – винаги близо до теб.',
      icon: Icons.hub,
    ),
    _IntroPage(
      title: 'Какво представлява БХСС?',
      body: 'Движение на студенти, изградени в общности от ученици, променени от Евангелието и влияещи в Университета, Църквата и обществото за слава на Христос.',
      icon: Icons.group,
    ),
    _IntroPage(
      title: 'Открий повече',
      body: 'Получавай подкрепа, вдъхновение, истории и ресурси, които ще изграждат твоята вяра и служение.',
      icon: Icons.explore,
    ),
    _IntroPage(
      title: 'Да започваме?',
      body: 'Присъедини се и стани част от нас.',
      icon: Icons.rocket_launch,
    ),
  ];

  Future<void> _finish() async {
    setState(()=>_saving=true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if(!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> const LoginScreen()));
  }

  void _next(){
    if(_index < _pages.length -1){
      _pc.nextPage(duration: const Duration(milliseconds:300), curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  void _skip(){ _finish(); }

  @override
  Widget build(BuildContext context){
    final isLast = _index == _pages.length -1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pc,
                itemCount: _pages.length,
                onPageChanged: (i)=> setState(()=> _index=i),
                itemBuilder: (_,i)=> _pages[i],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:20, vertical:12),
              child: Row(
                children: [
                  TextButton(onPressed: _saving? null : _skip, child: const Text('Пропусни')),
                  const Spacer(),
                  Row(children: List.generate(_pages.length, (i){
                    final active = i==_index; return Container(margin: const EdgeInsets.symmetric(horizontal:4), width: active? 12:8, height: active? 12:8, decoration: BoxDecoration(color: active? Theme.of(context).colorScheme.primary : Colors.grey.shade400, shape: BoxShape.circle));
                  })),
                  const Spacer(),
                  ElevatedButton(onPressed: _saving? null : _next, child: _saving? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)) : Text(isLast? 'Започни' : 'Напред')),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  final String title; final String body; final IconData icon;
  const _IntroPage({required this.title, required this.body, required this.icon});
  @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 96, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 36),
          Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Text(body, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
