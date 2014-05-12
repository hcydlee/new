libname new "D:\GraceZhang\new";
data cm1;
	set new.dmcm_raw;
	keep subjid cm1 dose1 ddd1 indication1 cmstdt1 cmendt1;
	rename cm1=cm dose1=dose ddd1=ddd indication1=indication cmstdt1=cmstdt cmendt1=cmendt;
run;
data cm2;
	set new.dmcm_raw;
	keep subjid cm2 dose2 ddd2 indication2 cmstdt2 cmendt2;
	rename cm2=cm dose2=dose ddd2=ddd indication2=indication cmstdt2=cmstdt cmendt2=cmendt;
run;
data cm3;
	set new.dmcm_raw;
	keep subjid cm3 dose3 ddd3 indication3 cmstdt3 cmendt3;
	rename cm3=cm dose3=dose ddd3=ddd indication3=indication cmstdt3=cmstdt cmendt3=cmendt;
run;
data cm_add1;
	set new.cm2_raw_revised;
	length cm $52 dose $26 ddd $8;
	cm=scan(vitd_name,1,' ');
	dose=scan(vitd_name,2,' ');
	ddd=scan(vitd_name,3,' ');
	indication='≤π≥‰VD'; 
	if not missing(cm);
		keep cm dose ddd indication subjid ;

run;
data cm_add2;
	set new.cm2_raw_revised;
	length cm $52 dose $26 ddd $8;
	cm=scan(ca_name,1,' ');
	dose=scan(ca_name,2,' ');
	ddd=scan(ca_name,3,' ');
	indication='≤π≥‰CA';
	if not missing(cm);
		keep cm dose ddd indication subjid ;

run;
data cm_add3;
	set new.cm2_raw_revised;
		length cm $52 dose $26 ddd $8;
	cm=scan(DHA,1,' ');
	dose=scan(DHA,2,' ');
	ddd=scan(DHA,3,' ');
	indication='≤π≥‰DHA';
	if not missing(cm);
		keep cm dose ddd indication subjid ;

run;
data cm_add4;
	set new.cm2_raw_revised;
		length cm $52 dose $26 ddd $8;
	cm=scan(probiotics,1,' ');
	dose=scan(probiotics,2,' ');
	ddd=scan(probiotics,3,' ');
	indication='≤π≥‰“Ê…˙æ˙';
	if not missing(cm);
	keep cm dose ddd indication subjid ;
run;
data cm;
	retain subjid cm dose indication ddd cmstdt cmendt;
	length ddd $8;
	set cm1 cm2 cm3 cm_add1-cm_add4;
	if not missing(cm);
	label cm='CM reported term'
		  dose='Dose of CM'
		  indication='Indication'
		  ddd='Frequency'
		  cmstdt='Start date of CM'
		  cmendt='End date of CM' 
		  ;
run;
proc sql noprint;
	create table cm_ as 
	select a.*,b.birthdt,b.ststdt,b.stendt,b.vitd,b.ca
	from cm a left join new.adsl b
	on a.subjid=b.subjid
	order by subjid,cmstdt,cmendt;
quit;

data new.adcm; 
	retain subjid birthdt ststdt stendt vitd ca cmstdt cmendt  cm dose indication ddd;
	set cm_;
run;
