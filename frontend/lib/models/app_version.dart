class AppVersionInfo {
  final int id;
  final int versionCode;
  final String versionName;
  final String? releaseNotes;
  final bool isMandatory;
  final String? downloadUrl;
  AppVersionInfo({required this.id,required this.versionCode,required this.versionName,this.releaseNotes,required this.isMandatory,this.downloadUrl});
  factory AppVersionInfo.fromJson(Map<String,dynamic> j)=> AppVersionInfo(
    id: j['id'],
    versionCode: j['version_code'],
    versionName: j['version_name'],
    releaseNotes: j['release_notes'],
    isMandatory: j['is_mandatory']==1 || j['is_mandatory']==true,
    downloadUrl: j['download_url']
  );
}

// Utility for semantic style comparison including optional pre-release tags.
// Returns 1 if a>b, -1 if a<b, 0 equal.
int compareSemantic(String a, String b){
  int toInt(String s){ final v=int.tryParse(s); return v??0; }
  List<String> splitMain(String v){ return v.split('+')[0].split('-')[0].split('.'); }
  final aParts = splitMain(a);
  final bParts = splitMain(b);
  final len = aParts.length > bParts.length ? aParts.length : bParts.length;
  for(int i=0;i<len;i++){
    final ai = i<aParts.length? toInt(aParts[i]):0;
    final bi = i<bParts.length? toInt(bParts[i]):0;
    if(ai>bi) return 1; if(ai<bi) return -1;
  }
  // If numeric equal, crude pre-release handling: stable (no -) > pre-release
  final aPre = a.contains('-');
  final bPre = b.contains('-');
  if(aPre && !bPre) return -1;
  if(!aPre && bPre) return 1;
  return 0;
}
