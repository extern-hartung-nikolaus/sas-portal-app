
     %if (%symexist(Keywords)) %then %do;
         put "<Keywords>&Keywords.</Keywords>";
         %end;
     %if (%symexist(PageRank)) %then %do;
         put "<PageRank>&PageRank.</PageRank>";
         %end;

     %if (%symexist(scope)) %then %do;
         put "<Scope>&scope.</Scope>";
         %end;

