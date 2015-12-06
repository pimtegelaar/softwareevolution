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

public map[str,list[int]] getType1Clones(map[str,lrel[int,str]] duplicateLines) {
	
	// Put all listrelations in one list
	list[lrel[int,str]] lineList = toList(range(duplicateLines));
	lrel[int,str] mergedLineList = [];
	for (subList <- lineList) {
		for (listRel <- subList) {
			tuple[int,str] locFile = listRel;
			mergedLineList += locFile;
		}
	}
	
	// Group list by linenumber and file
	map[str,set[int]] dupLinesPerFile = ();
	dupLinesPerFile = index(invert(mergedLineList));
	
	// Sort LOCs
	map[str,list[int]] sortedDupLinesPerFile = ();
	for ( file <- dupLinesPerFile ) {
		sortedDupLinesPerFile += (file:sort(dupLinesPerFile[file]));
	}
	
	// sortedDupLinesPerFile: per file the line numbers
	// duplicateLines: per sourceline the line number / file name combination
	lrel[int,str] dupList = [];
	list[lrel[str,int,int]] cloneList = [];
	// Through all duplicate source lines
	for (srcLine <- duplicateLines) {
		dupList = duplicateLines[srcLine];
		
		// Through specific source line / source file
		for (dupLine <- dupList) {
			
			// Get the other duplicate line numbers for current file name
			list[int] dupLineNumbers = sortedDupLinesPerFile[dupLine[1]];
			println(dupLineNumbers);
			// Check whether preceeding or subsequent LOC exists
			int dupLineIndex = indexOf(dupLineNumbers, dupLine[0]);
			// Previous lines
			if ( dupLineIndex != 0 && dupLineNumbers[dupLineIndex-1] == dupLine[0] - 1 ) {
				println(dupLine[0]);
				println("check");
			}
		}
	}
	
	return ("a":[1,2,3]);
}