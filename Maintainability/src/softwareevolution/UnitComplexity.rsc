module softwareevolution::UnitComplexity

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import List;
import String;
import IO;
import Map;

import softwareevolution::LinesOfCode;

/*
** Calculate Unit Complexity
*/

public int calcUnitComplexity(loc method) {
	int complexity = 1;
	return complexity;
}

public tuple[real moderate, real high, real veryhigh] calcRiskComplexity(loc project) {
	int something = 0;
	int unitComplexity = 0;
	M3 model = createM3FromEclipseProject(project);
	map[loc,int] lpm = linesPerMethod(model);
	real moderate = 0.0;
	real high = 0.0;
	real veryhigh = 0.0;
	
	for ( method <- lpm ) {
		unitComplexity = calcUnitComplexity(method);
		if (unitComplexity > 50)
			veryhigh += lpm[method];
		else if (unitComplexity > 21)
			high += lpm[method];
		else
			moderate += lpm[method];
	}
	total = moderate + high + veryhigh;
	real moderatePercent = moderate / total * 100;
	real highPercent = high / total * 100;
	real veryhighPercent = veryhigh / total * 100;
	
	return <moderatePercent,highPercent,veryhighPercent>;;
}