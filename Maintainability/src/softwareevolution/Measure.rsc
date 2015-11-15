module softwareevolution::Measure

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import softwareevolution::LinesOfCode;
import softwareevolution::Duplication;
import softwareevolution::UnitComplexity;
import softwareevolution::CommentCleanup;
import softwareevolution::UnitSize;

/*
 * ----------- 
 *   Projects   
 * ----------- 
 */
 
public loc exampleProject = |project://example-project|;
public loc testRascal = |project://testrascal|;
public loc hyperSonicDB = |project://hsqldb-2.3.1|;
public loc smallDB = |project://smallsql0.21_src|;

public M3 getExampleProject() = createM3FromEclipseProject(exampleProject);
public M3 getTestRascal()  = createM3FromEclipseProject(testRascal);
public M3 getHyperSonicDB()  = createM3FromEclipseProject(hyperSonicDB);
public M3 getSmallDB()  = createM3FromEclipseProject(smallDB);


/*
 * ----------- 
 *   Metrics   
 * ----------- 
 */

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


public str unitSizeRank(loc project) {
  unitSize = determineUnitSize(project);
  if (unitSize.moderate > 50 || unitSize.high > 15 || unitSize.veryhigh > 5)  
    return "--";
  if (unitSize.moderate > 40 || unitSize.high > 10 || unitSize.veryhigh > 0)
    return "-";
  if (unitSize.moderate > 30 || unitSize.high > 5)
    return "o";
  if (unitSize.moderate > 25 || unitSize.high > 0)
    return "+";
  return "++";
}

public str duplicationRank(loc project) {
	M3 model = createM3FromEclipseProject(project);
	int pD = percentageDuplicates(model);
	str rank;
	if (pD > 0 &&  pD <= 3)   { rank = "++"; }
	if (pD > 3 &&  pD <= 5)   { rank = "+"; }
	if (pD > 5 &&  pD <= 10)  { rank = "o"; }
	if (pD > 10 && pD <= 20)  { rank = "-"; }
	if (pD > 20 && pD <= 100) { rank = "--"; }
	return rank;
}

public int countMethods(M3 model, loc class) {
  list[loc] methods = [ e | e <- model@containment[class], e.scheme == "java+method"];
  int methodCount = size(methods);
  return methodCount;
}
