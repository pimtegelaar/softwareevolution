module softwareevolution::LinesOfCode

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import softwareevolution::Replace;
import softwareevolution::CommentCleanup;

/**
 * We only count lines that contain atleast one non-whitespace character.
 */
public int countCodeLines(str sourcecode) = (0 | it + 1 | /\S+.*\n/  := sourcecode);

public str cleanUp(str sourcecode) {
  noTabsAndCarriageReturn = remove(remove(sourcecode, "\r"), "\t");
  // We clear the strings, because they may contain comment characters
  clearStrings = replace(noTabsAndCarriageReturn, "\"","\"","\"\"");
  // Replace multi- and single-line comments
  noComments = replace(replace(clearStrings, "/*","*/"), "//","\n");
  return noComments;
}

public map[str,int] linesPerFile(M3 model) {
  lpc = ();
  withoutComments = eraseComments(model);
  for (cleanSource <- withoutComments) {
    src = withoutComments[cleanSource];
    lines = countCodeLines(remove(remove(src, "\r"), "\t"));
    lpc[cleanSource] = lines;
  }
  return lpc;
}

public map[loc,int] linesPerMethod(M3 model) {
  lpm = ();
  withoutComments = eraseComments(model);
  map[loc,loc] myMethods = (e.name:e.src | e <- model@declarations, isMethod(e.name));
  for(parent <- {e | e <- model@declarations, isClass(e.name) || isInterface(e.name)}) {
    for(methodDeclaration <- methods(model, parent.name)) {
      loc method = myMethods[methodDeclaration];
      str fileLoc = parent.src.path;
      str file = withoutComments[fileLoc];
      offset = method.offset;
      end = offset+method.length;
      methodSrc = substring(file, offset, end);
      strippedSrc = remove(remove(methodSrc, "\r"), "\t");
      // We add 1 to the total lines, because the  last newline is not included in the method source.
      lpm[methodDeclaration] = countCodeLines(strippedSrc)+1;
    }
  }
  return lpm;
}

public int totalLines(M3 model) = (0 | it + subTotal | subTotal <- range(linesPerFile(model)));

public int linesProjectTotal(loc project) = totalLines(createM3FromEclipseProject(project));
