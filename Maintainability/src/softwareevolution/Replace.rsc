module softwareevolution::Replace

import String;

public str remove(str s, s2) = replaceAll(s,s2,"");

/** Removes excess newlines */
public str replaceNewlines(str s) {
  if(/^<before:.*?><newline:\n\n>+<after:.*>/s := s)
    return before + "\n" + replaceNewlines(after);  
  return s;
}

/** Replaces the values between the start symbol (ss) and the end symbol (es) in the string (s) with nothing. */
public str replace(str s, str ss, str es) {
  if(/^<before:.*?><newline:<ss>.*?<es>><after:.*>/s := s)
    return before + replace(after, ss, es);  
  return s;
}

/** Replaces the values between the start symbol (ss) and the end symbol (es) in the string (s) with a replacement (r). */
public str replace(str s, str ss, str es, str r) {
  if(/^<before:.*?><newline:<ss>.*?<es>><after:.*>/s := s)
    return before + r + replace(after, ss, es, r);  
  return s;
}
