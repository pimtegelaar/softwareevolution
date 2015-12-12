module softwareevolution::Duplication3

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import List;
import ListRelation;
import Set;
import String;
import Map;
import IO;

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

/** Generate a map of files with their duplicate lines */
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

/** Create flat source map, to lookup duplicate source lines, returns source line code */
public map[tuple[int,str],str] getSourceLookupMap(map[str,lrel[int,str]] duplicateLines) {
	map[tuple[int,str],str] sourceLookupMap = ();	
	for (dupLineReferences <- duplicateLines ) {
		for ( dupLineReference <- duplicateLines[dupLineReferences] ) {
			sourceLookupMap += (dupLineReference:dupLineReferences);
		}
	}
	return sourceLookupMap;
}

/** All duplicates listrelations in one list */
public lrel[int,str] mergeLines(map[str,lrel[int,str]] duplicateLines) {
	list[lrel[int,str]] dupLineList = toList(range(duplicateLines));
	lrel[int,str] mergedLineList = [];
	for (subDubList <- dupLineList) {
		for (listRelDub <- subDubList) {
			tuple[int,str] locFile = listRelDub;
			mergedLineList += locFile;
		}
	}	
	return mergedLineList;
}

/** Generate map with sorted list of line numbers from duplicate lines */
public map[str,list[int]] sortDupLinesPerFile(lrel[int,str] lineList) {
	// Group list by linenumber and file
	map[str,set[int]] dupLinesPerFile = ();
	dupLinesPerFile = index(invert(lineList));
	
	// Sort LOCs
	map[str,list[int]] sortedDupLinesPerFile = ();
	for ( file <- dupLinesPerFile ) {
		sortedDupLinesPerFile += (file:sort(dupLinesPerFile[file]));
	}
	
	return sortedDupLinesPerFile;
}

/** Generate map by file name with enclosed start line numbers / end line numbers */
public map[str,lrel[int,int]] getEnclosedLinesPerFile(map[str,list[int]] sortedDupLines) {
	map[str,lrel[int,int]] enclosedLinesPerFile = ();
	for ( file <- sortedDupLines ) {	
		list[int] lineValues = sortedDupLines[file];
		list[int] lineIndexes = index(sortedDupLines[file]);
		int currLineIndex = 0;
		int lineIndex = size(lineIndexes);
		
		// Create list with sublists of sequencing line numbers
		list[int] subLineList = [];
		list[list[int]] groupLineList = [];
		while ( currLineIndex < lineIndex ) {
			if (size(subLineList) == 0 ) { subLineList = [lineValues[currLineIndex]]; }
			else {
				int currValue = lineValues[currLineIndex];
				int lastValue = subLineList[size(subLineList)-1];
				if ( currValue - lastValue != 1 ) {
					groupLineList += [subLineList];
					subLineList = [];
					subLineList = [currValue];
				}
				else { subLineList += currValue; }
			}
			currLineIndex += 1;
		}		
		groupLineList += [subLineList];

		// Create the list with start- and end line numbers
		lrel[int,int] dupLineRel = [];
		for ( fileLineNumbers <- groupLineList ) {
			dupLineRel += <fileLineNumbers[0],fileLineNumbers[size(fileLineNumbers)-1]>;
		}
		enclosedLinesPerFile += (file:dupLineRel);
		dupLineRel = [];
	}
	return enclosedLinesPerFile;
}

/** Create flat source map, to lookup duplicate source lines, returns enclosed source lines tuple */
public map[tuple[int,str],tuple[int,int]] getEnclosedLookupMap( map[str,lrel[int,str]] duplicateLines
                                                               , map[str,lrel[int,int]] enclosedLines) {
	map[tuple[int,str],tuple[int,int]] enclosedLookupMap = ();
	for (dupLineReferences <- duplicateLines ) {
		for ( dupLineReference <- duplicateLines[dupLineReferences] ) {
			int currLine = dupLineReference[0];
			for ( subLines <- enclosedLines[dupLineReference[1]] ) {
				if ( currLine >= subLines[0] && currLine <= subLines[1] ) {
					enclosedLookupMap += (dupLineReference:<subLines[0],subLines[1]>);
					break;
				}
			}
		}
	}
	return enclosedLookupMap;
}

/** Create flat source map, to lookup which clones are possible for specific enclosed lines / file */
public map[tuple[int,int,str],lrel[int,int,str]] getPossibleCloneLookupMap( map[str,lrel[int,str]] duplicateLines
                                                                          , map[tuple[int,str],str] srcLookupMap 
                                                                          , map[str,lrel[int,int]] enclosedLinesPerFile
                                                                          , map[tuple[int,str],tuple[int,int]] enclosedLookupMap ) {	
	map[tuple[int,int,str],lrel[int,int,str]] possibleClonedLines = ();
	// Go through enclosed lines, build clone lookup structure from there
	for ( enclosedLineFile <- enclosedLinesPerFile ) {	
		for ( enclosedLines <- enclosedLinesPerFile[enclosedLineFile] ) {		    
		    // Through every single source line of the enclosed lines
		    for ( currSrcLineNo <- [enclosedLines[0]..enclosedLines[1] + 1] ) {
		    	str currSrcLine = srcLookupMap[<currSrcLineNo,enclosedLineFile>];
		    	// For the current line, check the duplicate lines
		    	tuple[int,int] refLine;
		    	for ( dupRefLine <- duplicateLines[currSrcLine] ) {
		    		refLine = enclosedLookupMap[dupRefLine];
		    		// Merge if value is already in list, otherwise set to initial value
					if ( possibleClonedLines[<enclosedLines[0],enclosedLines[1],enclosedLineFile>]? ) {
						possibleClonedLines[<enclosedLines[0],enclosedLines[1],enclosedLineFile>] += [<refLine[0],refLine[1],dupRefLine[1]>];
					}
					else {
						possibleClonedLines[<enclosedLines[0],enclosedLines[1],enclosedLineFile>] = [<refLine[0],refLine[1],dupRefLine[1]>]; 
					}
		    	}
		    }
		}
	}
	
	// Cleanup possible clones list
	map[tuple[int,int,str],lrel[int,int,str]] possibleClonedLinesCleaned = ();
	for ( possibleClone <- possibleClonedLines ) {
		lrel[int,int,str] listSubClones = [];
		for ( subClone <- possibleClonedLines[possibleClone] ) {	
			if ( possibleClonedLinesCleaned[possibleClone]? ) {
				bool cloneAlreadyInList = false;
				if ( [subClone] <= listSubClones ) { cloneAlreadyInList = true; }
				// Only add if subClone is not already in the map
				if ( cloneAlreadyInList == false ) {
					possibleClonedLinesCleaned[possibleClone] += [subClone];
					listSubClones += [subClone];
				}
			}
			else {
				possibleClonedLinesCleaned[possibleClone] = [subClone];
				listSubClones = [subClone];
			}
		}
		listSubClones = [];
	}
	return (possibleClonedLinesCleaned);
}

/** Generate list of type 1 clone pairs */
public list[lrel[int,int,str]] getType1Clones(M3 model, int minCloneSize) {
	
	map[str,lrel[int,str]] srcDuplicates = getSourceDuplicates(model);
	map[tuple[int,str],str] srcLookupMap = getSourceLookupMap(srcDuplicates);
	lrel[int,str] mergedLineList = mergeLines(srcDuplicates);
	map[str,list[int]] sortedDupLinesPerFile = sortDupLinesPerFile(mergedLineList);
	map[str,lrel[int,int]] enclosedLinesPerFile = getEnclosedLinesPerFile(sortedDupLinesPerFile);
	map[tuple[int,str],tuple[int,int]] enclosedLookupMap = getEnclosedLookupMap( srcDuplicates
	                                                                           , enclosedLinesPerFile );
	map[tuple[int,int,str],lrel[int,int,str]] possibleClonesLookupMap = getPossibleCloneLookupMap( srcDuplicates
	                                                                                             , srcLookupMap
	                                                                                             , enclosedLinesPerFile
	                                                                                             , enclosedLookupMap
	                                                                                             );
	
	// Start looking for clones, from file perspective
	list[lrel[int,int,str]] cloneList = [];
	for ( file <- enclosedLinesPerFile ) {
		for ( enclosedLines <- enclosedLinesPerFile[file] ) {
			int amountLines = enclosedLines[1] - enclosedLines[0] + 1;	
			
			// Single line clones (look from current enclosed lines perspective)
								
			if ( amountLines == 1 && minCloneSize == 1 ) {
				str singleSourceLine = srcLookupMap[<enclosedLines[0],file>];			
				// Only look through the lines that exist in the possibleClones map
				if ( possibleClonesLookupMap[<enclosedLines[0],enclosedLines[1],file>]? ) {
					str refSourceLine = "";
					for ( possibleClones <- possibleClonesLookupMap[<enclosedLines[0],enclosedLines[1],file>] ) {
						refSourceLine = srcLookupMap[<possibleClones[0],possibleClones[2]>];
						if ( singleSourceLine == refSourceLine ) {
							cloneList += [[ <enclosedLines[0], enclosedLines[0], file>
				                          , <possibleClones[0], possibleClones[0], possibleClones[2]>
				                         ]];
						}
					}
				}
			}
			
			// Multi row clones	(also contains single line check for ref lines)
			
			// Applicable source lines to lists
			list[str] orgSrcLines = [ srcLookupMap[<n,file>] | n <- [enclosedLines[0]..enclosedLines[1] + 1] ];				
			lrel[int,int,str] possibleClonesList = possibleClonesLookupMap[<enclosedLines[0],enclosedLines[1],file>];
			
			// Create map to lookup original source line numbers
			int orgLineIndex = 0;
			map[int,int] orgIndexToLineNo = ();
			for ( lineNo <- [enclosedLines[0]..enclosedLines[1] + 1] ) {
				orgIndexToLineNo[orgLineIndex] = lineNo; 
				orgLineIndex += 1;
			}
			orgLineIndex = 0;
			
			// Get source lines from reference file
			map[tuple[int,int,str],list[str]] refSrcLines = ();
			for ( possibleCloneLines <- possibleClonesList ) {
				refList = [srcLookupMap[<n,possibleCloneLines[2]>] | n <- [possibleCloneLines[0]..possibleCloneLines[1] + 1]];
				refSrcLines[<possibleCloneLines[0],possibleCloneLines[1],possibleCloneLines[2]>] = refList;
			}
			
			// Go through the possible clone list
			for ( possibleCloneLines <- possibleClonesList ) {
				int amountRefLines = possibleCloneLines[1] - possibleCloneLines[0] + 1;
				
				// Section for single line reference cases
				if ( amountRefLines == 1 && minCloneSize == 1 ) {
					int orgLineIndexSub = 0;
					for ( orgSrcLine <- orgSrcLines ) {
						int orgLineNo = orgIndexToLineNo[orgLineIndexSub];
						if ( [orgSrcLine] == refSrcLines[possibleCloneLines] ) {
							cloneList += [[ <orgLineNo,orgLineNo,file>
							              , <possibleCloneLines[0],possibleCloneLines[1],possibleCloneLines[2]>
							             ]];
						}
						orgLineIndexSub += 1;
					}
					orgLineIndexSub = 0;
				}
				
				// Section for multi line reference cases (depends on size parameter)
				if ( amountLines >= minCloneSize && amountRefLines >= minCloneSize ) {				
					// Try to find the first match
					bool refLineMatched = false;
					int orgLinePos = 0;
					int refLinePos = 0;
					for ( refLineNo <- [possibleCloneLines[0]..possibleCloneLines[1] + 1] ) {
						int orgLineIndexSub = 0;	
						for ( orgSrcLine <- orgSrcLines ) {
							int orgLineNo = orgIndexToLineNo[orgLineIndexSub];
							// A match is detected, break out of the loop
							if ( orgSrcLine == srcLookupMap[<refLineNo,possibleCloneLines[2]>] ) { 
								refLineMatched = true;
								orgLinePos = orgLineNo;
								refLinePos = refLineNo;
								break; 
							}
							orgLineIndexSub += 1;
						}
						if ( refLineMatched ) { break; }
						orgLineIndexSub = 0;
					}
					refLineMatched = false;
					
					// Compare next lines, starting from initial match, as long as they are equal
					int nextOrgLinePos = orgLinePos + 1;
					int nextRefLinePos = refLinePos + 1;
					str nextOrgSrcLine = "";
					str nextRefSrcLine = "";
					while ( nextRefLinePos < possibleCloneLines[1] + 1 ) {
						if ( srcLookupMap[<nextOrgLinePos,file>]? ) {
							nextOrgSrcLine = srcLookupMap[<nextOrgLinePos,file>];
						}
						else { break; }
						if ( srcLookupMap[<nextRefLinePos,possibleCloneLines[2]>]? ) {
							nextRefSrcLine = srcLookupMap[<nextRefLinePos,possibleCloneLines[2]>];
						}
						else { break; }
						// Continue as long as matches are found
						if ( nextOrgSrcLine == nextRefSrcLine ) {
							nextOrgLinePos += 1;
							nextRefLinePos += 1;
						}
						else { break; }											
					}
					int endOrgLinePos = nextOrgLinePos - 1;
					int endRefLinePos = nextRefLinePos - 1;
					
					// Write the detected clone to the cloneList
					cloneList += [[ <orgLinePos,endOrgLinePos,file>
							      , <refLinePos,endRefLinePos,possibleCloneLines[2]>
							     ]];
				}
			}
		}
	}
	
	// Cleanup duplicate clone references
	
	return cloneList;
}