module softwareevolution::series2::Type1CloneDetectionTests

import Prelude;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import IO;

import softwareevolution::series2::CommentReplace;
import softwareevolution::series2::Type1CloneDetection;

public loc testRascal = |project://testrascal|;
public loc testSmallProject = |project://verysmallproject|;

public M3 getTestRascal()  = createM3FromEclipseProject(testRascal);
public M3 getSmallProject()= createM3FromEclipseProject(testSmallProject);

/** Get FileA.java from the Very Small Project */
public loc getFileA() {
	M3 model = getSmallProject();
	list[loc] fileList = [ fileRef | fileRef <- files(model), fileRef.file == "FileA.java" ];
	loc fileA = fileList[0];
	return fileA;
}

/** Clean and split */
public list[str] cleanSource(str src) {
	str cleanSrc = replaceAll(src, "\r\n", "\n");
	cleanSrc = replaceAll(cleanSrc, "\t", "");
    list[str] splitSrc = split("\n", cleanSrc);
    return splitSrc;
}

/** Read File A and split by new lines */
public list[str] readFileA() {
	loc fileA = getFileA();
	str fileAContent = readFile(fileA);
    list[str] fileASplitted = cleanSource(fileAContent);
	return fileASplitted;
}

/** Put File A through comment replacement and split result by new lines */
public list[str] stripFileA() {
	map[str,str] projectReplComments = replaceComments(getSmallProject(), " ");
	loc fileA = getFileA();
	str fileAReplComments = projectReplComments[fileA.path];
    list[str] fileASplittedReplComments = cleanSource(fileAReplComments);
	return fileASplittedReplComments;
}

/** Test whether list without comments is the same size as original list */
test bool fileASameSize() {
	list[str] orgFileA = readFileA();
	list[str] replFileA = stripFileA();
	assert size(orgFileA) == size(replFileA) : "lists are not the same size after comment replacement!";
	return true;
}

/** Test whether list without comments is the same source as original list */
test bool fileASameSource() {
	list[str] orgFileA = readFileA();
	list[str] replFileA = stripFileA();
	assert orgFileA[0]  == replFileA[0]  : "difference in line 1   - package verysmallproject;";
	assert orgFileA[1]  == replFileA[1]  : "difference in line 2   - (empty)";
	assert orgFileA[2]  != replFileA[2]  : "difference in line 3   - (comment)";
	assert orgFileA[3]  != replFileA[3]  : "difference in line 4   - (comment)";
	assert orgFileA[4]  != replFileA[4]  : "difference in line 5   - (comment)";
	assert orgFileA[5]  == replFileA[5]  : "difference in line 6   - (empty)";
	assert orgFileA[6]  == replFileA[6]  : "difference in line 7   - public class FileA {";
	assert orgFileA[7]  == replFileA[7]  : "difference in line 8   - int a = 1;";
	assert orgFileA[8]  == replFileA[8]  : "difference in line 9   - int b = 2;";
	assert orgFileA[9]  == replFileA[9]  : "difference in line 10  - int c = 3;";
	assert orgFileA[10] == replFileA[10] : "difference in line 11  - }";
	return true;
}

/** Test whether returned duplicate lines are correct */
test bool dupLineCorrectSrc() {
	
	M3 model = getSmallProject();
	list[str] strippedFileA = stripFileA();
	map[str,str] srcNoComments = replaceComments(model," ");
	map[str,lrel[int,str]] duplicateLines = getSourceDuplicates(model);
	int i = 0;
	while ( i < 11 ) {	
		str randomLine = getOneFrom(strippedFileA);		
		if ( duplicateLines[randomLine]? ) {
			for ( dupLine <- duplicateLines[randomLine] ) {
				int listNo = dupLine[0] - 1;
				str srcFile = srcNoComments[dupLine[1]];
			    list[str] cleanSrcFile = cleanSource(srcFile);
				assert trim(randomLine) == trim(cleanSrcFile[listNo]) : trim(randomLine) + " - line is different from - " + trim(cleanSrcFile[listNo]);
			}
		}
		i += 1;
	}
	return true;
}