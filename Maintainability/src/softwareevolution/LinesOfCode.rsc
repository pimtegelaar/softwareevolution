module softwareevolution::LinesOfCode

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import List;
import String;
import IO;
import Map;
import softwareevolution::Replace;

public int countLines(str sourcecode) {
  int lineCount = (0 | it + 1 | /.+\n/ := sourcecode);
  return lineCount;
}

public str cleanUp(str sourcecode) {
  noTabsAndCarriageReturn = remove(remove(sourcecode, "\r"), "\t");
  // We clear the strings, because they may contain comment characters
  clearStrings = replace(noTabsAndCarriageReturn, "\"","\"","\"\"");
  // Replace multi- and single-line comments
  noComments = replace(replace(clearStrings, "/*","*/"), "//","\n");
  return noComments;
}

public map[loc,int] linesPerClass(M3 model) {
  lpc = ();
  for (c <- files(model)) {
    cleanSource = cleanUp(readFile(c));
    lines = countLines(cleanSource);
    lpc[c] = lines;
  }
  return lpc;
}

public int totalLines(M3 model) = (0 | it + subTotal | subTotal <- range(linesPerClass(model)));

public int linesProjectTotal(loc project) = totalLines(createM3FromEclipseProject(project));
