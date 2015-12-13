module softwareevolution::series2::Declaration2TreeClickable

import Prelude;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import lang::java::m3::AST;
import demo::lang::Exp::Concrete::WithLayout::Syntax;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import util::Editors;
import softwareevolution::series1::Measure;

public Declaration getA() = getMethodASTEclipse(|java+method:///com/helloworld/HelloWorld/main(java.lang.String%5B%5D)|,model=getExampleProject());
public Declaration getA2() = getMethodASTEclipse(|java+method:///smallsql/junit/TestThreads/testConcurrentThreadWrite()|,model=getSmallDB());

public Figure t(str description,str color) = t(description,color,[]);
public Figure t(str description,str color, list[Figure] children) = t(description,color,children,[std(size(20)), std(gap(10))]);
public Figure t(str description,str color, list[Figure] children, list[FProperty] properties) = tree(box(text(description,fontColor("white")),fillColor(color)),children,properties);

// Declarations
public Figure mapD2T(m: \compilationUnit(list[Declaration] imports, list[Declaration] types)) = t("compilationUnit","purple",[mapD2T(\import)|\import<-imports]+[mapD2T(\type)|\type<-types],[md(m)]);
public Figure mapD2T(m: \compilationUnit(Declaration package, list[Declaration] imports, list[Declaration] types)) = t("compilationUnit","purple",[mapD2T(package)]+[mapD2T(\import)|\import<-imports]+[mapD2T(\type)|\type<-types],[md(m)]);
public Figure mapD2T(m: \enum(str name, list[Type] implements, list[Declaration] constants, list[Declaration] body)) = t("enum: "+name,"purple",[mapD2T(i)|i<-implements]+[mapD2T(c)|c<-constants]+[mapD2T(b)|b<-body],[md(m)]);
public Figure mapD2T(m: \enumConstant(str name, list[Expression] arguments, Declaration class)) = t("enumConstant: "+name,"purple",[mapD2T(arg) | arg <- arguments]+mapD2T(class),[md(m)]);
public Figure mapD2T(m: \enumConstant(str name, list[Expression] arguments)) = t("enumConstant: "+name,"purple",[mapD2T(arg) | arg <- arguments],[md(m)]);
public Figure mapD2T(m: \class(str name, list[Type] extends, list[Type] implements, list[Declaration] body)) = t("class: "+name,"purple",[mapD2T(e)|e<-extends]+[mapD2T(i)|i<-implements]+[mapD2T(b) | b <- body],[md(m)]);
public Figure mapD2T(m: \class(list[Declaration] body)) = t("class","purple",[mapD2T(b) | b <- body],[md(m)]);
public Figure mapD2T(m: \interface(str name, list[Type] extends, list[Type] implements, list[Declaration] body)) = t("interface","purple",[mapD2T(e)|e<-extends]+[mapD2T(i)|i<-implements]+[mapD2T(b) | b <- body],[md(m)]);
public Figure mapD2T(m: \field(Type \type, list[Expression] fragments)) = t("field","purple",[mapD2T(\type)]+[mapD2T(f)|f<-fragments] + [mapD2T(modifier) | modifier <- m@modifiers?[]],[md(m)]);
public Figure mapD2T(m: \initializer(Statement initializerBody)) = t("initializer","purple",[mapD2T(initializerBody)],[md(m)]);
public Figure mapD2T(m: \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl)) = t("method: "+name,"purple",[mapD2T(modifier) | modifier <- m@modifiers?[]] + [mapD2T(impl)] + [ mapD2T(param) | param <- parameters],[md(m)]);
public Figure mapD2T(m: \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions)) = t("method: "+name,"purple",[md(m)]);
public Figure mapD2T(m: \constructor(str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl)) = t("constructor: "+name,"purple",[md(m)]);
public Figure mapD2T(m: \import(str name)) = t("import: "+name,"purple",[md(m)]);
public Figure mapD2T(m: \package(str name)) = t("package: "+name,"purple",[md(m)]);
public Figure mapD2T(m: \package(Declaration parentPackage, str name)) = t("package: "+name,"purple",[mapD2T(parentPackage)],[md(m)]);
public Figure mapD2T(m: \variables(Type \type, list[Expression] \fragments)) = t("variables","purple",[mapD2T(modifier) | modifier <- m@modifiers?[]] + [mapD2T(\type)]+[mapD2T(fragment) | fragment <- fragments],[md(m)]);
public Figure mapD2T(m: \typeParameter(str name, list[Type] extendsList)) = t("typeParameter: "+name,"purple", [mapD2T(el)|el<-extendsList],[md(m)]);
public Figure mapD2T(m: \annotationType(str name, list[Declaration] body)) = t("annotationType: "+name,"purple", [mapD2T(b)|b<-body],[md(m)]);
public Figure mapD2T(m: \annotationTypeMember(Type \type, str name)) = t("annotationTypeMember: "+name,"purple", [mapD2T(\type)],[md(m)]);
public Figure mapD2T(m: \annotationTypeMember(Type \type, str name, Expression defaultBlock)) = t("annotationTypeMember: "+name,"purple", [mapD2T(\type),mapD2T(defaultBlock)],[md(m)]);
public Figure mapD2T(m: \parameter(Type \type, str name, int extraDimensions)) = t("param: "+name,"purple", [mapD2T(\type)],[md(m)]);
public Figure mapD2T(m: \vararg(Type \type, str name)) = t("vararg: "+name,"purple", [mapD2T(\type)],[md(m)]);

// Statements
public Figure mapD2T(m: \assert(Expression expression)) = tree(box(text("assert","green")),[mapD2T(expression)],[md(m)]);
public Figure mapD2T(m: \assert(Expression expression, Expression message)) = tree(box(text("assert","green")),[mapD2T(expression),mapD2T(message)],[md(m)]);
public Figure mapD2T(m: \block(list[Statement] statements)) = t("block", "green", [mapD2T(statement) | statement <- statements],[md(m)]);
public Figure mapD2T(m: \break()) = t("break","green");
public Figure mapD2T(m: \break(str label)) = t("break","green");
public Figure mapD2T(m: \continue()) = t("continue","green");
public Figure mapD2T(m: \continue(str label)) = t("continue","green");
public Figure mapD2T(m: \do(Statement body, Expression condition)) = t("do","green",[mapD2T(body),mapD2T(condition)],[md(m)]);
public Figure mapD2T(m: \empty()) = t("empty","green");
public Figure mapD2T(m: \foreach(Declaration parameter, Expression collection, Statement body)) = t("foreach","green",[mapD2T(parameter),mapD2T(collection),mapD2T(body)],[md(m)]);
public Figure mapD2T(m: \for(list[Expression] initializers, Expression condition, list[Expression] updaters, Statement body)) = t("for","green",[mapD2T(init) | init <- initializers]+mapD2T(condition)+[mapD2T(updater) | updater <- updaters]+mapD2T(body),[md(m)]);
public Figure mapD2T(m: \for(list[Expression] initializers, list[Expression] updaters, Statement body)) = t("for","green",[mapD2T(init) | init <- initializers]+[mapD2T(updater) | updater <- updaters]+mapD2T(body),[md(m)]);
public Figure mapD2T(m: \if(Expression condition, Statement thenBranch)) = t("if","green",[mapD2T(condition),mapD2T(thenBranch)],[md(m)]);
public Figure mapD2T(m: \if(Expression condition, Statement thenBranch, Statement elseBranch)) = t("if","green",[mapD2T(condition),mapD2T(thenBranch),mapD2T(elseBranch)],[md(m)]);
public Figure mapD2T(m: \label(str name, Statement body)) = t("label","green",[mapD2T(body)],[md(m)]);
public Figure mapD2T(m: \return(Expression expression)) = t("return","green",[mapD2T(expression)],[md(m)]);
public Figure mapD2T(m: \return()) = t("return","green");
public Figure mapD2T(m: \switch(Expression expression, list[Statement] statements)) = t("switch","green",[mapD2T(expression)]+[mapD2T(statement) | statement <- statements],[md(m)]);
public Figure mapD2T(m: \case(Expression expression)) = t("case","green",[mapD2T(expression)],[md(m)]);
public Figure mapD2T(m: \defaultCase()) = t("defaultCase","green");
public Figure mapD2T(m: \synchronizedStatement(Expression lock, Statement body)) = t("synchronizedStatement","green",[mapD2T(lock),mapD2T(body)],[md(m)]);
public Figure mapD2T(m: \throw(Expression expression)) = t("throw","green",[mapD2T(expression)],[md(m)]);
public Figure mapD2T(m: \try(Statement body, list[Statement] catchClauses)) = t("try","green",[mapD2T(body)]+[mapD2T(cc)| cc <- catchClauses],[md(m)]);
public Figure mapD2T(m: \try(Statement body, list[Statement] catchClauses, Statement \finally)) = t("try","green",[mapD2T(body)]+[mapD2T(cc) | cc <- catchClauses]+mapD2T(\finally),[md(m)]);                              
public Figure mapD2T(m: \catch(Declaration exception, Statement body)) = t("catch","green",[mapD2T(exception),mapD2T(body)],[md(m)]);
public Figure mapD2T(m: \declarationStatement(Declaration declaration)) = t("declarationStatement","green",[mapD2T(declaration)],[md(m)]);
public Figure mapD2T(m: \while(Expression condition, Statement body)) = t("while","green",[mapD2T(condition),mapD2T(body)],[md(m)]);
public Figure mapD2T(m: \expressionStatement(Expression stmt)) = t("expressionStatement","green",[mapD2T(stmt)],[md(m)]);
public Figure mapD2T(m: \constructorCall(bool isSuper, Expression expr, list[Expression] arguments)) = t("constructorCall","green",[mapD2T(expr)]+[mapD2T(arg) | arg <- arguments],[md(m)]);
public Figure mapD2T(m: \constructorCall(bool isSuper, list[Expression] arguments)) = t("constructorCall","green",[mapD2T(arg) | arg <- arguments],[md(m)]);

// Expressions
public Figure mapD2T(m: \arrayAccess(Expression array, Expression index)) = t("arrayAccess","blue",[mapD2T(array),mapD2T(index)]);
public Figure mapD2T(m: \newArray(Type \type, list[Expression] dimensions, Expression init)) = t("newArray","blue",[mapD2T(\type)]+[mapD2T(dim)|dim<-dimensions]+mapD2T(init),[md(m)]);
public Figure mapD2T(m: \newArray(Type \type, list[Expression] dimensions)) = t("newArray","blue",[mapD2T(\type)]+[mapD2T(dim)|dim<-dimensions],[md(m)]);
public Figure mapD2T(m: \arrayInitializer(list[Expression] elements)) = t("arrayInitializer","blue",[mapD2T(element)|element<-elements],[md(m)]);
public Figure mapD2T(m: \assignment(Expression lhs, str operator, Expression rhs)) = t("assignment","blue",[mapD2T(lhs),t(operator,"blue")]+mapD2T(rhs),[md(m)]);
public Figure mapD2T(m: \cast(Type \type, Expression expression)) = t("cast","blue",[mapD2T(\type),mapD2T(expression)],[md(m)]);
public Figure mapD2T(m: \characterLiteral(str charValue)) = t("char: "+charValue,"blue");
public Figure mapD2T(m: \newObject(Expression expr, Type \type, list[Expression] args, Declaration class)) = t("newObject","blue",[mapD2T(expr),mapD2T(\type)]+[mapD2T(arg)|arg<-args]+mapD2T(class),[md(m)]);
public Figure mapD2T(m: \newObject(Expression expr, Type \type, list[Expression] args)) = t("newObject","blue",[mapD2T(expr),mapD2T(\type)]+[mapD2T(arg)|arg<-args],[md(m)]);
public Figure mapD2T(m: \newObject(Type \type, list[Expression] args, Declaration class)) = t("newObject","blue",[mapD2T(\type)]+[mapD2T(arg)|arg <- args]+[mapD2T(class)],[md(m)]);
public Figure mapD2T(m: \newObject(Type \type, list[Expression] args)) = t("newObject","blue",[mapD2T(\type)]+[mapD2T(arg)|arg <- args],[md(m)]);
public Figure mapD2T(m: \qualifiedName(Expression qualifier, Expression expression)) = t("qualifiedName","blue",[mapD2T(qualifier),mapD2T(expression)],[md(m)]);
public Figure mapD2T(m: \conditional(Expression expression, Expression thenBranch, Expression elseBranch)) = t("conditional","blue",[mapD2T(expression),mapD2T(thenBranch),mapD2T(elseBranch)],[md(m)]);
public Figure mapD2T(m: \fieldAccess(bool isSuper, Expression expression, str name)) = t("fieldAccess","blue",[mapD2T(expression)],[md(m)]);
public Figure mapD2T(m: \fieldAccess(bool isSuper, str name)) = t("fieldAccess","blue");
public Figure mapD2T(m: \instanceof(Expression leftSide, Type rightSide)) = t("instanceof","blue",[mapD2T(leftSide),mapD2T(rightSide)],[md(m)]);
public Figure mapD2T(m: \methodCall(bool isSuper, str name, list[Expression] arguments)) = t(name,"blue",[mapD2T(argument) | argument <- arguments],[md(m)]);
public Figure mapD2T(m: \methodCall(bool isSuper, Expression receiver, str name, list[Expression] arguments)) = t(name,"blue",mapD2T(receiver)+[mapD2T(argument) | argument <- arguments],[md(m)]);
public Figure mapD2T(m: Expression::\null()) = t("null","blue");
public Figure mapD2T(m: \number(str numberValue)) = t(numberValue,"blue");
public Figure mapD2T(m: \booleanLiteral(bool boolValue)) = t(toString(boolValue),"blue");
public Figure mapD2T(m: \stringLiteral(str stringValue)) = t(stringValue,"blue");
public Figure mapD2T(m: \type(Type \type)) = t("type","blue",[mapD2T(\type)],[md(m)]);
public Figure mapD2T(m: \variable(str name, int extraDimensions)) = t("var: "+name,"blue");
public Figure mapD2T(m: \variable(str name, int extraDimensions, Expression \initializer)) = t("var: "+name,"blue",[mapD2T(\initializer)],[md(m)]);
public Figure mapD2T(m: \bracket(Expression expression)) = t("bracket","blue",[mapD2T(expression)],[md(m)]);
public Figure mapD2T(m: \this()) = t("this","blue");
public Figure mapD2T(m: \this(Expression thisExpression)) = t("this","blue",[mapD2T(thisExpression)],[md(m)]);
public Figure mapD2T(m: \super()) = t("super","blue");
public Figure mapD2T(m: \declarationExpression(Declaration decl)) = t("declarationExpression","blue",[mapD2T(decl)],[md(m)]);
public Figure mapD2T(m: \infix(Expression lhs, str operator, Expression rhs)) = t("infix","blue",[mapD2T(lhs),t(operator,"blue"),mapD2T(rhs)],[md(m)]);
public Figure mapD2T(m: \postfix(Expression operand, str operator)) = t("postfix","blue", [mapD2T(operand),t(operator,"blue")],[md(m)]);
public Figure mapD2T(m: \prefix(str operator, Expression operand)) = t("prefix","blue", [t(operator,"blue"),mapD2T(operand)],[md(m)]);
public Figure mapD2T(m: \simpleName(str name)) = t(name,"blue");
public Figure mapD2T(m: \markerAnnotation(str typeName)) = t("markerAnnotation","blue");
public Figure mapD2T(m: \normalAnnotation(str typeName, list[Expression] memberValuePairs)) = t("normalAnnotation","blue",[mapD2T(mvp) | mvp <- memberValuePairs],[md(m)]);
public Figure mapD2T(m: \memberValuePair(str name, Expression \value)) = t("memberValuePair","blue", [mapD2T(\value)],[md(m)]);
public Figure mapD2T(m: \singleMemberAnnotation(str typeName, Expression \value)) = t("singleMemberAnnotation","blue", [mapD2T(\value)],[md(m)]);


// Types
public Figure mapD2T(Type::arrayType(Type \type)) = t("arrayType","pink", [mapD2T(\type)]);
public Figure mapD2T(Type::parameterizedType(Type \type)) = t("parameterizedType","pink", [mapD2T(\type)]);
public Figure mapD2T(Type::qualifiedType(Type qualifier, Expression simpleName)) = t("qualifiedType","pink", [mapD2T(qualifier),mapD2T(simpleName)]);
public Figure mapD2T(Type::simpleType(Expression name)) = t("simpleType","pink", [mapD2T(name)]);
public Figure mapD2T(Type::unionType(list[Type] types)) = t("unionType","pink", [mapD2T(\type) | \type <- types]);
public Figure mapD2T(Type::wildcard()) = t("wildcard","pink");
public Figure mapD2T(Type::upperbound(Type \type)) = t("upperbound","pink", [mapD2T(\type)]);
public Figure mapD2T(Type::lowerbound(Type \type)) = t("lowerbound","pink", [mapD2T(\type)]);
public Figure mapD2T(Type::\int()) = t("int","pink");
public Figure mapD2T(Type::short()) = t("short","pink");
public Figure mapD2T(Type::long()) = t("long","pink");
public Figure mapD2T(Type::float()) = t("float","pink");
public Figure mapD2T(Type::double()) = t("double","pink");
public Figure mapD2T(Type::char()) = t("char","pink");
public Figure mapD2T(Type::string()) = t("string","pink");
public Figure mapD2T(Type::byte()) = t("byte","pink");
public Figure mapD2T(Type::\void()) = t("void","pink");
public Figure mapD2T(Type::\boolean()) = t("boolean","pink");


// Modifiers
public Figure mapD2T(Modifier::\private()) = t("private","orange");
public Figure mapD2T(Modifier::\public()) = t("public","orange");
public Figure mapD2T(Modifier::\protected()) = t("protected","orange");
public Figure mapD2T(Modifier::\friendly()) = t("friendly","orange");
public Figure mapD2T(Modifier::\static()) = t("static","orange");
public Figure mapD2T(Modifier::\final()) = t("final","orange");
public Figure mapD2T(Modifier::\synchronized()) = t("synchronized","orange");
public Figure mapD2T(Modifier::\transient()) = t("transient","orange");
public Figure mapD2T(Modifier::\abstract()) = t("abstract","orange");
public Figure mapD2T(Modifier::\native()) = t("native","orange");
public Figure mapD2T(Modifier::\volatile()) = t("volatile","orange");
public Figure mapD2T(Modifier::\strictfp()) = t("strictfp","orange");
public Figure mapD2T(Modifier::\annotation(Expression \anno)) = t("annotation","orange",[mapD2T(\anno)]);
public Figure mapD2T(Modifier::\onDemand()) = t("onDemand","orange");
public Figure mapD2T(Modifier::\default()) = t("default","orange");

public FProperty md(Declaration m) = onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
  if(m@src?) {
    source = m@src;
    edit(source,[info(1,"")]);
  }
  return true;
});
public FProperty md(Statement m) = onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
  if(m@src?) {
    source = m@src;
    edit(source,[info(1,"")]);
  }
  return true;
});
public FProperty md(Expression m) = onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
  if(m@src?) {
    source = m@src;
    edit(source,[info(1,"")]);
  }
  return true;
});
