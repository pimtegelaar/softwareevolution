module softwareevolution::Measure

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import List;
import String;
import IO;
import Map;
import softwareevolution::LinesOfCode;
import softwareevolution::Duplication;
import softwareevolution::UnitComplexity;
import softwareevolution::UnitSize;

public M3 getExampleProject() {
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
** Cleanup source code
*/

public list[loc] getComments(M3 model) {
	
	rel[loc,loc] d = model@documentation;
	list[loc] comments = [];  
	
	for ( <_,e> <- d ) {
		comments = comments + e;
	}
	
	return comments;
}

public map[int,str] removeComments(M3 model) {
	
	list[loc] comments = getComments(model);
	str source = "";
	map[int,str] newSource = ();
	list[str] splittedSource = [];
	str mergedSource = "";
	str replaceComment = "";
	int beginLine = 0;
	int endLine = 0;
	int beginColumn = 0;
	int endColumn = 0;
	int i = 0;
	
	for (c <- files(model)) {
		source = readFile(c);
		println(c);
		splittedSource = split("\r\n", source);
		for (p <- comments) {
			if (c.file == p.file) {
				
				// singleline comments
				if (p.begin.line == p.end.line) {
					beginLine = p.begin.line - 1;
					beginColumn = p.begin.column;
					endColumn = p.end.column;
					replaceComment = substring(splittedSource[beginLine], beginColumn, endColumn);
					splittedSource[beginLine] = replaceFirst(splittedSource[beginLine],replaceComment,"");
				}
				
				// multiline comments
				if (p.begin.line != p.end.line) {
					beginLine = p.begin.line - 1;
					endLine = p.end.line - 1;
					beginColumn = p.begin.column;
					endColumn = p.end.column;
					for (l <- [beginLine..endLine + 1]) {										
						// replace beginline
						if ( l == beginLine ) {
							replaceComment = substring(splittedSource[l], beginColumn, size(splittedSource[l]));
							splittedSource[l] = replaceFirst(splittedSource[l],replaceComment,"");
						}
						// replace lines in between
						if ( l != beginLine && l != endLine ) { 
							replaceComment = substring(splittedSource[l], 0, size(splittedSource[l]));
							splittedSource[l] = replaceFirst(splittedSource[l],replaceComment,"");
						}
						// replace endline
						if ( l == endLine ) { 
							replaceComment = substring(splittedSource[l], 0, endColumn);
							splittedSource[l] = replaceFirst(splittedSource[l],replaceComment,"");
						}
					}
				}
			}
		}
		for (s <- splittedSource) { 
			// remove new lines and leading/trailing white spaces (remove too much new lines now?)
			if ( isEmpty(trim(s)) == false ) { mergedSource = mergedSource + "\r\n" + s; }
		}
		mergedSource = replaceFirst(mergedSource, "\r\n", "");
		newSource = newSource + (i: mergedSource);
		mergedSource = "";
		i += 1;		
	}
	return newSource;
}

/*
** Metrics
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