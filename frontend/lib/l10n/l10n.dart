import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

// Simplified localization loader (manual) – for larger apps use flutter gen-l10n.
// Here we manually map keys from ARB conceptually; in a production app you would
// enable flutter's built-in localization generation.

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) => Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static final Map<String, Map<String,String>> _localizedValues = {
    'en': {
      'complete_profile_title': "Let's complete your profile",
      'complete_profile_sub': 'Choose your city and interests to personalize your content.',
      'interests': 'Interests',
      'done': 'Done',
      'error_select_city': 'Please select a city',
      'onboarding_step2_title': 'Onboarding (2/2)',
      'saving': 'Saving...',
      'rollback_error': 'Failed to save interests. Please retry.',
      'community':'Community',
      'posts_tab':'Posts',
      'prayers_tab':'Prayers',
      'new_post':'New Post',
      'new_prayer':'New Prayer Request',
      'edit':'Edit',
      'content_label':'Content',
      'content_required':'Content required',
      'image':'Image',
      'change_image':'Change image',
      'selected':'Selected',
      'save':'Save',
      'anonymous':'Anonymous',
      'answered':'Answered',
      'likes':'Likes',
      'loading_more':'Loading...',
      'no_more_posts':'No more posts',
      'no_more_prayers':'No more prayers',
      'error_generic':'Error',
      'retry':'Retry',
      'characters_left':'{count} characters left',
      'comments':'Comments ({count})',
      'no_comments':'No comments',
      'add_comment_hint':'Add a comment',
      'new_tag':'New',
      'about_org':'About Organization',
      'feedback':'Feedback',
      'feedback_thanks':'Thank you for your feedback!',
      'feedback_hint':'Share your thoughts...',
      'send':'Send',
      'min_chars':'Min {count} chars',
      'contact_optional':'Contact (optional)',
    },
    'bg': {
      'complete_profile_title': 'Нека довършим профила ти',
      'complete_profile_sub': 'Избери своя град и интереси. Това помага да персонализираме съдържанието.',
      'interests': 'Интереси',
      'done': 'Готово',
      'error_select_city': 'Моля избери град',
      'onboarding_step2_title': 'Онбординг (2/2)',
      'saving': 'Запис...',
      'rollback_error': 'Неуспешно запазване на интересите. Опитай отново.',
      'community':'Общност',
      'posts_tab':'Постове',
      'prayers_tab':'Молитви',
      'new_post':'Нов пост',
      'new_prayer':'Нова молитвена нужда',
      'edit':'Редакция',
      'content_label':'Съдържание',
      'content_required':'Изисква се текст',
      'image':'Снимка',
      'change_image':'Сменѝ снимка',
      'selected':'Избрана',
      'save':'Запази',
      'anonymous':'Анонимно',
      'answered':'Отговорена',
      'likes':'Харесвания',
      'loading_more':'Зареждане...',
      'no_more_posts':'Няма повече постове',
      'no_more_prayers':'Няма повече молитви',
      'error_generic':'Грешка',
      'retry':'Опитай отново',
      'characters_left':'Остават {count} символа',
      'comments':'Коментари ({count})',
      'no_comments':'Няма коментари',
      'add_comment_hint':'Добави коментар',
      'new_tag':'Нов',
      'about_org':'За организацията',
      'feedback':'Обратна връзка',
      'feedback_thanks':'Благодарим за обратната връзка!',
      'feedback_hint':'Сподели мнение...',
      'send':'Изпрати',
      'min_chars':'Мин. {count} символа',
      'contact_optional':'Контакт (по избор)',
    }
  };

  String t(String key, {Map<String,String>? params}) {
    var raw = _localizedValues[locale.languageCode]?[key] ?? _localizedValues['en']![key] ?? key;
    if(params!=null){
      params.forEach((k,v){ raw = raw.replaceAll('{'+k+'}', v); });
    }
    return raw;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => ['en','bg'].contains(locale.languageCode);
  @override
  Future<AppLocalizations> load(Locale locale) async { Intl.defaultLocale = locale.languageCode; return AppLocalizations(locale); }
  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
