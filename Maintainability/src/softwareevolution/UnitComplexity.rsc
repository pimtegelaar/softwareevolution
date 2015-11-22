module softwareevolution::UnitComplexity

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import softwareevolution::Replace;
import softwareevolution::CommentCleanup;

public tuple[real low, real moderate, real high, real veryhigh] calcRiskComplexity(loc project) {
  model = createM3FromEclipseProject(project);
  return calcRiskComplexity(model, eraseComments(model));
}

public tuple[real low, real moderate, real high, real veryhigh] calcRiskComplexity(M3 model,  map[str,str] withoutComments) {
  int something = 0;
  int unitComplexity = 0;
  map[loc,int] ccpm = ccPerMethod(model, withoutComments);
  real low = 0.0;
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
      low += 1; 
  }
  total = low + moderate + high + veryhigh;
  real lowPercent = low / total * 100;
  real moderatePercent = moderate / total * 100;
  real highPercent = high / total * 100;
  real veryhighPercent = veryhigh / total * 100;
  
  return <lowPercent,moderatePercent,highPercent,veryhighPercent>;;
}

public map[loc,int] ccPerMethod(M3 model) = ccPerMethod(model, eraseComments(model));

public map[loc,int] ccPerMethod(M3 myModel, map[str,str] withoutComments) {
  lpm = ();
  map[loc,loc] myMethods = (e.name:e.src | e <- myModel@declarations, isMethod(e.name));
  for(parent <- {e | e <- myModel@declarations, isClass(e.name) || isInterface(e.name)}) {
    for(methodDeclaration <- methods(myModel, parent.name)) {
      loc method = myMethods[methodDeclaration];
      methodAST = getMethodASTEclipse(methodDeclaration, model=myModel);
      int result = 0;
      visit (methodAST) {
        case \do(_,_) : result += 1;  
        case \while(_,_) : result += 1; 
        case \foreach(_,_,_): result += 1;
        case \for(_,_,_): result += 1;
        case \for(_,_,_,_): result += 1;
        case \if(_,_): result += 1;
        case \if(_,_,_): result += 1;
        case \case(_): result += 1;
        case \catch(_,_): result += 1;
      }
      lpm[methodDeclaration] = result;
    }
  }
  return lpm;
}
