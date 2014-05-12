libname new "D:\GraceZhang\new";
proc sort data=new.lb_raw out=lb
	(rename=(Cu__umol_L_=Cu 
			 Zn__umol_L_=Zn 
			 Ca__mmol_L_=Ca 
			 Mg__mmol_L_=Mg 
			 Fe__mmol_L_=Fe 
			 Pb__ug_L_=Pb
			 Cr__ug_L_=Cr
			 D__ng_ml_=VitD));
	by subjid lbdt;
	where not missing(subjid);
run;
proc transpose data=lb out=lbt;
	by subjid lbdt;
	var cu zn ca mg fe pb cr vitd;
run;

data new.adlb;
	set lbt;
	rename _name_=paramcd _label_=param col1=aval;

	label _name_="Parameter Code"
		  _label_="Parameter"
			subjid='Subject ID'
			lbdt='Date of Collection';
run;
