String getFlagValue(String flag, String s) {
  RegExp regExp = RegExp(r'(' + RegExp.escape(flag) + r')\s+(\S+)');
  Match? match = regExp.firstMatch(s); 

  if (match != null) {
    return match.group(2) ?? ''; 
  }
  return ''; 
}
