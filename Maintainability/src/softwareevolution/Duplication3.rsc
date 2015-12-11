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

private map[str,lrel[int,str]] getSourceDuplicates(M3 model) {
	
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

// Put all duplicates listrelations in one list
private lrel[int,str] mergeLines(map[str,lrel[int,str]] duplicateLines) {
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

// Generate map with sorted list of line numbers from duplicate lines
private map[str,list[int]] sortDupLinesPerFile(lrel[int,str] lineList) {
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

// Generate map by file name with enclosed start line numbers / end line numbers
private map[str,lrel[int,int]] getEnclosedLinesPerFile(map[str,list[int]] sortedDupLines) {
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
			if (size(subLineList) == 0 ) { 
				subLineList = [lineValues[currLineIndex]];
			}
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
		
		//println("group");
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

public list[lrel[str,int,int]] getType1Clones(M3 model, int minCloneSize) {
	
	map[str,lrel[int,str]] srcDuplicates = getSourceDuplicates(model);
	lrel[int,str] mergedLineList = mergeLines(srcDuplicates);
	//println(mergedLineList);
	
	map[str,list[int]] sortedDupLinesPerFile = sortDupLinesPerFile(mergedLineList);
    //println(sortedDupLinesPerFile);

	map[str,lrel[int,int]] enclosedLinesPerFile = getEnclosedLinesPerFile(sortedDupLinesPerFile);
	println(enclosedLinesPerFile);
	
	// Create flat source maps, to lookup the relevant source lines
	map[tuple[int,str],str] sourceLookupMap = ();
	map[tuple[int,str],tuple[int,int]] enclosedLookupMap = ();
	
	for (dupLineReferences <- srcDuplicates ) {
		for ( dupLineReference <- srcDuplicates[dupLineReferences] ) {
			sourceLookupMap = sourceLookupMap + (dupLineReference:dupLineReferences);
			int currLine = dupLineReference[0];
			for ( subLines <- enclosedLinesPerFile[dupLineReference[1]] ) {
				if ( currLine >= subLines[0] && currLine <= subLines[1] ) {
					enclosedLookupMap = enclosedLookupMap + (dupLineReference:<subLines[0],subLines[1]>);
					break;
				}
			}
		}
	}
	
	//println(sourceLookupMap);
	//println(enclosedLookupMap);
	
	// Start looking for clones, from file perspective
	list[lrel[str,int,int]] cloneList = [];
	for ( file <- enclosedLinesPerFile ) {
		// For each enclosed group determine the source lines for current file
		for ( enclosedLines <- enclosedLinesPerFile[file] ) {
			int amountLines = enclosedLines[1] - enclosedLines[0] + 1;
			
			// Multi row clones
			if ( amountLines >= minCloneSize ) {
				
				// Orginal enclosed source lines in a list
				list[tuple[int,str]] orgSrcLines = [];
				for ( lineNo <- [enclosedLines[0]..enclosedLines[1] + 1] ) {
					orgSrcLines = orgSrcLines + <lineNo,sourceLookupMap[<lineNo,file>]>;					
				}
				
				//println("file");
				//println(file);
				//println("original line numbers");
				//println(enclosedLines);
				//println("original source lines");
				//println(orgSrcLines);
				
				// List of enclosed lines in all files with matching source lines
				map[str,lrel[int,int]] possibleClonedLines = ();
				for ( orgSrcLine <- orgSrcLines ) {
					lrel [int,str] dupLines = srcDuplicates[orgSrcLine[1]];					
					// Check all references in files 
					for ( dupLine <- dupLines ) {
						tuple[int,int] currLines = enclosedLookupMap[dupLine];
						list[int] refLines = [currLines[0],currLines[1]];
						list[int] allRefLines = [];
						// Create a list with references that must be checked, exclude original refs
						if ( currLines != <enclosedLines[0],enclosedLines[1]> ) {						
							// Merge if value is already in list, otherwise set to initial value
							if ( possibleClonedLines[dupLine[1]]? ) {
								allRefLines = carrier(possibleClonedLines[dupLine[1]]);
								// If it is already in the list, add it
								if ( refLines <= allRefLines == false ) { 
									possibleClonedLines[dupLine[1]] += [currLines];
								}
							}
							else { possibleClonedLines[dupLine[1]] = [currLines]; }
						}
					}
				}

				//println("possible clones");
				//println(possibleClonedLines);
				
				// Check all reference lines against the current line list
				list[tuple[int,str]] refSrcLines = [];
				for ( possibleClonesFile <- possibleClonedLines ) {
					for ( checkLines <- possibleClonedLines[possibleClonesFile] ) {
						// Check the reference source lines
						for ( lineNo <- [checkLines[0]..checkLines[1] + 1] ) {
							refSrcLines += <lineNo,sourceLookupMap[<lineNo,possibleClonesFile>]>;
						}

						//println("org file");
						//println(file);
						//println("ref file");
						//println(possibleClonesFile);
						//println("ref list");
						//println(refSrcLines);
						
						// Try to match the referenced lines with the original lines
						for ( refSrcLine <- refSrcLines ) {
							// Is referenced line part of original lines?
							if ( [refSrcLine[1]] <= range(orgSrcLines) ) {
								for ( orgSrcLine <- orgSrcLines ) {
									if (orgSrcLine[1] == refSrcLine[1]) {
										int startOrgLineNo = orgSrcLine[0];
										int startRefLineNo = refSrcLine[0];
										//println("start org line no");
										//println(startOrgLineNo);
										//println("start ref line no");
										//println(startRefLineNo);
										int cloneLineAmount = 1;
										// Try to detect largest clone possible
										while ( cloneLineAmount < minCloneSize ) {
											//int nextOrgLineNo = orgSrcLine[0] + cloneLineAmount;
											//int nextRefLineNo = refSrcLine[0] + cloneLineAmount;
											//str nextOrgSrcLine = sourceLookupMap[<nextOrgLineNo,file>];
											//str nextRefSrcLine = sourceLookupMap[<nextRefLineNo,possibleClonesFile>];
											//println("next org line no");
											//println(nextOrgLineNo);
											//println("next ref line no");
											//println(nextRefLineNo);
											cloneLineAmount += 1;
											break;
										}										
									}
								}
							}
						}
						
						refSrcLines = [];						
					}
				}
			}
			
			// Single line clones
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