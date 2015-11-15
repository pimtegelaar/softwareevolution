module softwareevolution::Duplication

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import List;
import String;
import IO;
import Map;
import softwareevolution::CommentCleanup;

/*
** Get source information
*/

public str getFile(loc class) {
	str fileSource = readFile(class);
	fileSource = replaceAll(fileSource, "\t", "");
	return fileSource;
}

public list[str] splitLines(str source) {
	list[str] splittedLines = split("\r\n", source);
	splittedLines = [ trim(s) | s <- splittedLines ];
	return splittedLines;
}

/*
** Check for duplicates in a sourcelist. 
** Assumption: input does not contain tabs or leading/trailing whitespaces.
** Problem: what is definition of duplicate? Code now probably identifies too much.
*/

public int amountDuplicates(list[str] sourceList) {
	int checkAmount = size(sourceList) - 6; // Can't check when 5 or less rows are left
	int fixedCheckAmount = size(sourceList) - 5; // The number of cases to compare the 6 lines against
	int initStartPos = 0;
	int initEndPos = 5;
	int checkStartPos = 0;
	int checkEndPos = 5;
	int duplicateAmount = 0;
	
	while (checkAmount > 0) {  	  
	  for (int n <- [0..fixedCheckAmount]) {		    	
	  	if (initStartPos == checkStartPos) { 
	  		checkStartPos += 1;
	  		checkEndPos += 1;
	  	}
	  	
	  	if (sourceList[initStartPos..initEndPos] == sourceList[checkStartPos..checkEndPos]) {
	  		duplicateAmount += 1;
	  	}  	
	  	checkStartPos += 1;
	    checkEndPos += 1;	  	
	  }
	  
	  initStartPos += 1;
	  initEndPos += 1;
	  checkStartPos = 0;
	  checkEndPos = 5;
	  checkAmount -= 1;
	}	
	return duplicateAmount;
}

/*
** Started working on the function to find duplicate code
** Base is the map of sourcecode (without comments)
** Todo: - think of efficient method to compare
**       - proper definition for duplicate?
**       - use proper Rascal functions to reduce cyclomatic complexity
*/

// produce sourceLineList, contains a map with the source for all model files
public list[map[int,str]] mapSourceLines(M3 model) {

	map[int,str] sourceMap = removeComments(model);
	list[str] sourceLines = [];
	list[map[int,str]] sourceSubList = [];
	list[map[int,str]] sourceLineList = [];

	for ( s <- [0..size(sourceMap)] ) {
		sourceLines = split("\r\n", sourceMap[s]);		
		sourceSubList = [ (l:sourceLines[l] | int l <- [0..size(sourceLines)]) ];
		sourceLineList = sourceLineList + sourceSubList;
	}

	return sourceLineList;
}

// check how much a line occurs in a sourceLineList
public int checkLOCOccurence(list[map[int,str]] source, str line) {
	
	int occurences = 0;
	
	// assumption is that source is a dence map
	for ( s <- [0..size(source)] ) {
		for ( l <- [0..size(source[s])] ) {
			if ( source[s][l] == line ) { occurences += 1; }
		}
	}
	
	return occurences;
}

// check whether group of 6 lines occurs in a sourceLineList
public int checkGroupLOCOccurence(list[map[int,str]] source, map[int,str] group) {
	
	int occurences = 0;
	str line1 = "";
	str line2 = "";
	str line3 = "";
	str line4 = "";
	str line5 = "";
	str line6 = "";
	
	// assumption is that source is a dence map
	for ( s <- [0..size(source)] ) {
		for ( l <- [0..size(source[s])] ) {
			if ( source[s][l] == group[0] ) { 
				line1 = source[s][l];
				line2 = source[s][l+1];
				line3 = source[s][l+2];
				line4 = source[s][l+3];
				line5 = source[s][l+4];
				line6 = source[s][l+5];
				if  ( line1 == group[0]
				   && line2 == group[1]
				   && line3 == group[2]
				   && line4 == group[3]
				   && line5 == group[4]
				   && line6 == group[5]
				    ) {
					println("duplicate of 6 found");
					println(line1);
					println(line2);
					println(line3);
					println(line4);
					println(line5);
					println(line6);
					occurences += 6;   
				}
				line1 = "";
				line2 = "";
				line3 = "";
				line4 = "";
				line5 = "";
				line6 = "";
			}
		}
	}
	
	return occurences;
}

// calculate the percentage of duplicates
// todo: method to compare the map content
public list[map[int,int]] pD(M3 model) {
	
	int percentageDuplicates = 0;
	int duplicateLineAmount = 0;
	list[map[int,str]] sourceLineMap = mapSourceLines(model);
	int occurences = 0;
	map[int,int] occurenceMap = ();
	list[map[int,int]] occurenceList = [];
	map[int,str] compareMap = ();
	
	//int totalLOC = (0 | it + size(sourceLineMap[l]) | int l <- [0..size(sourceLineMap)]);
	//int possibleCheckAmount = totalLOC - (size(sourceLineMap) * 5); // each file means 5 less checks
	
	// for all sourcelines check number of occurences in code
	for ( f <- [0..size(sourceLineMap)] ) {
		for ( l <- [0..size(sourceLineMap[f])] ) {
			occurences = checkLOCOccurence(sourceLineMap, sourceLineMap[f][l]);
			//if (sourceLineMap[f][l] == "\t\tdoingTheSameThing = 1;") { println(occurences); }			
			occurenceMap = occurenceMap + (l:occurences);			
		}
		occurenceList = occurenceList + occurenceMap;
		occurenceMap = ();
	}
	
	// only check for lines that occur more then once
	for ( f <- [0..size(sourceLineMap)] ) {
		for ( l <- [0..size(sourceLineMap[f])] ) {
			if ( occurenceList[f][l] > 1 ) {
				compareMap = ( 0:sourceLineMap[f][l]) + (1:sourceLineMap[f][l+1])
				             + (2:sourceLineMap[f][l+2]) + (3:sourceLineMap[f][l+3])
				             + (4:sourceLineMap[f][l+4]) + (5:sourceLineMap[f][l+5]);
				duplicateLineAmount = duplicateLineAmount + checkGroupLOCOccurence(sourceLineMap, compareMap);
			}
		}
	}	
	
	// start comparing sets of 6 sourcelines with the rest of the sourcecode
	
	//return percentageDuplicates;
	return occurenceList;
}