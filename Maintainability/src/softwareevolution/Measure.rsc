module softwareevolution::Measure

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import List;
import String;
import IO;
import Map;
import softwareevolution::LinesOfCode;

public M3 getExampleProject() {
	return createM3FromEclipseProject(|project://example-project|);
}

public M3 getHyperSonicDB() {
	return createM3FromEclipseProject(|project://hsqldb-2.3.1|);
}

public M3 getSmallDB() {
	return createM3FromEclipseProject(|project://smallsql0.21_src|);
}

public int countMethods(M3 model, loc class) {
  list[loc] methods = [ e | e <- model@containment[class], e.scheme == "java+method"];
  int methodCount = size(methods);
  return methodCount;
}

public str volumeRank(loc project) {
	int projectLOC = linesProjectTotal(project);
	str rank;
	if (projectLOC > 0        && projectLOC <=   66000) { rank = "++"; }
	if (projectLOC > 66000    && projectLOC <=  246000) { rank = "+";  }
	if (projectLOC > 246000   && projectLOC <=  665000) { rank = "o";  }
	if (projectLOC > 665000   && projectLOC <= 1310000) { rank = "-";  }
	if (projectLOC > 1310000)                           { rank = "--"; }
	return rank;
}

/*
** Duplication checks
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
	int fixedCheckAmount = size(sourceList) - 7; // The number of cases to compare the 6 lines against
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
	  		println(initStartPos);
	  		println(initEndPos);
	  		println(checkStartPos);
	  		println(checkEndPos);
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