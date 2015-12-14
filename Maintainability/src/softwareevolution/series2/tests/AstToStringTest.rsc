module softwareevolution::series2::tests::AstToStringTest

import lang::java::jdt::m3::AST;
import softwareevolution::series2::AstToString;
import softwareevolution::series2::tests::Assertions;

private loc commandDrop = |project://smallsql0.21_src/src/smallsql/database/CommandDrop.java|;

public Declaration getSampleAst() = createAstFromFile(commandDrop,true);

test bool test_AstToString() {
  astString = astToString(getSampleAst(),false);
  assertEquals(astString, " package package import import simpleName simpleName parameter simpleName parameter simpleName parameter parameter simpleName constructorCall this fieldAccess simpleName assignment expressionStatement this fieldAccess simpleName assignment expressionStatement this fieldAccess simpleName assignment expressionStatement block constructor simpleName parameter simpleName parameter simpleName simpleName simpleName simpleName qualifiedName case simpleName stringLiteral methodCall simpleName simpleName number methodCall assignment expressionStatement if simpleName simpleName simpleName newObject variable variables declarationStatement simpleName methodCall prefix simpleName simpleName simpleName simpleName qualifiedName newObject methodCall prefix infix simpleName simpleName simpleName qualifiedName simpleName methodCall throw if simpleName simpleName methodCall variable variables declarationStatement simpleName null infix number variable variables declarationExpression simpleName simpleName simpleName qualifiedName infix simpleName postfix simpleName simpleName arrayAccess methodCall expressionStatement block if simpleName methodCall expressionStatement break simpleName simpleName qualifiedName case simpleName simpleName simpleName simpleName methodCall expressionStatement break simpleName simpleName qualifiedName case simpleName simpleName simpleName simpleName methodCall expressionStatement break simpleName simpleName qualifiedName case simpleName simpleName qualifiedName case simpleName simpleName qualifiedName simpleName qualifiedName newObject throw defaultCase simpleName newObject throw switch block method class compilationUnit");
  return true;
}

test bool test_AstToStringIncludingNames() {
  astString = astToString(getSampleAst(),true);
  assertEquals(astString, " packagesmallsql packagedatabase importjava.io importsmallsql.database.language.Language simpleNameCommand simpleNameLogger parameter simpleNameString parameter simpleNameString parameter parameter simpleNamelog constructorCall this fieldAccesstype simpleNametype assignment expressionStatement this fieldAccesscatalog simpleNamecatalog assignment expressionStatement this fieldAccessname simpleNamename assignment expressionStatement block constructor simpleNameSSConnection parameter simpleNameSSStatement parameter simpleNameException simpleNametype simpleNameSQLTokenizer simpleNameDATABASE qualifiedName case simpleNamename stringLiteral methodCallstartsWith simpleNamename simpleNamename number methodCallsubstring assignment expressionStatement if simpleNameFile simpleNameFile simpleNamename newObject variabledir variables declarationStatement simpleNamedir methodCallisDirectory prefix simpleNameFile simpleNamedir simpleNameUtils simpleNameMASTER_FILENAME qualifiedName newObject methodCallexists prefix infix simpleNameSmallSQLException simpleNameLanguage simpleNameDB_NONEXISTENT qualifiedName simpleNamename methodCallcreate throw if simpleNameFile simpleNamedir methodCalllistFiles variablefiles variables declarationStatement simpleNamefiles null infix number variablei variables declarationExpression simpleNamei simpleNamefiles simpleNamelength qualifiedName infix simpleNamei postfix simpleNamefiles simpleNamei arrayAccess methodCalldelete expressionStatement block if simpleNamedir methodCalldelete expressionStatement break simpleNameSQLTokenizer simpleNameTABLE qualifiedName case simpleNameDatabase simpleNamecon simpleNamecatalog simpleNamename methodCalldropTable expressionStatement break simpleNameSQLTokenizer simpleNameVIEW qualifiedName case simpleNameDatabase simpleNamecon simpleNamecatalog simpleNamename methodCalldropView expressionStatement break simpleNameSQLTokenizer simpleNameINDEX qualifiedName case simpleNameSQLTokenizer simpleNamePROCEDURE qualifiedName case simpleNamejava simpleNamelang qualifiedName simpleNameUnsupportedOperationException qualifiedName newObject throw defaultCase simpleNameError newObject throw switch block method classCommandDrop compilationUnit");
  return true;
}