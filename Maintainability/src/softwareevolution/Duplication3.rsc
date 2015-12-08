module softwareevolution::Duplication3

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;

import List;
import ListRelation;
import Set;
import String;
import IO;
import Map;
import util::Math;

import softwareevolution::CommentCleanup;

public map[str,lrel[int,str]] getSourceDuplicates(M3 model) {
	
	// Get map of source without comments
	map[str,str] srcNoComments = eraseComments(model);
	
	int totalLines = 0;
	map[str,lrel[int,str]] srcMap = ();
	map[str,lrel[int,str]] duplicateLines = ();
	
	// Through all sources
	for (srcKey <- srcNoComments) {
		srcLOCs = srcNoComments[srcKey];
		srcClean = replaceAll(replaceAll(srcLOCs, "\r", ""), "\t", "");
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

public map[tuple[int,str],str] getType1Clones(map[str,lrel[int,str]] duplicateLines) {
	
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
	
	// Start looking for clones, from file perspective...
	list[lrel[str,int,int]] cloneList = [];
	for ( file <- enclosedLinesPerFile ) {
		println(file);
	}
	
	// Cleanup duplicate clone references
	
	return (());
}