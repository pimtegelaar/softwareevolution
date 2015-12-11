module softwareevolution::Duplication3

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import List;
import ListRelation;
import Set;
import String;
import IO;
import Map;
import util::Math;

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

public map[str,lrel[int,str]] getSourceDuplicates(M3 model) {
	
	// Get map of source without comments
	map[str,str] srcNoComments = replaceComments(model," ");
	
	int totalLines = 0;
	map[str,lrel[int,str]] srcMap = ();
	map[str,lrel[int,str]] duplicateLines = ();
	
	// Through all sources
	for (srcKey <- srcNoComments) {
		srcLOCs = srcNoComments[srcKey];
		srcClean = replaceAll(srcLOCs, "\t", "");
		srcLines = split("\n", srcClean);
		srcLines = [ trim(line) | line <- srcLines ];
		int i = 0;
		
	    // Through source lines
	  	for(line <- srcLines) {
	      i += 1;
	      if (line != "") {
	      	lrel[int,str] lineOccurences = [];
	    	  
	    	// append srcMap value if line already exists
	    	if (srcMap[line]?) {
	    	  lineOccurences += srcMap[line];
	    	}
	      	
	      	// set srcMap value
	      	srcMap[line] = lineOccurences + <i,srcKey>;
	      }
	  	}
	  	totalLines +=i;	
	}
	
	// Map of sourcelines and occurences in list relations (line number/file)
	duplicateLines = (line:sort(srcMap[line]) | line <- srcMap, size(srcMap[line]) > 1 && line != "{" && line != "}"); 
	
	return duplicateLines;	
}

public list[lrel[str,int,int]] getType1Clones(map[str,lrel[int,str]] duplicateLines, int minCloneSize) {
	
	// Put all listrelations in one list
	list[lrel[int,str]] dupLineList = toList(range(duplicateLines));
	lrel[int,str] mergedLineList = [];
	for (subDubList <- dupLineList) {
		for (listRelDub <- subDubList) {
			tuple[int,str] locFile = listRelDub;
			mergedLineList += locFile;
		}
	}
	
	//println(mergedLineList);
	
	// Group list by linenumber and file
	map[str,set[int]] dupLinesPerFile = ();
	dupLinesPerFile = index(invert(mergedLineList));
	
	// Sort LOCs
	map[str,list[int]] sortedDupLinesPerFile = ();
	for ( file <- dupLinesPerFile ) {
		sortedDupLinesPerFile += (file:sort(dupLinesPerFile[file]));
	}

    //println(sortedDupLinesPerFile);

    // Structures for creating index with file name / start line numbers / end line numbers
	map[str,lrel[int,int]] enclosedLinesPerFile = ();
	for ( file <- sortedDupLinesPerFile ) {
		
		list[int] lineValues = sortedDupLinesPerFile[file];
		list[int] lineIndexes = index(sortedDupLinesPerFile[file]);
		list[list[int]] groupLineList = [];
		list[int] subLineList = [];
		int lineIndex = size(lineIndexes);
		int currLineIndex = 0;
		
		//println(file);
		//println(lineValues);
		//println(lineIndexes);
		
		// Create list with sublists of sequencing line numbers
		while ( currLineIndex < lineIndex ) {
			if (size(subLineList) == 0 ) { 
				subLineList = [lineValues[currLineIndex]];
			}
			else {
				int currValue = lineValues[currLineIndex];
				int lastValue = subLineList[size(subLineList)-1];
				if ( currValue - lastValue != 1 ) {
					groupLineList = groupLineList + [subLineList];
					subLineList = [];
					subLineList = [currValue];
				}
				else { subLineList = subLineList + currValue; }
			}
			currLineIndex += 1;
		}		
		groupLineList = groupLineList + [subLineList];
		
		//println("group");
		//println(groupLineList);

		// Create list with start- and end line numbers
		lrel[int,int] dupLineRel = [];

		for ( fileLineNumbers <- groupLineList ) {
			dupLineRel = dupLineRel + <fileLineNumbers[0],fileLineNumbers[size(fileLineNumbers)-1]>;
		}
		enclosedLinesPerFile = enclosedLinesPerFile + (file:dupLineRel);
		dupLineRel = [];
	}
	
	//println(enclosedLinesPerFile);
	
	// Create a flat source map, to lookup the relevant source lines
	map[tuple[int,str],str] sourceLookupMap = ();
	for (dupLineReferences <- duplicateLines ) {
		for ( dupLineReference <- duplicateLines[dupLineReferences] ) {
			sourceLookupMap = sourceLookupMap + (dupLineReference:dupLineReferences);
		}
	}
	
	//println(sourceLookupMap);
	
	// Start looking for clones, from file perspective
	list[lrel[str,int,int]] cloneList = [];
	for ( file <- enclosedLinesPerFile ) {
		// For each enclosed group determine the source lines for current file
		for ( enclosedLines <- enclosedLinesPerFile[file] ) {
			int amountLines = enclosedLines[1] - enclosedLines[0] + 1;
			int lineIterator = 0;
			
			// Multi row duplicates
			if ( amountLines >= minCloneSize ) {
				
				// Orginal source lines in a list
				list[str] orgSrcLines = [];
				for ( lineNo <- [enclosedLines[0]..enclosedLines[1] + 1] ) {
					orgSrcLines = orgSrcLines + sourceLookupMap[<lineNo,file>];					
				}
				
				println(file);
				println(enclosedLines);
				println(orgSrcLines);
				
				// List of enclosed lines in other files with matching source lines
				
				map[str,lrel[int,int]] possibleClonedLines = ();
				for ( orgSrcLine <- orgSrcLines ) {
					lrel [int,str] dupLines = duplicateLines[orgSrcLine];
					//lrel [int,str] clonedLines = [];
					//for ( dupLine <- dupLines ) {
					//	println(dupLine);
					//}		
					println(dupLines);			
				}
			}
			
			// Single line duplicates
			if ( minCloneSize == 1 ) {
				str singleSourceLine = sourceLookupMap[<enclosedLines[0],file>];
				// Go through duplicates lines in other files
				for ( duplicateLine <- duplicateLines[singleSourceLine] ) {
					// When source line is the same, we have a single row clone
					if  ( singleSourceLine == sourceLookupMap[duplicateLine] 
					   && duplicateLine[1] != file
					    ) {
						cloneList = cloneList + [[ <file, enclosedLines[1], enclosedLines[1]>
						                         , <duplicateLine[1], duplicateLine[0], duplicateLine[0]>
						                        ]];
					}
				}
			}
		}
	}
	
	// Cleanup duplicate clone references
	
	return (cloneList);
}