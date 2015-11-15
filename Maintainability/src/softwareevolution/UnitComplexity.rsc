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
	real small = 0.0;
	real moderate = 0.0;
	real high = 0.0;
	real veryhigh = 0.0;
	
	for ( method <- lpm ) {
		unitComplexity = calcUnitComplexity(method);
		if (unitComplexity > 50)
			veryhigh += 1;
		else if (unitComplexity > 20)
			high += 1;
		else if(unitComplexity > 10)
			moderate += 1;
		else
		  small += 1;	
	}
	total = small + moderate + high + veryhigh;
	real moderatePercent = moderate / total * 100;
	real highPercent = high / total * 100;
	real veryhighPercent = veryhigh / total * 100;
	
	return <moderatePercent,highPercent,veryhighPercent>;;
}