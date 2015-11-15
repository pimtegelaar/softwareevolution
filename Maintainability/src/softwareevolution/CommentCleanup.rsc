module softwareevolution::CommentCleanup

import Prelude;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

public list[loc] getComments(M3 model) = [e | <_,e> <- model@documentation];

/** Replaces comments with spaces */
public map[str,str] eraseComments(M3 model) {
  map[str,str] files = (f.path:readFileEnc(f,"UTF-8") | f <- files(model));    
  for (comment <- getComments(model)) {
    file = files[comment.path];
    cleared = replaceWithSpace(file, comment.offset, comment.length);
    files[comment.path] = cleared;
  }  
  return files;
}

public str replaceWithSpace(str s, int offset, int length) {
  before = substring(s, 0, offset);
  after = substring(s, offset + length);
  replacement = repeat(length, " ");
  return before + replacement + after;
}


public str repeat(int l, str s) {
  result = "";
  for(i <- [0..l])
    result += s;
  return result;
}

public map[int,str] removeComments(M3 model) {
  
  list[loc] comments = getComments(model);
  map[int,str] newSource = ();
  list[str] splittedSource = [];
  str mergedSource = "";
  int i = 0;
  
  for (c <- files(model)) {
    source = readFile(c);
    splittedSource = split("\r\n", source);
    for (comment <- comments) {
      if (c.file == comment.file) {     
  // singleline comments
  if (comment.begin.line == comment.end.line) {
    beginLine = comment.begin.line - 1;
    beginColumn = comment.begin.column;
    endColumn = comment.end.column;
    currentLine = splittedSource[beginLine];
    replaceComment = substring(currentLine, beginColumn, endColumn);
    splittedSource[beginLine] = replaceFirst(splittedSource[beginLine],replaceComment,"");
  }
  
  // multiline comments
  if (comment.begin.line != comment.end.line) {
    beginLine = comment.begin.line - 1;
    endLine = comment.end.line - 1;
    beginColumn = comment.begin.column;
    endColumn = comment.end.column;
    for (l <- [beginLine..endLine + 1]) {                   
      // replace beginline
      if ( l == beginLine ) {
        replaceComment = substring(splittedSource[l], beginColumn, size(splittedSource[l]));
        splittedSource[l] = replaceFirst(splittedSource[l],replaceComment,"");
      }
      // replace lines in between
      if ( l != beginLine && l != endLine ) { 
        replaceComment = substring(splittedSource[l], 0, size(splittedSource[l]));
        splittedSource[l] = replaceFirst(splittedSource[l],replaceComment,"");
      }
      // replace endline
      if ( l == endLine ) { 
        replaceComment = substring(splittedSource[l], 0, endColumn);
        splittedSource[l] = replaceFirst(splittedSource[l],replaceComment,"");
      }
    }
  }
      }
    }
    for (s <- splittedSource) { 
      // remove new lines and leading/trailing white spaces (remove too much new lines now?)
      if ( isEmpty(trim(s)) == false ) { mergedSource = mergedSource + "\r\n" + s; }
    }
    mergedSource = replaceFirst(mergedSource, "\r\n", "");
    newSource = newSource + (i: mergedSource);
    mergedSource = "";
    i += 1;   
  }
  return newSource;
}
