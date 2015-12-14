module softwareevolution::series2::VisualizeClones

import Prelude;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import util::Editors;

public Figure t(str description,str color) = t(description,color,[]);
public Figure t(str description,str color, list[Figure] children) = t(description,color,children,[std(size(20)), std(gap(10)),std(orientation(leftRight()))]);
public Figure t(str description,str color, list[Figure] children, list[FProperty] properties) = tree(box(text(description,fontColor("white")),fillColor(color)),children,properties+[std(size(20)), std(gap(10))]);

public Figure convertToTree(map[int,set[set[loc]]] clones) {
  children = [];
  for(statementSize <- clones) {
    children2 = [];
    for(cloneClass<-clones[statementSize]) {
      children3 = [];
      for(clone<-cloneClass) {
        children3 += t("<clone.file> <clone.begin> <clone.end>","blue", [],[md(clone)]); 
      }
      children2 += t("","orange",children3,[std(gap(20))]);
    }
    children+=t("<statementSize> statements","green", children2);
  }
  return t("Clones","red",children);
}

public FProperty md(loc location) = onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
    edit(location,[info(1,"")]);
  return true;
});
