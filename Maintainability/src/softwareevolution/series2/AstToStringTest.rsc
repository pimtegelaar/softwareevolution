module softwareevolution::series2::AstToStringTest

import lang::java::jdt::m3::AST;
import softwareevolution::series2::AstToString;

private loc commandDrop = |project://smallsql0.21_src/src/smallsql/database/CommandDrop.java|;

public Declaration getSampleAst() = createAstFromFile(commandDrop,true);

test bool test_AstToString() {
  astString = astToString(getSampleAst());
  return astString == " package package import import simpleName simpleName parameter simpleName parameter simpleName parameter parameter simpleName constructorCall this fieldAccess simpleName assignment expressionStatement this fieldAccess simpleName assignment expressionStatement this fieldAccess simpleName assignment expressionStatement block constructor simpleName parameter simpleName parameter simpleName simpleName simpleName simpleName qualifiedName case simpleName stringLiteral methodCall simpleName simpleName number methodCall assignment expressionStatement if simpleName simpleName simpleName newObject variable variables declarationStatement simpleName methodCall prefix simpleName simpleName simpleName simpleName qualifiedName newObject methodCall prefix infix simpleName simpleName simpleName qualifiedName simpleName methodCall throw if simpleName simpleName methodCall variable variables declarationStatement simpleName null infix number variable variables declarationExpression simpleName simpleName simpleName qualifiedName infix simpleName postfix simpleName simpleName arrayAccess methodCall expressionStatement block if simpleName methodCall expressionStatement break simpleName simpleName qualifiedName case simpleName simpleName simpleName simpleName methodCall expressionStatement break simpleName simpleName qualifiedName case simpleName simpleName simpleName simpleName methodCall expressionStatement break simpleName simpleName qualifiedName case simpleName simpleName qualifiedName case simpleName simpleName qualifiedName simpleName qualifiedName newObject throw defaultCase simpleName newObject throw switch block method class compilationUnit";
}