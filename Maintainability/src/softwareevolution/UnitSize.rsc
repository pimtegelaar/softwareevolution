module softwareevolution::UnitSize

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import softwareevolution::LinesOfCode;

/*
** Get source information
*/
public tuple[real small, real moderate, real large, real huge] determineUnitSize(loc project) {
  map[loc,int] lpm = linesPerMethod(createM3FromEclipseProject(project));
  real small = 0.0;
  real moderate = 0.0;
  real large = 0.0;
  real huge = 0.0;
  for(l <- lpm) {
    unitSize = lpm[l];
    if(unitSize > 100)
      huge += 1;
    else if(unitSize > 50)
      large += 1;
    else if(unitSize > 20) 
      moderate += 1;
    else
      small += 1;
  }
  total = small + moderate + large + huge;
  real smallPercent = small / total * 100;
  real moderatePercent = moderate / total * 100;
  real largePercent = large / total * 100;
  real hugePercent = huge / total * 100;
  return <smallPercent,moderatePercent,largePercent,hugePercent>;
}
