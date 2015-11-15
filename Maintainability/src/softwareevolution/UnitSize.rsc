module softwareevolution::UnitSize

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import softwareevolution::LinesOfCode;

/*
** Get source information
*/
tuple[real moderate, real high, real veryhigh] determineUnitSize(loc project) {
  map[loc,int] lpm = linesPerMethod(createM3FromEclipseProject(project));
  real small = 0.0;
  real moderate = 0.0;
  real high = 0.0;
  real veryhigh = 0.0;
  for(l <- lpm) {
    unitSize = lpm[l];
    if(unitSize > 100)
      veryhigh += 1;
    else if(unitSize > 50)
      high += 1;
    else if(unitSize > 20) 
      moderate += 1;
    else
      small += 1;
  }
  total = small + moderate + high + veryhigh;
  real moderatePercent = moderate / total * 100;
  real highPercent = high / total * 100;
  real veryhighPercent = veryhigh / total * 100;
  return <moderatePercent,highPercent,veryhighPercent>;
}
