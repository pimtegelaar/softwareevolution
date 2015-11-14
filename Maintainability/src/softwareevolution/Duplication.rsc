module softwareevolution::Duplication

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import List;
import String;
import IO;
import Map;

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

// check how much a line occures in a sourceLineList
public int checkLineOccurence(list[map[int,str]] source, str line) {
	
	int occurences = 0;
	
	// assumption is that source is a dence map
	for ( s <- [0..size(source)] ) {
		for ( l <- [0..size(source[s])] ) {
			if ( source[s][l] == line ) { occurences += 1; }
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
	list[map[int,int]] occurenceSubList = [];
	list[map[int,int]] occurenceList = [];
	
	int totalLOC = (0 | it + size(sourceLineMap[l]) | int l <- [0..size(sourceLineMap)]);
	int possibleCheckAmount = totalLOC - (size(sourceLineMap) * 5); // each file means 5 less checks
	
	int initStartPos = 0;
	int initEndPos = 5;
	int checkStartPos = 0;
	int checkEndPos = 5;
	
	// for all sourcelines check number of occurences in code
	for ( f <- [0..size(sourceLineMap)] ) {
		for ( l <- [0..size(sourceLineMap[f])] ) {
			// bad construction to check occurences of line in all source
			occurences = checkLineOccurence(sourceLineMap, sourceLineMap[f][l]);
			//if (sourceLineMap[f][l] == "\t\tdoingTheSameThing = 1;") { println(occurences); }
			
			//occurencelist not correct yet
			//occurenceSubList = [ (m:occurences | int m <- [0..l]) ] ;
			
		}
		//occurenceList = occurenceList + occurenceSubList;
		//occurenceSubList = [];
	}
	
	// start comparing sets of 6 sourcelines with the rest of the sourcecode
	
	//return percentageDuplicates;
	return occurenceList;
}