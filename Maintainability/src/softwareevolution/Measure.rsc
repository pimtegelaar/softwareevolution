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
	projectLOC = linesProjectTotal(project);
	if (projectLOC > 1310000)
	  return "--";
	if (projectLOC > 665000)
	  return rank = "-";
	if (projectLOC > 246000)
	  return rank = "o";
	if (projectLOC > 66000)
	  return rank = "+";
	return "++";
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
	pD = percentageDuplicates(createM3FromEclipseProject(project));
  if (pD > 20)
    return "--";
  if (pD > 10)
    return rank = "-";
  if (pD > 5)
    return rank = "o";
  if (pD > 3)
    return rank = "+";
  return "++";
}
