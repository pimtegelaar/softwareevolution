module softwareevolution::LinesOfCode

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import softwareevolution::Replace;
import softwareevolution::CommentCleanup;

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

public map[loc,int] linesPerMethod(M3 model) {
  lpm = ();
  withoutComments = eraseComments(model);
  map[loc,loc] myMethods = (e.name:e.src | e <- model@declarations, isMethod(e.name));
  for(classDeclaration <- {e | e <- model@declarations, isClass(e.name)}) {
    for(methodDeclaration <- methods(model, classDeclaration.name)) {
      loc method = myMethods[methodDeclaration];
      str fileLoc = classDeclaration.src.path;
      str file = withoutComments[fileLoc];
      offset = classDeclaration.src.offset + method.offset;
      length = method.length;
      end = offset+length;
      methodSrc = substring(file, offset, end);
      lpm[method]=countLines(methodSrc);
    }
  }
  return lpm;
}

public int totalLines(M3 model) = (0 | it + subTotal | subTotal <- range(linesPerClass(model)));

public int linesProjectTotal(loc project) = totalLines(createM3FromEclipseProject(project));
