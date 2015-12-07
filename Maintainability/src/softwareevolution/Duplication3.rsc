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

public map[str, tuple[int,int]] getType1Clones(map[str,lrel[int,str]] duplicateLines) {
	
	// Put all listrelations in one list
	list[lrel[int,str]] dupLineList = toList(range(duplicateLines));
	lrel[int,str] mergedLineList = [];
	for (subDubList <- dupLineList) {
		for (listRelDub <- subDubList) {
			tuple[int,str] locFile = listRelDub;
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
	
	// Index with file name / start line number / end line number
	map[str, tuple[int,int]] enclosedLinesPerFile = ();
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
		for ( fileLineNumbers <- groupLineList ) {
			enclosedLinesPerFile = enclosedLinesPerFile + (file:<fileLineNumbers[0],fileLineNumbers[size(fileLineNumbers)-1]>);
		}
	}
	
	//println(enclosedLinesPerFile);
	
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
			
			//println("specific");
			//println(dupLine);
			//println("general");
			//println(dupList);
			
			// Preceeding or subsequent indexes
			
			//println(dupLineNumbers);
			//println(dupLine);
			//println(indexOf(dupLineNumbers, dupLine[0]));
			
			int dupLineIndex = indexOf(dupLineNumbers, dupLine[0]);
			int decreaseLineIndex = dupLineIndex - 1;
			int prevLine = 1;
			int increaseLineIndex = dupLineIndex + 1;
			int nextLine = 1;
			bool prevLineExists = false;
			bool nextLineExists = false;
			
			//println(srcLine);
			//println(dupLineNumbers[decreaseLineIndex]);
			//println(nextLineExists);
			//println(dupLineNumbers[increaseLineIndex]);
			
			if (dupLineIndex != 0 && dupLineNumbers[decreaseLineIndex]?) {
				prevLineExists = true;
			}
			
			if (dupLineNumbers[increaseLineIndex]?) {
				nextLineExists = true;
			}
			
			if (prevLineExists == false && nextLineExists == false) {
				println("isolated line");
			}
			
			// Previous lines
			while ( dupLineIndex != 0 && dupLineNumbers[decreaseLineIndex] == dupLine[0]-prevLine ) {
				//println(dupLine[0]-prevLine);
				//println(dupList);
				
				//for ( int n <- [0..size(dupList)] ) {
				//	println(srcLine);
				//}
				
				decreaseLineIndex -= 1;
				prevLine += 1;
			}
		}
	}
	
	return (enclosedLinesPerFile);
}