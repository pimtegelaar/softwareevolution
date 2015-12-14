module softwareevolution::series2::AstToString

import lang::java::jdt::m3::AST;

public str astToString(value decl, bool includeNames) {
  str result = "";
  visit(decl) {
    // Statements
    case \assert(_): result += " assert";
    case \assert(_,_): result += " assert";
    case \block(_): result += " block";
    case \break(): result += " break";
    case \break(_): result += " break";
    case \continue(): result += " continue";
    case \continue(_): result += " continue";
    case \do(_,_): result += " do";
    case \empty(): result += " empty";
    case \foreach(_,_,_): result += " foreach";
    case \for(_,_,_): result += " for";
    case \for(_,_,_): result += " for";
    case \if(_, _): result += " if";
    case \if(_,_,_): result += " if";
    case \label(_,_): result += " label";
    case \return(_): result += " return";
    case \return(): result += " return";
    case \switch(_,_): result += " switch";
    case \case(_): result += " case";
    case \defaultCase(): result += " defaultCase";
    case \synchronizedStatement(_,_): result += " synchronizedStatement";
    case \throw(_): result += " throw";
    case \try(_,_): result += " try";
    case \try(_,_,_): result += " try";                       
    case \catch(_,_): result += " catch";
    case \declarationStatement(_): result += " declarationStatement";
    case \while(_,_): result += " while";
    case \expressionStatement(_): result += " expressionStatement";
    case \constructorCall(_,_,_): result += " constructorCall";
    case \constructorCall(_,_): result += " constructorCall";
    
    // Expressions
    case \arrayAccess(Expression array, Expression index): result += " arrayAccess";
    case \newArray(Type \type, list[Expression] dimensions, Expression init): result += " newArray";
    case \newArray(Type \type, list[Expression] dimensions): result += " newArray";
    case \arrayInitializer(list[Expression] elements): result += " arrayInitializer";
    case \assignment(Expression lhs, str operator, Expression rhs): result += " assignment";
    case \cast(Type \type, Expression expression): result += " cast";
    case \characterLiteral(str charValue): result += " characterLiteral";
    case \newObject(Expression expr, Type \type, list[Expression] args, Declaration class): result += " newObject";
    case \newObject(Expression expr, Type \type, list[Expression] args): result += " newObject";
    case \newObject(Type \type, list[Expression] args, Declaration class): result += " newObject";
    case \newObject(Type \type, list[Expression] args): result += " newObject";
    case \qualifiedName(Expression qualifier, Expression expression): result += " qualifiedName";
    case \conditional(Expression expression, Expression thenBranch, Expression elseBranch): result += " conditional";
    case \fieldAccess(bool isSuper, Expression expression, str name):  {result += " fieldAccess";if(includeNames) result+=name;}
    case \fieldAccess(bool isSuper, str name):  {result += " fieldAccess";if(includeNames) result+=name;}
    case \instanceof(Expression leftSide, Type rightSide): result += " instanceof";
    case \methodCall(bool isSuper, str name, list[Expression] arguments):  {result += " methodCall";if(includeNames) result+=name;}
    case \methodCall(bool isSuper, Expression receiver, str name, list[Expression] arguments): {result += " methodCall";if(includeNames) result+=name;}
    case Expression::\null(): result += " null";
    case \number(str numberValue): result += " number";
    case \booleanLiteral(bool boolValue): result += " booleanLiteral";
    case \stringLiteral(str stringValue): result += " stringLiteral";
    case \type(Type \type): result += " type";
    case \variable(str name, int extraDimensions):  {result += " variable";if(includeNames) result+=name;}
    case \variable(str name, int extraDimensions, Expression \initializer):  {result += " variable";if(includeNames) result+=name;}
    case \bracket(Expression expression): result += " bracket";
    case \this(): result += " this";
    case \this(Expression thisExpression): result += " this";
    case \super(): result += " super";
    case \declarationExpression(Declaration decl): result += " declarationExpression";
    case \infix(Expression lhs, str operator, Expression rhs): result += " infix";
    case \postfix(Expression operand, str operator): result += " postfix";
    case \prefix(str operator, Expression operand): result += " prefix";
    case \simpleName(str name):  {result += " simpleName";if(includeNames) result+=name;}
    case \markerAnnotation(str typeName): {result += " markerAnnotation";if(includeNames) result+=typeName;}
    case \normalAnnotation(str typeName, list[Expression] memberValuePairs): {result += " normalAnnotation";if(includeNames) result+=typeName;}
    case \memberValuePair(str name, Expression \value)             :  {result += " memberValuePair";if(includeNames) result+=name;}
    case \singleMemberAnnotation(str typeName, Expression \value): {result += " singleMemberAnnotation";if(includeNames) result+=typeName;}
    
    // Declarations
    case \compilationUnit(list[Declaration] imports, list[Declaration] types): result += " compilationUnit";
    case \compilationUnit(Declaration package, list[Declaration] imports, list[Declaration] types): result += " compilationUnit";
    case \enum(str name, list[Type] implements, list[Declaration] constants, list[Declaration] body): {result += " enum";if(includeNames) result+=name;}
    case \enumConstant(str name, list[Expression] arguments, Declaration class): {result += " enumConstant";if(includeNames) result+=name;}
    case \enumConstant(str name, list[Expression] arguments): {result += " enumConstant"; if(includeNames) result+=name;}
    case \class(str name, list[Type] extends, list[Type] implements, list[Declaration] body): {result += " class";if(includeNames) result+=name;}
    case \class(list[Declaration] body): result += " class";
    case \interface(str name, list[Type] extends, list[Type] implements, list[Declaration] body): {result += " interface"; if(includeNames) result+=name;}
    case \field(Type \type, list[Expression] fragments): result += " field";
    case \initializer(Statement initializerBody): result += " initializer";
    case \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl):{ result += " method"; }
    case \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions): {result += " method"; if(includeNames) result+=name;}
    case \constructor(str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl): {result += " constructor"; }
    case \import(str name): {result += " import"; if(includeNames) result+=name;}
    case \package(str name): {result += " package"; if(includeNames) result+=name;}
    case \package(Declaration parentPackage, str name):{ result += " package"; if(includeNames) result+=name;}
    case \variables(Type \type, list[Expression] \fragments): result += " variables";
    case \typeParameter(str name, list[Type] extendsList): {result += " typeParameter"; if(includeNames) result+=name;}
    case \annotationType(str name, list[Declaration] body): {result += " annotationType"; if(includeNames) result+=name;}
    case \annotationTypeMember(Type \type, str name): {result += " annotationTypeMember"; if(includeNames) result+=name;}
    case \annotationTypeMember(Type \type, str name, Expression defaultBlock): {result += " annotationTypeMember"; if(includeNames) result+=name;}
    case \parameter(Type \type, str name, int extraDimensions): result += " parameter";
    case \vararg(Type \type, str name): {result += " vararg"; if(includeNames) result+=name;}
  }
  return result;
}