module softwareevolution::Measure

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import List;
import String;
import IO;
import Map;

public M3 getExampleProject() {
	return createM3FromEclipseProject(|project://example-project|);
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

public int countLines(str sourcecode) {
  int lineCount = (0 | it + 1 | /\r\n/ := sourcecode);
  return lineCount;
}

public int countLOC(str sourcecode) {    
  int lineCounter = 0;
  str sourceWithoutTabs = replaceAll(sourcecode, "\t", ""); // remove tab characters
  for (n <- split("\r\n", sourceWithoutTabs)) {
    str m = trim(n); // remove leading/trailing white spaces
    // first part: don't match comments, second part: do match words or opening/closing brackets
    if ( /^\/|^\/\*|^\*/ !:= m && /\w|\{|\}/ := m ) {
    	lineCounter += 1;
    	println("match: " + m);
	} 
	else
		println("no match: " + m);
  } 
  return lineCounter;
}

public map[loc,int] linesPerClass(M3 model) {
	lpc = ();
	for (c <- classes(model)) {
		lines = countLOC(readFile(c));
		lpc[c] = lines;
	}
	return lpc;
}

public int totalLines(M3 model) = (0 | it + subTotal | subTotal <- range(linesPerClass(model)));

public int linesProjectTotal(loc project) = totalLines(createM3FromEclipseProject(project));

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