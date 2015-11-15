module softwareevolution::Measure

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import softwareevolution::LinesOfCode;
import softwareevolution::Duplication;
import softwareevolution::UnitComplexity;
import softwareevolution::UnitSize;
import softwareevolution::CommentCleanup;

public M3 getExampleProject() {
	return createM3FromEclipseProject(|project://example-project|);
}

public M3 getTestRascal() {
	return createM3FromEclipseProject(|project://testrascal|);
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