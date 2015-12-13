module softwareevolution::series2::Type1CloneDetectionVisualisation

import Prelude;
import IO;
import util::Math;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import vis::Figure;
import vis::ParseTree;
import vis::Render;

import softwareevolution::series2::CommentReplace;
import softwareevolution::series2::Type1CloneDetection;

public loc testRascal       = |project://testrascal|;
public loc testSmallProject = |project://verysmallproject|;

public M3 getTestRascal   = createM3FromEclipseProject(testRascal);
public M3 getSmallProject = createM3FromEclipseProject(testSmallProject);

public list[lrel[int,int,str]] type1Clones = getType1Clones(getSmallProject,3);

public Figure t(str description,str color) = t(description,color,[]);
public Figure t(str description,str color, list[Figure] children) = t(description,color,children,[std(size(20)), std(gap(10))]);
public Figure t(str description,str color, list[Figure] children, list[FProperty] properties) = tree(box(text(description,fontColor("white")),fillColor(color)),children,properties);

public Figure showType1Clones(list[lrel[int,int,str]] type1Clones) {
	
	str numberOfClones = toString(size(type1Clones));
	Figure amountClones = t("Total clones: " + numberOfClones, "blue");
	
	return amountClones;
}