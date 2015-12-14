module softwareevolution::series2::Type1CloneDetectionVisualisation

import Prelude;
import IO;
import util::Math;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import vis::Figure;
import vis::Render;
import vis::KeySym;
import util::Editors;

import softwareevolution::series2::CommentReplace;
import softwareevolution::series2::Type1CloneDetection;

public loc testRascal = |project://testrascal|;
public loc testSmallProject = |project://verysmallproject|;

public M3 getTestRascal() = createM3FromEclipseProject(testRascal);
public M3 getSmallProject() = createM3FromEclipseProject(testSmallProject);

/** Function to create a figure (with children) */
public Figure t(str description,str color) = t(description,color,[]);
public Figure t(str description,str color, list[Figure] children) = t(description,color,children,[std(size(20)), std(gap(10))]);
public Figure t(str description,str color, list[Figure] children, list[FProperty] properties) = tree(box(text(description,fontColor("white")),fillColor(color)),children,properties);

/** Property for the mousedown event */
public FProperty md(loc location) = onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
  edit(location,[info(1,"")]);
  return true;
});

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
				loc counterLoc = toLocation(clone[1][2]);
				str counterFileName = counterLoc.file;
				Figure counterFile = t(counterFileName, "red");
				str counterPart = toString(clone[1][0]) + "-" + toString(clone[1][1]);
				Figure counterClone = t(counterPart, "green", [counterFile], [md(counterLoc)]);
				clonesPerFile += t(toString(clone[0][0]) + "-" + toString(clone[0][1]), "orange", [counterClone]);
				i += 1; 
			}
		}
		// Write all file names with the clone data
		fileFigures += t(allFiles[file] + ": " + toString(i) + " clones", "black", clonesPerFile);
		clonesPerFile = [];
		i = 0;
	}
	
	// Create summary Figure, parent of file Figure
	str numberOfClones = toString(size(type1Clones));
	Figure cloneSummary = t("Type 1 clones for " + description + " (min. clonesize = " + toString(minCloneSize) + "): " + numberOfClones, "blue", fileFigures);

	return (cloneSummary);
}