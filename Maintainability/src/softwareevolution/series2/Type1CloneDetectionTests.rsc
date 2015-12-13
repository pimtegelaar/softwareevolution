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

/** Read File A and split by new lines */
public list[str] readFileA() {
	loc fileA = getFileA();
	str fileAContent = readFile(fileA);
	fileAContent = replaceAll(fileAContent, "\r\n", "\n");
    list[str] fileASplitted = split("\n", fileAContent);
	return fileASplitted;
}

/** Put File A through comment replacement and split result by new lines */
public list[str] stripFileA() {
	map[str,str] projectReplComments = replaceComments(getSmallProject(), "--- this is a replaced comment ---");
	loc fileA = getFileA();
	str fileAReplComments = projectReplComments[fileA.path];
	fileAContent = replaceAll(fileAReplComments, "\r\n", "\n");
    list[str] fileASplittedReplComments = split("\n", fileAContent);
	return fileASplittedReplComments;
}

/** Test whether list without comments is the same size as original list */
test bool fileASameSize() {
	list[str] orgFileA = readFileA();
	list[str] replFileA = stripFileA();
	assert size(orgFileA) == size(replFileA) : "lists are not the same size after comment replacement!";
	return true;
}