PROC IMPORT OUT= WORK.lb 
            DATAFILE= "D:\GraceZhang\new\������ҩ�������.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
libname new "D:\GraceZhang\new";
data new.lb_raw;
	set lb;
run;
