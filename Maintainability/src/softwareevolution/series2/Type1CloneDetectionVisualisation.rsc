module softwareevolution::series2::Type1CloneDetectionVisualisation

import Prelude;
import IO;
import util::Math;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import vis::Figure;
import vis::Render;

import softwareevolution::series2::CommentReplace;
import softwareevolution::series2::Type1CloneDetection;

public loc testRascal = |project://testrascal|;
public loc testSmallProject = |project://verysmallproject|;

public M3 getTestRascal() = createM3FromEclipseProject(testRascal);
public M3 getSmallProject() = createM3FromEclipseProject(testSmallProject);

public Figure t(str description,str color) = t(description,color,[]);
public Figure t(str description,str color, list[Figure] children) = t(description,color,children,[std(size(20)), std(gap(10))]);
public Figure t(str description,str color, list[Figure] children, list[FProperty] properties) = tree(box(text(description,fontColor("white")),fillColor(color)),children,properties);

/** Show summary information about Type 1 clones */
public Figure showType1Clones(M3 model, str description, int minCloneSize) {
	
	list[lrel[int,int,str]] type1Clones = getType1Clones(model,minCloneSize);
	
	// Create map with filenames from the model
	map[str,str] allFiles = ();
	for ( fileFromModel <- files(model) ) {
		allFiles[fileFromModel.path] = fileFromModel.file;
	}
	
	// Create Sub Figures with Clone data
	list[Figure] fileFigures = [];
	for ( file <- allFiles ) {
		int i = 0;
		list[Figure] clonesPerFile = [];
		for ( clone <- type1Clones ) {
			if ( clone[0][2] == file ) { 
				clonesPerFile += t("lines " + toString(clone[0][0]) + "-" + toString(clone[0][0]), "orange");
				i += 1; 
			}
		}
		fileFigures += t(allFiles[file] + ": " + toString(i) + " clones", "black", clonesPerFile);
		clonesPerFile = [];
		i = 0;
	}
	
	// Create summary Figure
	str numberOfClones = toString(size(type1Clones));
	Figure cloneSummary = t("Type 1 clones for " + description + " (min. clonesize = " + toString(minCloneSize) + "): " + numberOfClones, "blue", fileFigures);

	return (cloneSummary);
}