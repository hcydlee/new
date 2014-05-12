libname new "D:\GraceZhang\new";

ods output onewayfreqs=stat1;
proc freq data=new.adsl;
	table sex/list;
	table ca;
	table vitd;
run;
ods output close;

proc means data=new.adsl;
	var birthweight;
run;
