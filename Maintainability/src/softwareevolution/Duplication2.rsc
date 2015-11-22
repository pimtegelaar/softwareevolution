module softwareevolution::Duplication2


import Prelude;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

import softwareevolution::CommentCleanup;
import softwareevolution::Replace;

public tuple[int,int] totalDuplicateLines(M3 model) {
  withoutComments = eraseComments(model);
  int totalLines = 0;
  map[str,lrel[int,str]] index = ();
  map[str,map[int,str]] index2 = ();
  for (cleanSource <- withoutComments) {
    src = withoutComments[cleanSource];
    noTabsAndCarriageReturn = remove(remove(src, "\r"), "\t");
	  sourceLines = split("\n", noTabsAndCarriageReturn);
	  int i = 0;
  	for(line <- sourceLines) {
      i += 1;
      if(line!="") {
    	  lrel[int,str] locs = [];
    	  if(index[line]?) {
    	    locs += index[line];
    	  }
      	index[line] = locs + <i,cleanSource>;
      	map[int,str] m = ();
      	if(index2[cleanSource]?) {
      	  m += index2[cleanSource];
      	}
      	m[i] = line;
      	index2[cleanSource] = m;
    	}
  	}
  	totalLines +=i;
  }
  duplicateLines = (ind:index[ind] | ind <- index, size(index[ind])>1);
  int result = 0;
  for (cleanSource <- withoutComments) {
    src = withoutComments[cleanSource];
    noTabsAndCarriageReturn = remove(remove(src, "\r"), "\t");
    sourceLines = split("\n", noTabsAndCarriageReturn);
    int i = 0;
    sls = size(sourceLines);
    while(i<sls) {
      line=sourceLines[i];
      i += 1;
      if(line != "}" && duplicateLines[line]?) {
        dls = duplicateLines[line];
        for (dl <- dls) {
          f = dl[1];
          if(f!=cleanSource || dl[0]!= i) {
            or = index2[cleanSource];
            r = index2[f];
            h = 0;
            while (or[i+h]? && r[dl[0]+h]?) {
              orl = or[i+h];
              rl = r[dl[0]+h];
              if(orl!=rl) {
                break;
              }
              h += 1;
            }
            if(h > 5) {
              result+=h;
            }
            i+=h;
          }
        }
      }
    }
  }
  
  return <totalLines,result>;
}