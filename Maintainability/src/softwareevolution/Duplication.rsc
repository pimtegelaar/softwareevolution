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

public list[map[int,str]] percentageDuplicates(M3 model) {
	
	int percentageDuplicates = 0;
	list[map[int,str]] sourceLineMap = removeComments(model);
	
	// start comparing sets of 6 sourcelines with the rest of the sourcecode
	
	return percentageDuplicates;
}