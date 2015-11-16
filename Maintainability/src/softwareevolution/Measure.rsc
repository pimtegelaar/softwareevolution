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

public int r(str s) {
  switch(s) {
     case "★★★★★": return 5;
     case "★★★★☆": return 4;
     case "★★★☆☆": return 3;
     case "★★☆☆☆": return 2;
     case "★☆☆☆☆": return 1;
  }
}

public str r(int s) {
  switch(s) {
     case 5: return "★★★★★";
     case 4: return "★★★★☆";
     case 3: return "★★★☆☆";
     case 2: return "★★☆☆☆";
     case 1: return "★☆☆☆☆";
  }
}

/*
 * ----------- 
 *   Metrics   
 * ----------- 
 */
 
public void measure(loc project) {
  vr = volumeRank(project);
  usr = unitSizeRank(project);
  ucr = unitComplexityRank(project);
  dr = duplicationRank(project);
  
  an = analizability(vr,dr,usr);
  ch = changeability(ucr,dr);
  st = stability(usr);
  tst = testability(ucr,usr);
  
  str result =
  "                 -------------------------------------------------
  '                 | Volume | Complexity | Duplication | Unit size |
  '                 | <vr> |   <ucr>    |   <dr>    |    <usr>  |||
  ' -------------------------------------------------------------------------
  ' | Analyzability |   X    |            |      X      |     X     | <an> ||
  ' | Changeability |        |     X      |      X      |           | <ch> ||
  ' | Stability     |        |            |             |     X     | <st> ||
  ' | Testability   |        |     X      |             |     X     | <tst> ||
  ' -------------------------------------------------------------------------
  '                                              Maintainability:   | <endscore(an,ch,st,tst)> ||
  '                                                                 ---------
  ";
  
  println(result);
}

private str analizability(str vr, str dr, str usr) = r((r(vr) + r(dr) + r(usr)) / 3);
private str changeability(str ucr, str dr) = r((r(ucr) + r(dr)) / 2);
private str stability(str usr) = usr;
private str testability(str ucr, str usr) = r((r(ucr) + r(usr)) / 2);
private str endscore(str an, str ch, str st, str tst) =  r((r(an) + r(ch) + r(st) + r(tst)) / 4);

public str volumeRank(loc project) {
	projectLOC = linesProjectTotal(project);
  println("===============================================");
  println(" Lines of code");
  println("===============================================");
  println(" Total lines of code: <projectLOC>");
  println("-----------------------------------------------");
  println();
	if (projectLOC > 1310000)
	  return r(1);
	if (projectLOC > 665000)
	  return rank = r(2);
	if (projectLOC > 246000)
	  return rank = r(3);
	if (projectLOC > 66000)
	  return rank = r(4);
	return r(5);
}


public str unitSizeRank(loc project) {
  unitSize = determineUnitSize(project);
  println("===============================================");
  println(" Unit size");
  println("===============================================");
  println(" Small:    <unitSize.small>");
  println(" Moderate: <unitSize.moderate>");
  println(" Large:    <unitSize.large>");
  println(" Huge:     <unitSize.huge>");
  println("-----------------------------------------------");
  println();
  if (unitSize.moderate > 50 || unitSize.large > 15 || unitSize.huge > 5)  
    return r(1);
  if (unitSize.moderate > 40 || unitSize.large > 10 || unitSize.huge > 0)
    return r(2);
  if (unitSize.moderate > 30 || unitSize.large > 5)
    return r(3);
  if (unitSize.moderate > 25 || unitSize.large > 0)
    return r(4);
  return r(5);
}

public str unitComplexityRank(loc project) {
  unitComplexity = calcRiskComplexity(project);
  println("===============================================");
  println(" Complexity");
  println("===============================================");
  println(" Low:       <unitComplexity.low>");
  println(" Moderate:  <unitComplexity.moderate>");
  println(" High:      <unitComplexity.high>");
  println(" Very high: <unitComplexity.veryhigh>");
  println("-----------------------------------------------");
  println();
  if (unitComplexity.moderate > 50 || unitComplexity.high > 15 || unitComplexity.veryhigh > 5)  
    return r(1);
  if (unitComplexity.moderate > 40 || unitComplexity.high > 10 || unitComplexity.veryhigh > 0)
    return r(2);
  if (unitComplexity.moderate > 30 || unitComplexity.high > 5)
    return r(3);
  if (unitComplexity.moderate > 25 || unitComplexity.high > 0)
    return r(4);
  return r(5);
}

public str duplicationRank(loc project) {
	//pD = percentageDuplicates(createM3FromEclipseProject(project));
	pD = 15;
	println("===============================================");
  println(" Duplication");
  println("===============================================");
  println(" Percentage of duplicates: <pD>");
  println("-----------------------------------------------");
  println();
  if (pD > 20)
    return r(1);
  if (pD > 10)
    return rank = r(2);
  if (pD > 5)
    return rank = r(3);
  if (pD > 3)
    return rank = r(4);
  return r(5);
}
