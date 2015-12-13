module softwareevolution::series2::AstCloneDetectionTest

import softwareevolution::series2::AstCloneDetection;

import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import lang::java::jdt::m3::AST;
import softwareevolution::series1::Measure;
import softwareevolution::series2::Crypto;
import softwareevolution::series2::AstToString;
import softwareevolution::series2::Assertions;

test bool test_countStatements() {
  result = countStatements(getA());
  assertEquals(result,24);
  return true;
}

test bool test_indexeer() {
  i = indexeer(getTr(),5);
  assertEquals(size(i),23);
  
  six = i[6];
  assertEquals(size(six),6);
  
  
  domOfSix = domain(six);
  assertEquals(size(domOfSix),2);
  assertIn("ƒ\a1c\a15´ªß\a1cg\ufffdOãé»“\a04º", domOfSix);
  
  return true;
}


test bool test_duplicates() {
  rel[int,str,loc] index =  {
    <33,"÷ÍîÈÑë\'³bøD{\a05…+9",|project:///softwareevolution/testrascal/src/core/Main.java|(306,1197,<24,0>,<79,1>)>,
    <18,"£½%³šw!È\"…«\t\a0ctã\a03",|project:///softwareevolution/testrascal/src/analyzer/InitShizzle.java|(0,581,<1,0>,<35,3>)>,
    <6,"&\t(…—hÒW\ufffd\a123\a0fµó—ì",|project:///softwareevolution/testrascal/src/analyzer/InitShizzle.java|(401,173,<25,1>,<33,2>)>,
    <34,"\n“\a05îFFÕpÒ¦ŽžN\a18Ì²",|project:///softwareevolution/testrascal/src/core/Duplicates.java|(47,779,<5,1>,<48,2>)>,
    <12," Ã N¿Ë\a00Ô\a17ú@\a03\a15=ä\a10",|project:///softwareevolution/testrascal/src/core/ExampleCyclomaticComplexity.java|(118,397,<5,55>,<18,2>)>,
    <10,"óe‚þu:Œ‰\a05`+«Vœ•—",|project:///softwareevolution/testrascal/src/core/ExampleCyclomaticComplexity.java|(130,348,<6,9>,<16,10>)>,
    <34,"jë©ù\a18¸ˆ`mêñtåÛ\a18\ufffd",|project:///softwareevolution/testrascal/src/core/Duplicates.java|(92,734,<5,46>,<48,2>)>,
    <6,"&\t(…—hÒW\ufffd\a123\a0fµó—ì",|project:///softwareevolution/testrascal/src/analyzer/InitShizzle.java|(53,163,<5,1>,<13,2>)>,
    <6,"ƒ\a1c\a15´ªß\a1cg\ufffdOãé»“\a04º",|project:///softwareevolution/testrascal/src/analyzer/InitShizzle.java|(267,128,<15,46>,<23,2>)>,
    <30,")4dõ!-á¯À\a19­0Ð÷Ê°",|project:///softwareevolution/testrascal/src/core/Main.java|(468,944,<32,40>,<73,2>)>,
    <9,"»»\a1e-\<ÕóÅôµM\'-µÄ–",|project:///softwareevolution/testrascal/src/core/ExampleCyclomaticComplexity.java|(158,320,<6,37>,<16,10>)>,
    <12,"!\a11Œ×ª\a1bbZˆÁ\a0eAÃwñø",|project:///softwareevolution/testrascal/src/core/ExampleCyclomaticComplexity.java|(64,451,<5,1>,<18,2>)>,
    <34,"é\a18f7ÄÂïâ{\a12Ðë@\a145)",|project:///softwareevolution/testrascal/src/core/Duplicates.java|(17,812,<3,0>,<49,1>)>,
    <33,"\rT¨WÓô\a16pÌêÜ\a05ã\a1a­î",|project:///softwareevolution/testrascal/src/core/Main.java|(0,1503,<1,0>,<79,1>)>,
    <12,"\ufffdœyíd6\a10r\ufffd\a15Ï\"–ˆ?\a0b",|project:///softwareevolution/testrascal/src/core/ExampleCyclomaticComplexity.java|(0,520,<1,0>,<20,1>)>,
    <8,"›ì—H…É\a06É¸™/Ô)Oš½",|project:///softwareevolution/testrascal/src/core/ExampleCyclomaticComplexity.java|(178,288,<7,17>,<15,18>)>,
    <6,"&\t(…—hÒW\ufffd\a123\a0fµó—ì",|project:///softwareevolution/testrascal/src/analyzer/InitShizzle.java|(222,173,<15,1>,<23,2>)>,
    <12,"ýþ\a19‰8J:\a03ËÀšû\a02ë¤G",|project:///softwareevolution/testrascal/src/core/ExampleCyclomaticComplexity.java|(17,503,<3,0>,<20,1>)>,
    <6,"ƒ\a1c\a15´ªß\a1cg\ufffdOãé»“\a04º",|project:///softwareevolution/testrascal/src/analyzer/InitShizzle.java|(97,119,<5,45>,<13,2>)>,
    <18,"©æñˆGó€â\'\<æW\>Üó9",|project:///softwareevolution/testrascal/src/analyzer/InitShizzle.java|(21,558,<3,0>,<35,1>)>,
    <6,"ƒ\a1c\a15´ªß\a1cg\ufffdOãé»“\a04º",|project:///softwareevolution/testrascal/src/analyzer/InitShizzle.java|(446,128,<25,46>,<33,2>)>,
    <34,"í\a04\a07]EÉ\a11Þ\'«È\a0e\\k\a08é",|project:///softwareevolution/testrascal/src/core/Duplicates.java|(0,829,<1,0>,<49,1>)>,
    <30,"Òrç´?c¢?J\tY±8ë±\ufffd",|project:///softwareevolution/testrascal/src/core/Main.java|(414,998,<31,1>,<73,2>)>
  };
  i = duplicates(index);
  
  assertEquals(size(i),1);
  
  six = i[6];
  assertEquals(size(six),2);
  
  expectedSix = {
    {
      |project:///softwareevolution/testrascal/src/analyzer/InitShizzle.java|(267,128,<15,46>,<23,2>),
      |project:///softwareevolution/testrascal/src/analyzer/InitShizzle.java|(446,128,<25,46>,<33,2>),
      |project:///softwareevolution/testrascal/src/analyzer/InitShizzle.java|(97,119,<5,45>,<13,2>)
    },
    {
      |project:///softwareevolution/testrascal/src/analyzer/InitShizzle.java|(222,173,<15,1>,<23,2>),
      |project:///softwareevolution/testrascal/src/analyzer/InitShizzle.java|(401,173,<25,1>,<33,2>),
      |project:///softwareevolution/testrascal/src/analyzer/InitShizzle.java|(53,163,<5,1>,<13,2>)
    }
  };
  
  assertEquals(six, expectedSix);
  return true;
}
