PROC IMPORT OUT= WORK.dmcm 
            DATAFILE= "D:\GraceZhang\new\�����������¼���ҩ���.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
libname new "D:\GraceZhang\new";
data new.dmcm_raw;
	set dmcm;
run;


PROC IMPORT OUT= WORK.cmm
            DATAFILE= "D:\GraceZhang\new\������ҩ�������_m.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet2$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data new.dmcm_m;
	set cmm;
run;
