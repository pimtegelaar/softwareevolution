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
		
		//println(file);
		//println(lineValues);
		//println(lineIndexes);
		
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
		
		//println(groupLineList);

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
		    	//println("file");
				//println(enclosedLineFile);
				//println("enclosed lines");
				//println(enclosedLines);
		    	//println("current Line number");
		    	//println(currSrcLineNo);
		    	//println("current Source line");
		    	//println(currSrcLine);
		    	// For the current line, check the duplicate lines
		    	tuple[int,int] refLine;
		    	for ( dupRefLine <- duplicateLines[currSrcLine] ) {
		    		refLine = enclosedLookupMap[dupRefLine];
		    		//println("dup");
		    		//println(dupRefLine);
		    		//println("ref");
		    		//println(refLine);
		    		// Merge if value is already in list, otherwise set to initial value
					if ( possibleClonedLines[<enclosedLines[0],enclosedLines[1],enclosedLineFile>]? ) {
						possibleClonedLines[<enclosedLines[0],enclosedLines[1],enclosedLineFile>] += [<refLine[0],refLine[1],dupRefLine[1]>];
					}
					else {
						possibleClonedLines[<enclosedLines[0],enclosedLines[1],enclosedLineFile>] = [<refLine[0],refLine[1],dupRefLine[1]>]; 
					}
					//println("clone key");
					//println(<enclosedLines[0],enclosedLines[1],enclosedLineFile>);
					//println("current clone map");
					//println(possibleClonedLines[<enclosedLines[0],enclosedLines[1],enclosedLineFile>]);
		    	}
		    }
		}
	}
	
	// Cleanup possible clones list
	map[tuple[int,int,str],lrel[int,int,str]] possibleClonedLinesCleaned = ();
	for ( possibleClone <- possibleClonedLines ) {
		lrel[int,int,str] listSubClones = [];
		for ( subClone <- possibleClonedLines[possibleClone] ) {		
			// Only continue when the subClone is different from the possibleClone
			if ( possibleClone != subClone ) {		
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
		}
		listSubClones = [];
	}
	return (possibleClonedLinesCleaned);
}

/** Generate list of type 1 clone pairs */
public list[lrel[str,int,int]] getType1Clones(M3 model, int minCloneSize) {
	
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
	list[lrel[str,int,int]] cloneList = [];
	for ( file <- enclosedLinesPerFile ) {
		for ( enclosedLines <- enclosedLinesPerFile[file] ) {
			int amountLines = enclosedLines[1] - enclosedLines[0] + 1;	
			
			// Single line clones
			if ( minCloneSize == 1 ) {
				str singleSourceLine = srcLookupMap[<enclosedLines[0],file>];
				
				println(file);
				println("org line");
				println(singleSourceLine);
				
				// Only look through the lines that exist in the possibleClones map
				if ( possibleClonesLookupMap[<enclosedLines[0],enclosedLines[1],file>]? ) {
					str refSourceLine = "";
					for ( possibleClones <- possibleClonesLookupMap[<enclosedLines[0],enclosedLines[1],file>] ) {
						refSourceLine = srcLookupMap[<possibleClones[0],possibleClones[2]>];
						if ( singleSourceLine == refSourceLine ) {
							cloneList += [[ <file, enclosedLines[0], enclosedLines[0]>
				                          , <possibleClones[2], possibleClones[0], possibleClones[0]>
				                         ]];
						}
					}
				}
			}
			
			//// Multi row clones
			//if ( 0 >= minCloneSize ) {
			//	
			//	// Orginal enclosed source lines in a list
			//	list[tuple[int,str]] orgSrcLines = [];
			//	for ( lineNo <- [enclosedLines[0]..enclosedLines[1] + 1] ) {
			//		orgSrcLines = orgSrcLines + <lineNo,srcLookupMap[<lineNo,file>]>;					
			//	}
			//	
			//	// Check all reference lines against the current line list
			//	list[tuple[int,str]] refSrcLines = [];
			//	for ( possibleClonesFile <- possibleClonedLines ) {
			//		for ( checkLines <- possibleClonedLines[possibleClonesFile] ) {
			//			// Check the reference source lines
			//			for ( lineNo <- [checkLines[0]..checkLines[1] + 1] ) {
			//				refSrcLines += <lineNo,srcLookupMap[<lineNo,possibleClonesFile>]>;
			//			}
			//			
			//			// Try to match the referenced lines with the original lines
			//			for ( refSrcLine <- refSrcLines ) {
			//				// Is referenced line part of original lines?
			//				if ( [refSrcLine[1]] <= range(orgSrcLines) ) {
			//					for ( orgSrcLine <- orgSrcLines ) {
			//						if (orgSrcLine[1] == refSrcLine[1]) {
			//							int startOrgLineNo = orgSrcLine[0];
			//							int startRefLineNo = refSrcLine[0];
			//							//println("start org line no");
			//							//println(startOrgLineNo);
			//							//println("start ref line no");
			//							//println(startRefLineNo);
			//							int cloneLineAmount = 1;
			//							// Try to detect largest clone possible
			//							while ( cloneLineAmount < minCloneSize ) {
			//								//int nextOrgLineNo = orgSrcLine[0] + cloneLineAmount;
			//								//int nextRefLineNo = refSrcLine[0] + cloneLineAmount;
			//								//str nextOrgSrcLine = srcLookupMap[<nextOrgLineNo,file>];
			//								//str nextRefSrcLine = srcLookupMap[<nextRefLineNo,possibleClonesFile>];
			//								//println("next org line no");
			//								//println(nextOrgLineNo);
			//								//println("next ref line no");
			//								//println(nextRefLineNo);
			//								cloneLineAmount += 1;
			//								break;
			//							}										
			//						}
			//					}
			//				}
			//			}
			//			
			//			refSrcLines = [];						
			//		}
			//	}
			//}
		}
	}
	
	// Cleanup duplicate clone references
	
	return cloneList;
}