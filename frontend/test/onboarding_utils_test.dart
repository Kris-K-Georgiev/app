import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/onboarding/onboarding_utils.dart';

void main(){
  group('isProfileIncomplete', (){
    test('null map -> incomplete', (){
      expect(isProfileIncomplete(null), true);
    });
    test('missing name', (){
      expect(isProfileIncomplete({'city':'Sofia'}), true);
    });
    test('missing city', (){
      expect(isProfileIncomplete({'name':'John Doe'}), true);
    });
    test('complete', (){
      expect(isProfileIncomplete({'name':'John Doe','city':'Plovdiv'}), false);
    });
    test('whitespace trimmed', (){
      expect(isProfileIncomplete({'name':'   ','city':'Varna'}), true);
    });
  });
}
