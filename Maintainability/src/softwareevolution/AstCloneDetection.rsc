module softwareevolution::AstCloneDetection

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import lang::java::m3::AST;
import softwareevolution::Measure;

public Declaration getA() = getMethodASTEclipse(|java+method:///com/helloworld/HelloWorld/main(java.lang.String%5B%5D)|,model=getExampleProject());
public Declaration getA2() = getMethodASTEclipse(|java+method:///smallsql/junit/TestThreads/testConcurrentThreadWrite()|,model=getSmallDB());

public int countStatements(Declaration decl) {
  int i = 0;
  visit(decl) {
    case \assert(_): i+=1;
    case \assert(_,_): i+=1;
    case \block(_): i+=1;
    case \break(): i+=1;
    case \break(_): i+=1;
    case \continue(): i+=1;
    case \continue(_): i+=1;
    case \do(_,_): i+=1;
    case \empty(): i+=1;
    case \foreach(_,_,_): i+=1;
    case \for(_,_,_): i+=1;
    case \for(_,_,_): i+=1;
    case \if(_, _): i+=1;
    case \if(_,_,_): i+=1;
    case \label(_,_): i+=1;
    case \return(_): i+=1;
    case \return(): i+=1;
    case \switch(_,_): i+=1;
    case \case(_): i+=1;
    case \defaultCase(): i+=1;
    case \synchronizedStatement(_,_): i+=1;
    case \throw(_): i+=1;
    case \try(_,_): i+=1;
    case \try(_,_,_): i+=1;                       
    case \catch(_,_): i+=1;
    case \declarationStatement(_): i+=1;
    case \while(_,_): i+=1;
    case \expressionStatement(_): i+=1;
    case \constructorCall(_,_,_): i+=1;
    case \constructorCall(_,_): i+=1;
  }
  return i;
}