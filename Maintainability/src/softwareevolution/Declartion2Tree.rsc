module softwareevolution::Declartion2Tree

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import lang::java::m3::AST;
import demo::lang::Exp::Concrete::WithLayout::Syntax;
import ParseTree;
import vis::Figure;
import vis::ParseTree;
import vis::Render;
import softwareevolution::Measure;

public Declaration getA() = getMethodASTEclipse(|java+method:///com/helloworld/HelloWorld/main(java.lang.String%5B%5D)|,model=getExampleProject());
public Declaration getA2() = getMethodASTEclipse(|java+method:///smallsql/junit/TestThreads/testConcurrentThreadWrite()|,model=getSmallDB());

public Figure t(str description,str color) = t(description,color,[]);
public Figure t(str description,str color, list[Figure] children) = t(description,color,children,[std(size(20)), std(gap(10))]);
public Figure t(str description,str color, list[Figure] children, list[FProperty] properties) = tree(box(text(description,fontColor("white")),fillColor(color)),children,properties);

// Declarations
public Figure mapD2T(\compilationUnit(list[Declaration] imports, list[Declaration] types)) = t("compilationUnit","purple",[mapD2T(\import)|\import<-imports]+[mapD2T(\type)|\type<-types]);
public Figure mapD2T(\compilationUnit(Declaration package, list[Declaration] imports, list[Declaration] types)) = t("compilationUnit","purple",[mapD2T(package)]+[mapD2T(\import)|\import<-imports]+[mapD2T(\type)|\type<-types]);
public Figure mapD2T(\enum(str name, list[Type] implements, list[Declaration] constants, list[Declaration] body)) = t("enum: "+name,"purple",[mapD2T(i)|i<-implements]+[mapD2T(c)|c<-constants]+[mapD2T(b)|b<-body]);
public Figure mapD2T(\enumConstant(str name, list[Expression] arguments, Declaration class)) = t("enumConstant: "+name,"purple",[mapD2T(arg) | arg <- arguments]+mapD2T(class));
public Figure mapD2T(\enumConstant(str name, list[Expression] arguments)) = t("enumConstant: "+name,"purple",[mapD2T(arg) | arg <- arguments]);
public Figure mapD2T(\class(str name, list[Type] extends, list[Type] implements, list[Declaration] body)) = t("class: "+name,"purple",[mapD2T(e)|e<-extends]+[mapD2T(i)|i<-implements]+[mapD2T(b) | b <- body]);
public Figure mapD2T(\class(list[Declaration] body)) = t("class","purple",[mapD2T(b) | b <- body]);
public Figure mapD2T(\interface(str name, list[Type] extends, list[Type] implements, list[Declaration] body)) = t("interface","purple",[mapD2T(e)|e<-extends]+[mapD2T(i)|i<-implements]+[mapD2T(b) | b <- body]);
public Figure mapD2T(\field(Type \type, list[Expression] fragments)) = t("field","purple",[mapD2T(\type)]+[mapD2T(f)|f<-fragments]);
public Figure mapD2T(\initializer(Statement initializerBody)) = t("initializer","purple",[mapD2T(initializerBody)]);
public Figure mapD2T(\method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl)) = t("method: "+name,"purple",[ mapD2T(param) | param <- parameters] + mapD2T(impl));
public Figure mapD2T(\method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions)) = t("method: "+name,"purple");
public Figure mapD2T(\constructor(str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl)) = t("constructor: "+name,"purple");
public Figure mapD2T(\import(str name)) = t("import: "+name,"purple");
public Figure mapD2T(\package(str name)) = t("package: "+name,"purple");
public Figure mapD2T(\package(Declaration parentPackage, str name)) = t("package: "+name,"purple",[mapD2T(parentPackage)]);
public Figure mapD2T(\variables(Type \type, list[Expression] \fragments)) = t("variables","purple",[mapD2T(\type)]+[mapD2T(fragment) | fragment <- fragments]);
public Figure mapD2T(\typeParameter(str name, list[Type] extendsList)) = t("typeParameter: "+name,"purple", [mapD2T(el)|el<-extendsList]);
public Figure mapD2T(\annotationType(str name, list[Declaration] body)) = t("annotationType: "+name,"purple", [mapD2T(b)|b<-body]);
public Figure mapD2T(\annotationTypeMember(Type \type, str name)) = t("annotationTypeMember: "+name,"purple", [mapD2T(\type)]);
public Figure mapD2T(\annotationTypeMember(Type \type, str name, Expression defaultBlock)) = t("annotationTypeMember: "+name,"purple", [mapD2T(\type),mapD2T(defaultBlock)]);
public Figure mapD2T(\parameter(Type \type, str name, int extraDimensions)) = t("param: "+name,"purple", [mapD2T(\type)]);
public Figure mapD2T(\vararg(Type \type, str name)) = t("vararg: "+name,"purple", [mapD2T(\type)]);

// Statements
public Figure mapD2T(\assert(Expression expression)) = tree(box(text("assert","green")),[mapD2T(expression)]);
public Figure mapD2T(\assert(Expression expression, Expression message)) = tree(box(text("assert","green")),[mapD2T(expression),mapD2T(message)]);
public Figure mapD2T(\block(list[Statement] statements)) = t("block", "green", [mapD2T(statement) | statement <- statements]);
public Figure mapD2T(\break) = t("break","green");
public Figure mapD2T(\break(str label)) = t("break","green");
public Figure mapD2T(\continue) = t("continue","green");
public Figure mapD2T(\continue(str label)) = t("continue","green");
public Figure mapD2T(\do(Statement body, Expression condition)) = t("do","green",[mapD2T(body),mapD2T(condition)]);
public Figure mapD2T(\empty) = t("empty","green");
public Figure mapD2T(\foreach(Declaration parameter, Expression collection, Statement body)) = t("foreach","green",[mapD2T(parameter),mapD2T(collection),mapD2T(body)]);
public Figure mapD2T(\for(list[Expression] initializers, Expression condition, list[Expression] updaters, Statement body)) = t("for","green",[mapD2T(init) | init <- initializers]+mapD2T(condition)+[mapD2T(updater) | updater <- updaters]+mapD2T(body));
public Figure mapD2T(\for(list[Expression] initializers, list[Expression] updaters, Statement body)) = t("for","green",[mapD2T(init) | init <- initializers]+[mapD2T(updater) | updater <- updaters]+mapD2T(body));
public Figure mapD2T(\if(Expression condition, Statement thenBranch)) = t("if","green",[mapD2T(condition),mapD2T(thenBranch)]);
public Figure mapD2T(\if(Expression condition, Statement thenBranch, Statement elseBranch)) = t("if","green",[mapD2T(condition),mapD2T(thenBranch),mapD2T(elseBranch)]);
public Figure mapD2T(\label(str name, Statement body)) = t("label","green",[mapD2T(body)]);
public Figure mapD2T(\return(Expression expression)) = t("return","green",[mapD2T(expression)]);
public Figure mapD2T(\return) = t("return","green");
public Figure mapD2T(\switch(Expression expression, list[Statement] statements)) = t("switch","green",[mapD2T(expression)]+[mapD2T(statement) | statement <- statements]);
public Figure mapD2T(\case(Expression expression)) = t("case","green",[mapD2T(expression)]);
public Figure mapD2T(\defaultCase) = t("defaultCase","green");
public Figure mapD2T(\synchronizedStatement(Expression lock, Statement body)) = t("synchronizedStatement","green",[mapD2T(lock),mapD2T(body)]);
public Figure mapD2T(\throw(Expression expression)) = t("throw","green",[mapD2T(expression)]);
public Figure mapD2T(\try(Statement body, list[Statement] catchClauses)) = t("try","green",[mapD2T(body)]+[mapD2T(cc)| cc <- catchClauses]);
public Figure mapD2T(\try(Statement body, list[Statement] catchClauses, Statement \finally)) = t("try","green",[mapD2T(body)]+[mapD2T(cc) | cc <- catchClauses]+mapD2T(\finally));                              
public Figure mapD2T(\catch(Declaration exception, Statement body)) = t("catch","green",[mapD2T(exception),mapD2T(body)]);
public Figure mapD2T(\declarationStatement(Declaration declaration)) = t("declarationStatement","green",[mapD2T(declaration)]);
public Figure mapD2T(\while(Expression condition, Statement body)) = t("while","green",[mapD2T(condition),mapD2T(body)]);
public Figure mapD2T(\expressionStatement(Expression stmt)) = t("expressionStatement","green",[mapD2T(stmt)]);
public Figure mapD2T(\constructorCall(bool isSuper, Expression expr, list[Expression] arguments)) = t("constructorCall","green",[mapD2T(expr)]+[mapD2T(arg) | arg <- arguments]);
public Figure mapD2T(\constructorCall(bool isSuper, list[Expression] arguments)) = t("constructorCall","green",[mapD2T(arg) | arg <- arguments]);

// Expressions
public Figure mapD2T(\arrayAccess(Expression array, Expression index)) = t("arrayAccess","blue",[mapD2T(array),mapD2T(index)]);
public Figure mapD2T(\newArray(Type \type, list[Expression] dimensions, Expression init)) = t("newArray","blue",[mapD2T(\type)]+[mapD2T(dim)|dim<-dimensions]+mapD2T(init));
public Figure mapD2T(\newArray(Type \type, list[Expression] dimensions)) = t("newArray","blue",[mapD2T(\type)]+[mapD2T(dim)|dim<-dimensions]);
public Figure mapD2T(\arrayInitializer(list[Expression] elements)) = t("arrayInitializer","blue",[mapD2T(element)|element<-elements]);
public Figure mapD2T(\assignment(Expression lhs, str operator, Expression rhs)) = t("assignment","blue",[mapD2T(lhs),t(operator,"blue")]+mapD2T(rhs));
public Figure mapD2T(\cast(Type \type, Expression expression)) = t("cast","blue",[mapD2T(\type),mapD2T(expression)]);
public Figure mapD2T(\characterLiteral(str charValue)) = t("char: "+charValue,"blue");
public Figure mapD2T(\newObject(Expression expr, Type \type, list[Expression] args, Declaration class)) = t("newObject","blue",[mapD2T(expr),mapD2T(\type)]+[mapD2T(arg)|arg<-args]+mapD2T(class));
public Figure mapD2T(\newObject(Expression expr, Type \type, list[Expression] args)) = t("newObject","blue",[mapD2T(expr),mapD2T(\type)]+[mapD2T(arg)|arg<-args]);
public Figure mapD2T(\newObject(Type \type, list[Expression] args, Declaration class)) = t("newObject","blue",[mapD2T(\type)]+[mapD2T(arg)|arg <- args]+[mapD2T(class)]);
public Figure mapD2T(\newObject(Type \type, list[Expression] args)) = t("newObject","blue",[mapD2T(\type)]+[mapD2T(arg)|arg <- args]);
public Figure mapD2T(\qualifiedName(Expression qualifier, Expression expression)) = t("qualifiedName","blue",[mapD2T(qualifier),mapD2T(expression)]);
public Figure mapD2T(\conditional(Expression expression, Expression thenBranch, Expression elseBranch)) = t("conditional","blue",[mapD2T(expression),mapD2T(thenBranch),mapD2T(elseBranch)]);
public Figure mapD2T(\fieldAccess(bool isSuper, Expression expression, str name)) = t("fieldAccess","blue",[mapD2T(expression)]);
public Figure mapD2T(\fieldAccess(bool isSuper, str name)) = t("fieldAccess","blue");
public Figure mapD2T(\instanceof(Expression leftSide, Type rightSide)) = t("instanceof","blue",[mapD2T(leftSide),mapD2T(rightSide)]);
public Figure mapD2T(\methodCall(bool isSuper, str name, list[Expression] arguments)) = t(name,"blue",[mapD2T(argument) | argument <- arguments]);
public Figure mapD2T(\methodCall(bool isSuper, Expression receiver, str name, list[Expression] arguments)) = t(name,"blue",mapD2T(receiver)+[mapD2T(argument) | argument <- arguments]);
public Figure mapD2T(\null) = t("null","blue");
public Figure mapD2T(\number(str numberValue)) = t(numberValue,"blue");
public Figure mapD2T(\booleanLiteral(bool boolValue)) = t(boolVale,"blue");
public Figure mapD2T(\stringLiteral(str stringValue)) = t(stringValue,"blue");
public Figure mapD2T(\type(Type \type)) = t("type","blue",[mapD2T(\type)]);
public Figure mapD2T(\variable(str name, int extraDimensions)) = t("var: "+name,"blue");
public Figure mapD2T(\variable(str name, int extraDimensions, Expression \initializer)) = t("var: "+name,"blue",[mapD2T(\initializer)]);
public Figure mapD2T(\bracket(Expression expression)) = t("bracket","blue",[mapD2T(expression)]);
public Figure mapD2T(\this) = t("this","blue");
public Figure mapD2T(\this(Expression thisExpression)) = t("this","blue",[mapD2T(thisExpression)]);
public Figure mapD2T(\super) = t("super","blue");
public Figure mapD2T(\declarationExpression(Declaration decl)) = t("declarationExpression","blue",[mapD2T(decl)]);
public Figure mapD2T(\infix(Expression lhs, str operator, Expression rhs)) = t("infix","blue",[mapD2T(lhs),t(operator,"blue"),mapD2T(rhs)]);
public Figure mapD2T(\postfix(Expression operand, str operator)) = t("postfix","blue", [mapD2T(operand),t(operator,"blue")]);
public Figure mapD2T(\prefix(str operator, Expression operand)) = t("prefix","blue", [t(operator,"blue"),mapD2T(operand)]);
public Figure mapD2T(\simpleName(str name)) = t(name,"blue");
public Figure mapD2T(\markerAnnotation(str typeName)) = t("markerAnnotation","blue");
public Figure mapD2T(\normalAnnotation(str typeName, list[Expression] memberValuePairs)) = t("normalAnnotation","blue",[mapD2T(mvp) | mvp <- memberValuePairs]);
public Figure mapD2T(\memberValuePair(str name, Expression \value)) = t("memberValuePair","blue", [mapD2T(\value)]);
public Figure mapD2T(\singleMemberAnnotation(str typeName, Expression \value)) = t("singleMemberAnnotation","blue", [mapD2T(\value)]);


// Types
public Figure mapD2T(arrayType(Type \type)) = t("arrayType","pink", [mapD2T(\type)]);
public Figure mapD2T(parameterizedType(Type \type)) = t("parameterizedType","pink", [mapD2T(\type)]);
public Figure mapD2T(qualifiedType(Type qualifier, Expression simpleName)) = t("qualifiedType","pink", [mapD2T(qualifier),mapD2T(simpleName)]);
public Figure mapD2T(simpleType(Expression name)) = t("simpleType","pink", [mapD2T(name)]);
public Figure mapD2T(unionType(list[Type] types)) = t("unionType","pink", [mapD2T(\type) | \type <- types]);
public Figure mapD2T(wildcard) = t("wildcard","pink");
public Figure mapD2T(upperbound(Type \type)) = t("upperbound","pink", [mapD2T(\type)]);
public Figure mapD2T(lowerbound(Type \type)) = t("lowerbound","pink", [mapD2T(\type)]);
public Figure mapD2T(\int) = t("int","pink");
public Figure mapD2T(short) = t("short","pink");
public Figure mapD2T(long) = t("long","pink");
public Figure mapD2T(float) = t("float","pink");
public Figure mapD2T(double) = t("double","pink");
public Figure mapD2T(char) = t("char","pink");
public Figure mapD2T(string) = t("string","pink");
public Figure mapD2T(byte) = t("byte","pink");
public Figure mapD2T(\void) = t("void","pink");
public Figure mapD2T(\boolean) = t("boolean","pink");

// Modifiers
public Figure mapD2T(\private) = t("private","orange");
public Figure mapD2T(\public) = t("public","orange");
public Figure mapD2T(\protected) = t("protected","orange");
public Figure mapD2T(\friendly) = t("friendly","orange");
public Figure mapD2T(\static) = t("static","orange");
public Figure mapD2T(\final) = t("final","orange");
public Figure mapD2T(\synchronized) = t("synchronized","orange");
public Figure mapD2T(\transient) = t("transient","orange");
public Figure mapD2T(\abstract) = t("abstract","orange");
public Figure mapD2T(\native) = t("native","orange");
public Figure mapD2T(\volatile) = t("volatile","orange");
public Figure mapD2T(\strictfp) = t("strictfp","orange");
public Figure mapD2T(\annotation(Expression \anno)) = t("annotation","orange",[mapD2T(\anno)]);
public Figure mapD2T(\onDemand) = t("onDemand","orange");
public Figure mapD2T(\default) = t("default","orange");

