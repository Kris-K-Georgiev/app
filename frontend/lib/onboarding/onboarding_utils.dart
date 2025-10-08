/// Utilities for onboarding flow (profile completeness checks, etc.)

/// A profile is considered incomplete if:
/// - map is null OR
/// - name missing/empty OR
/// - city missing/empty
/// Extra fields can be appended here later (e.g. interests, avatar)
/// Basic completeness (name + city)
bool isProfileIncomplete(Map<String,dynamic>? user){
  if(user==null) return true;
  final name = (user['name'] as String?)?.trim();
  final city = (user['city'] as String?)?.trim();
  if(name==null || name.isEmpty) return true;
  if(city==null || city.isEmpty) return true;
  return false;
}

/// Extended completeness check optionally including interests.
/// Set [interestsRequired] to true if onboarding must include at least one interest.
bool isProfileIncompleteFull(Map<String,dynamic>? user,{bool interestsRequired=false}){
  if(isProfileIncomplete(user)) return true;
  if(!interestsRequired) return false;
  final interests = user?['interests'];
  if(interests is List){
    return interests.isEmpty;
  }
  return true; // required but missing
}

/// Global flag to toggle whether interests are mandatory in completeness.
/// Flip to true when backend enforces interests presence.
const bool kInterestsMandatory = false;
