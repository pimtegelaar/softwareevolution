module softwareevolution::series2::AstCloneDetection

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import lang::java::jdt::m3::AST;
import softwareevolution::series1::Measure;
import softwareevolution::series2::Crypto;
import softwareevolution::series2::AstToString;

@memo
public Declaration getA() = getMethodASTEclipse(|java+method:///com/helloworld/HelloWorld/main(java.lang.String%5B%5D)|,model=getExampleProject());
@memo
public Declaration getA2() = getMethodASTEclipse(|java+method:///smallsql/junit/TestThreads/testConcurrentThreadWrite()|,model=getSmallDB());

@memo
set[Declaration] getTr() = createAstsFromEclipseProject(testRascal,true);
@memo
set[Declaration] getSdb() = createAstsFromEclipseProject(smallDB,true);
@memo
set[Declaration] getHsqlDB() = createAstsFromEclipseProject(hyperSonicDB,false);

public set[set[loc]] duplicates(rel[str,loc] index) = {rbd | rbd <- groupRangeByDomain(index), size(rbd)>1};

@doc{convenience method}
public map[int,set[set[loc]]]  chained(set[Declaration] decl, int threshold) = chained(decl,threshold,false);

@doc{convenience method}
public map[int,set[set[loc]]]  chained(set[Declaration] decl, int threshold, bool includeNames) = duplicates(indexeer(decl,threshold,includeNames));

@doc{generates a map of duplicates for a given index}
public map[int,set[set[loc]]] duplicates(rel[int,str,loc] index) {
  map[int,set[set[loc]]] result = ();
  for(i <- domain(index)) {
    set[set[loc]]dup = duplicates(index[i]);
    if(size(dup)>1) {
      result[i]=dup;
    }
  }
  return result;  
}

@doc{creates an index for a set of declarations. 
The threshold is the minimum number of statements a subtree should have, in order to be considered}
public rel[int,str,loc] indexeer(set[Declaration] decl, int threshold, bool includeNames) {
  rel[int,str,loc] result = {};
  visit(decl) {
    case a: Type _: result+=makeRel(a,threshold,includeNames)?{};
    case a: Statement _: result+=makeRel(a,threshold,includeNames)?{};
    case a: Expression _: result+=makeRel(a,threshold,includeNames)?{};
    case a: Declaration _: result+=makeRel(a,threshold,includeNames)?{};
  }
  return result;
}

private rel[int,str,loc] makeRel(Type a, int threshold, bool includeNames) {
  if(a@src?) {
    int nrOfStatements = countStatements(a);
    if(nrOfStatements > threshold) {
        hash = md5(astToString(a,includeNames));
        return {<nrOfStatements,hash,a@src>};
    }
  }
  return {};
}

private rel[int,str,loc] makeRel(Statement a, int threshold, bool includeNames) {
  if(a@src?) {
    int nrOfStatements = countStatements(a);
    if(nrOfStatements > threshold) {
        hash = md5(astToString(a,includeNames));
        return {<nrOfStatements,hash,a@src>};
    }
  }
  return {};
}

private rel[int,str,loc] makeRel(Expression a, int threshold, bool includeNames) {
  if(a@src?) {
    int nrOfStatements = countStatements(a);
    if(nrOfStatements > threshold) {
        hash = md5(astToString(a,includeNames));
        return {<nrOfStatements,hash,a@src>};
    }
  }
  return {};
}

private rel[int,str,loc] makeRel(Declaration a, int threshold, bool includeNames) {
  if(a@src?) {
    int nrOfStatements = countStatements(a);
    if(nrOfStatements > threshold) {
        hash = md5(astToString(a,includeNames));
        return {<nrOfStatements,hash,a@src>};
    }
  }
  return {};
}

public int countStatements(Declaration decl) = (0 | it +1 | /Statement _ := decl);
public int countStatements(Expression decl) = (0 | it +1 | /Statement _ := decl);
public int countStatements(Statement decl) = (0 | it +1 | /Statement _ := decl);
public int countStatements(Type decl) = (0 | it +1 | /Statement _ := decl);
