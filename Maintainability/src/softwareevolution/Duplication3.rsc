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

public lrel[int,str] getType1Clones(map[str,lrel[int,str]] duplicateLines) {
	
	lrel[int,str] dupList = [];
	list[lrel[str,int,int]] cloneList = [];
	
	// Group list by linenumber and file
	map[str,list[int]] dupLinesPerFile = ();	
	list[lrel[int,str]] lineList = toList(range(duplicateLines));
	lrel[int,str] mergedLineList = [];
	
	for (subList <- lineList) {
		for (listRel <- subList) {
			tuple[int,str] locFile = listRel;
			mergedLineList += locFile;
		}
	}
	
	dupLinesPerFile = ();
	
	// Through all duplicate source lines
	for (srcLine <- duplicateLines) {
		dupList = duplicateLines[srcLine];	
		
		//println(srcLine);
		
		// Through specific source line / source file
		for (dupLine <- dupList) {
			
			cloneList = [];
			//println(dupLine[1]);
			
		}
	}
	
	return mergedLineList;
}