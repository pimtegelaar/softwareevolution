module softwareevolution::Measure

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import List;
import String;
import IO;

public int countMethods(M3 model, loc class) {
  list[loc] methods = [ e | e <- model@containment[class], e.scheme == "java+method"];
  int methodCount = size(methods);
  return methodCount;
}

public int countLines(str sourcecode) {
  int lineCount = (0 | it + 1 | /\r\n/ := sourcecode);
  return lineCount;
}

public int countLOC(str sourcecode) {    
  int lineCounter = 0;
  for (n <- split("\r\n", sourcecode)) {
    if ( /\w/ := n ) lineCounter += 1;
    if ( /\w/ := n ) println("match: " + n); else println("no match: " + n);

  } 
  return lineCounter;
}

// someFile = readFile(|project://example-project/src/Apple.java|);
// countLOC(someFile);