import 'package:flutter/material.dart';
import 'onboarding_questionnaire_screen.dart';

// New streamlined intro (step 1/2). Old marketing carousel removed for faster funnel.
class OnboardingIntroScreen extends StatelessWidget {
  const OnboardingIntroScreen({super.key});

  void _continue(BuildContext context){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const OnboardingQuestionnaireScreen()));
  }

  @override
  Widget build(BuildContext context){
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal:24, vertical:24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: 0.5, minHeight: 6, backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(.4)),
            ),
            const SizedBox(height:32),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        color: theme.colorScheme.primaryContainer.withOpacity(.55),
                      ),
                      alignment: Alignment.center,
                      child: Text('БХСС', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(height:32),
                  Text('Добре дошъл!', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height:12),
                  Text('Само още една кратка стъпка за да персонализираме преживяването ти.', style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: ()=> _continue(context), child: const Text('Продължи')))
          ]),
        ),
      ),
    );
  }
}
