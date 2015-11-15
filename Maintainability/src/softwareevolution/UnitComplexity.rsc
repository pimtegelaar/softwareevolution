module softwareevolution::UnitComplexity

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import softwareevolution::Replace;
import softwareevolution::CommentCleanup;

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
	map[loc,int] ccpm = ccPerMethod(model);
	real small = 0.0;
	real moderate = 0.0;
	real high = 0.0;
	real veryhigh = 0.0;
	
	for ( method <- ccpm ) {
		unitComplexity = ccpm[method];
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

public map[loc,int] ccPerMethod(M3 model) {
  lpm = ();
  withoutComments = eraseComments(model);
  map[loc,loc] myMethods = (e.name:e.src | e <- model@declarations, isMethod(e.name));
  for(parent <- {e | e <- model@declarations, isClass(e.name) || isInterface(e.name)}) {
    for(methodDeclaration <- methods(model, parent.name)) {
      loc method = myMethods[methodDeclaration];
      str fileLoc = parent.src.path;
      str file = withoutComments[fileLoc];
      offset = method.offset;
      end = offset+method.length;
      methodSrc = substring(file, offset, end);
      lpm[methodDeclaration] = countComplexity(methodSrc);
    }
  }
  return lpm;
}

public int countComplexity(str sourcecode) = (0 | it + 1 | /else if|if|else|\&\&|\|\||case|default|catch/  := sourcecode);