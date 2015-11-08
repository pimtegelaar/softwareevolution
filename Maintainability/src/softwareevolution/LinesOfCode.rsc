module softwareevolution::LinesOfCode

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import List;
import String;
import IO;
import Map;

public int countLines(str sourcecode) {
  int lineCount = (0 | it + 1 | /\r\n/ := sourcecode);
  return lineCount;
}

/*
** Volume checks
*/

public int countLOC(str sourcecode) {    
  int lineCounter = 0;
  str sourceWithoutTabs = replaceAll(sourcecode, "\t", ""); // remove tab characters
  for (n <- split("\r\n", sourceWithoutTabs)) {
    str m = trim(n); // remove leading/trailing white spaces
    // first part: don't match comments, second part: do match words or opening/closing brackets
    if ( /^\/|^\/\*|^\*/ !:= m && /\w|\{|\}/ := m ) {
      lineCounter += 1;
      println("match: " + m);
  } 
  else
    println("no match: " + m);
  } 
  return lineCounter;
}

public map[loc,int] linesPerClass(M3 model) {
  lpc = ();
  for (c <- classes(model)) {
    lines = countLOC(readFile(c));
    lpc[c] = lines;
  }
  return lpc;
}

public int totalLines(M3 model) = (0 | it + subTotal | subTotal <- range(linesPerClass(model)));

public int linesProjectTotal(loc project) = totalLines(createM3FromEclipseProject(project));
