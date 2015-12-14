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
  for(statementSize <- reverse(sort([c | c <- clones]))) {
    children2 = [];
    for(cloneClass<-clones[statementSize]) {
      children3 = [];
      for(clone<-cloneClass) {
        children3 += t("<clone.file> <clone.begin> <clone.end>","blue", [],[md(clone)]); 
      }
      children2 += t("<size(children3)>","orange",children3,[std(gap(20))]);
    }
    f = t("<statementSize>","green",children2);
    children += box(text("<statementSize>"),fillColor("green"),std(size(40+5*size(clones[statementSize]))),md(f));
  }
  return hvcat(children,gap(5));
}

public FProperty md(Figure f) = onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
  render(f);
  return true;
});

public FProperty md(loc location) = onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
  edit(location,[info(1,"")]);
  return true;
});
