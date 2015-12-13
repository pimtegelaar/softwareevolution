module softwareevolution::series1::UnitSize

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import softwareevolution::series1::LinesOfCode;
import softwareevolution::series1::CommentCleanup;

/*
** Get source information
*/
public tuple[real small, real moderate, real large, real huge] determineUnitSize(loc project) {
  model = createM3FromEclipseProject(project);
  return determineUnitSize(model, eraseComments(model));
}

public tuple[real small, real moderate, real large, real huge] determineUnitSize(M3 model, map[str,str] withoutComments) {
  map[loc,int] lpm = linesPerMethod(model, withoutComments);
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
