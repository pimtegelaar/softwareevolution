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
  for (n <- split("\r\n", sourcecode)) {
    // first part: don't match comments, second part: match words
    if ( /^\t\/|^\s\/|^\/|^\/\*|^\t\*+|^\s\*+/ !:= n && /\w|\{|\}/ := n ) {
    	lineCounter += 1;
    	println("match: " + n);
	} 
	else
		println("no match: " + n);
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

public int linesProjectTotal(loc project) {
	M3 model = createM3FromEclipseProject(project);
	map[loc,int] classTotals = linesPerClass(model);
	int lineTotal = (0 | it + n | int n <- range(classTotals));
	return lineTotal;
}

// someModel = createM3FromEclipseProject(|project://example-project|);
// someFile = readFile(|project://example-project/src/Apple.java|);
// countLOC(someFile);