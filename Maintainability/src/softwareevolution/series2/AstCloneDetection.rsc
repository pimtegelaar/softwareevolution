module softwareevolution::series2::AstCloneDetection

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import lang::java::jdt::m3::AST;
import softwareevolution::series1::Measure;
import softwareevolution::series2::Crypto;
import softwareevolution::series2::AstToString;

public Declaration getA() = getMethodASTEclipse(|java+method:///com/helloworld/HelloWorld/main(java.lang.String%5B%5D)|,model=getExampleProject());
public Declaration getA2() = getMethodASTEclipse(|java+method:///smallsql/junit/TestThreads/testConcurrentThreadWrite()|,model=getSmallDB());

set[Declaration] getTr() = createAstsFromEclipseProject(testRascal,true);
set[Declaration] getSdb() = createAstsFromEclipseProject(smallDB,true);
set[Declaration] geHsqlDB() = createAstsFromEclipseProject(hyperSonicDB,false);

public set[set[loc]] duplicates(rel[str,loc] index) = {rbd | rbd <- groupRangeByDomain(index), size(rbd)>1};

@doc{convenience method}
public map[int,set[set[loc]]]  chained(set[Declaration] decl, int threshold) = duplicates(indexeer(decl,threshold));

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
public rel[int,str,loc] indexeer(set[Declaration] decl, int threshold) {
  rel[int,str,loc] result = {};
  visit(decl) {
    case a: Type _: result+=makeRel(a,threshold)?{};
    case a: Statement _: result+=makeRel(a,threshold)?{};
    case a: Expression _: result+=makeRel(a,threshold)?{};
    case a: Declaration _: result+=makeRel(a,threshold)?{};
  }
  return result;
}

public rel[int,str,loc] makeRel(Type a, int threshold) {
  if(a@src?) {
    int nrOfStatements = countStatements(a);
    if(nrOfStatements > threshold) {
        hash = md5(astToString(a));
        return {<nrOfStatements,hash,a@src>};
    }
  }
  return {};
}

public rel[int,str,loc] makeRel(Statement a, int threshold) {
  if(a@src?) {
    int nrOfStatements = countStatements(a);
    if(nrOfStatements > threshold) {
        hash = md5(astToString(a));
        return {<nrOfStatements,hash,a@src>};
    }
  }
  return {};
}

public rel[int,str,loc] makeRel(Expression a, int threshold) {
  if(a@src?) {
    int nrOfStatements = countStatements(a);
    if(nrOfStatements > threshold) {
        hash = md5(astToString(a));
        return {<nrOfStatements,hash,a@src>};
    }
  }
  return {};
}

public rel[int,str,loc] makeRel(Declaration a, int threshold) {
  if(a@src?) {
    int nrOfStatements = countStatements(a);
    if(nrOfStatements > threshold) {
        hash = md5(astToString(a));
        return {<nrOfStatements,hash,a@src>};
    }
  }
  return {};
}



public int countStatements(Declaration decl) = (0 | it +1 | /Statement _ := decl);
public int countStatements(Expression decl) = (0 | it +1 | /Statement _ := decl);
public int countStatements(Statement decl) = (0 | it +1 | /Statement _ := decl);
public int countStatements(Type decl) = (0 | it +1 | /Statement _ := decl);

// Old methods below:

public list[loc] atleastXStatements(set[Declaration] decl, int threshold) {
  list[loc] result = [];
  visit(decl) {
    case a: Type _: if(countStatements(a)>threshold) result+=a@src?[];
    case a: Statement _: if(countStatements(a)>threshold) result+=a@src?[];
    case a: Expression _: if(countStatements(a)>threshold) result+=a@src?[];
    case a: Declaration _: if(countStatements(a)>threshold) result+=a@src?[];
  }
  return result;
}


public list[loc] sources(set[Declaration] decl) {
  list[loc] result = [];
  visit(decl) {
    case a: Statement _: result+= a@src?[];
    case a: Expression _: result+= a@src?[];
    case a: Modifier _: result+= a@src?[];
    case a: Type _: result+= a@src?[];
    case a: Declaration _: result+= a@src?[];
  }
  return result;
}