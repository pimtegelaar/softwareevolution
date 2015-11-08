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

public int countLOC(str sourcecode) {    
  int lineCounter = 0;
 
  str sourceWithoutCR = replaceAll(sourcecode, "\r", ""); // remove carriage returns
  str sourceWithoutTabs = replaceAll(sourceWithoutCR, "\t", ""); // remove tab characters

  bool multiLineComment = false;
  for (n <- split("\n", sourceWithoutTabs)) {
    str m = trim(n); // remove leading/trailing white spaces
    if(emptyLine(m) || singleLineComment(m) || multiLineCommentOnOneLine(m)) {
      println("-- no match: " + m);
      continue;
    }  
    if(multiLineComment) {
      if(multiLineCommentEnd(m))
        multiLineComment = false;
      println("-- no match: " + m);
      continue;
    }
    if(multiLineCommentStart(m)) {
      multiLineComment = true;
      println("-- no match: " + m);
      continue;
    }

    lineCounter += 1;
    println("++ match: " + m);
  } 
  return lineCounter;
}

public bool emptyLine(str s) = s == "";

/* True if the line starts with "//" precondition: string is devoid of leading spaces and tabs. */
public bool singleLineComment (str s) = /^\/\// := s;

public bool multiLineCommentOnOneLine(str s) = /^\/\*.*<end:\*\/$>/ := s;

public bool multiLineCommentStart(str s) = /^\/\*.*/ := s;

public bool multiLineCommentEnd(str s) = /.*\*\/$/ := s;

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
