module softwareevolution::series2::CommentReplace

import Prelude;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

/** Remove comments and generate map of sourcelines */
public map[str,str] replaceComments(M3 model, str replaceCommentWith) {
  
  list[loc] comments = [e | <_,e> <- model@documentation];
  map[str,str] newSource = ();
  list[str] splittedSource = [];
  str mergedSource = "";
  
  for (c <- files(model)) {
    source = readFile(c);
    source = replaceAll(source, "\r\n", "\n");
    splittedSource = split("\n", source);
    for (comment <- comments) {
      if (c.path == comment.path) {    
		  
		  // singleline comments
		  if (comment.begin.line == comment.end.line) {
		    beginLine = comment.begin.line - 1;
		    beginColumn = comment.begin.column;
		    endColumn = comment.end.column;
		    currentLine = splittedSource[beginLine];
		    replaceComment = substring(currentLine, beginColumn, endColumn);
		    splittedSource[beginLine] = replaceFirst(splittedSource[beginLine],replaceComment,replaceCommentWith);
		  }
  
		  // multiline comments
		  if (comment.begin.line != comment.end.line) {
		    beginLine = comment.begin.line - 1;
		    endLine = comment.end.line - 1;
		    beginColumn = comment.begin.column;
		    endColumn = comment.end.column;
		    for (l <- [beginLine..endLine + 1]) {                   
		      if ( l == beginLine ) {
		        replaceComment = substring(splittedSource[l], beginColumn, size(splittedSource[l]));
		        splittedSource[l] = replaceFirst(splittedSource[l],replaceComment,replaceCommentWith);
		      }
		      if ( l != beginLine && l != endLine ) { 
		        replaceComment = substring(splittedSource[l], 0, size(splittedSource[l]));
		        splittedSource[l] = replaceFirst(splittedSource[l],replaceComment,replaceCommentWith);
		      }
		      if ( l == endLine ) { 
		        replaceComment = substring(splittedSource[l], 0, endColumn);
		        splittedSource[l] = replaceFirst(splittedSource[l],replaceComment,replaceCommentWith);
		      }
		    }
		  }
      }
    }
    
    for (s <- splittedSource) { mergedSource = mergedSource + "\n" + s; }
    mergedSource = replaceFirst(mergedSource, "\n", "");
    newSource = newSource + (c.path:mergedSource);
    mergedSource = "";  
  }
  return newSource;
}