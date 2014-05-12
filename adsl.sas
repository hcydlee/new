libname new "D:\GraceZhang\new";
proc sort data=new.dmcm_raw out=dm;
	where not missing(subjid);
	by subjid;
run;
data dm1;
	set dm;
	format birthdt ststdt stendt date9.;
	birthdt=input(strip(put(birthday,best12.)),yymmdd8.);
	ststdt=input(strip(put(sstdt,best12.)),yymmdd8.);
	stendt=input(strip(put(sendt,best12.)),yymmdd8.);
	age1=ststdt-birthdt+1;
	age2=stendt-birthdt+1;
	label subjid='Subject ID'
		  birthdt="Birthday Date"
		  ststdt='Date of first visit'
		  stendt='Date of second visit'
		  age1="Age of first visit(Days)"
		  age2="Age of second visit(Days)";
	keep subjid birthdt ststdt stendt age1 age2 ;
run;

proc sql noprint;
	create table dm2 as 
	select a.*, b.vitd ,b.ca,b.sex,b.birthweight from
	dm1 a left join new.cm2_raw b
	on a.subjid=b.subjid;
quit;

proc sql noprint;
	create table dm3 as 
	select a.*,b.age_m,b.vitd_m,b.ca_m,b.vitd_name,b.ca_name,b.fa_m,b.dha_m,b.vitc_m,b.tb_m,
			b.cm,b.ddd,b.dose,b.cmstdt,b.indication,b.cmendt,
			b.cm1,b.ddd1,b.dose1,b.cmstdt1,b.indication1,b.cmendt1 from
	dm2 a left join new.dmcm_m b
	on a.subjid=b.subjid;
quit;
data new.adsl;
	set dm3;
	label birthweight='Weight at birth(g)';
run;
