PROC IMPORT OUT= WORK.cm2 
            DATAFILE= "D:\GraceZhang\new\ย่ย่ำราฉว้ฟ๖ฒนณไ.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet3$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
libname new "D:\GraceZhang\new";
data new.cm2_raw;
	set cm2;
run;
