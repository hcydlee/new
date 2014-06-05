libname new "c:\Users\sli126\Documents\GitHub\new";
/*proc format;
    value a
    aaaa
    bbbb
    cccc
    dddd
    ;
run;
*/
dm log 'clear';
dm output 'clear';
/*demographic character*/
options validvarname=upcase ;

proc format;
	value orderfmt
          1='Age (Days)'
          2='Sex, n (%)'
          3='BrithWeight (kg)'
		  4='Vitamin D usage'
		  5='Ca usage'
		  6='Vitamin D usage(mother)'
		  7='Ca usage(mother)'

           ;

	value $meanfmt
          'A_N'="n"
          'B_MEANSD'="Mean (SD)"
          'C_MEDIANR'="Median (Range)"
           ;

	value $sexfmt
          'F'="FEMALE"
          'M'="MALE"
          ;

	value $sexf
         'MALE'='1'
         'FEMALE'='2'
          ;

        value sexf
          1='Male'
          2='Female'
	;

	value yn
			1="Yes"
			2="No"
			;
	value $yn
		"Y"='1'
		"N"='2'
		;
run;

%macro disVar(indata=, outdata=, byvar=, varlist=, porder=, fmt=);
	proc sort data=&indata out=tmp1;
				by &byvar;
	run;
	proc freq data=tmp1;
                table &varlist/missing noprint out=one(drop=percent);
				by &byvar;
	run;

	proc freq data=tmp1(where=(not missing(&varlist)));
				table &varlist/missing noprint out=two;
				by &byvar;
	run;

	proc sort data=one;
		by &byvar &varlist;
	run;

	proc sort data=two;
		by &byvar &varlist;
	run;

	data three;
		merge one (in=a) two (in=b);
		by &byvar &varlist;
	 run;


	data three;
		set three;
		length varid $15;
		length what $80;
		length what1 $80;
		length value $30;
		%if %length(&fmt)>0 %then %do;
			what=left(put(&varlist,20.)); /*for sex?*/
			what1=put(&varlist,&fmt);
		%end;
		%else %do;
			what=left(&varlist);
			what1=what;
		%end;
     if what in ('', 'Missing') and what1 in ('', 'Missing')
           then value=trim(left(put(count,5.)));
           else  value=trim(left(put(count,5.))) || ' (' || trim(left(put(percent,8.1))) || ')';
		varid="&varlist";
		param=&porder;

		drop &varlist percent count;
	run;
	proc append base=&outdata data=three force;
	run;
%mend;
%macro conVar(indata=, outdata=, outdata2=, byvar=, varlist=, decimal=, porder=);
	proc sort data=&indata;
		by &byvar;
	run;
	proc means data=&indata noprint;
		by &byvar;
		var &varlist;
		output out=tmp0 n=n mean=mean std=std median=median stderr=stderr p25=p25 p75=p75 min=min max=max;
	run;


	%let mn=%eval(&decimal+1);
	%let s=%eval(&mn+1);
	%let mdecimal=%str(8.&decimal);
	%let mndecimal=%str(8.&mn);
	%let sdecimal=%str(8.&s);
	%let rmn=%sysevalf(0.1**&mn);
	%let rs=%sysevalf(0.1**&s);
	%let rd=%sysevalf(0.1**&decimal);
	data tmp1;
		set tmp0;
		length a_n b_meansd c_medianr /*d_minmax c_se d_median e_minmax*/ $30;
		a_n=trim(left(put(n,5.)));
		b_meansd=trim(left(put(round(mean,&rmn),&mndecimal))) || ' (' || trim(left(put(round(std,&rs),&sdecimal))) || ')';
		c_medianR=trim(left(put(round(median,&rmn),&mndecimal))) ||' ('||trim(left(put(round(min,&rd),&mdecimal))) || ', ' || trim(left(put(round(max,&rd),&mdecimal)))||')';
		/*d_minmax='(' || trim(left(put(round(min,&rd),&mdecimal))) || ', ' || trim(left(put(round(max,&rd),&mdecimal))) ||')';*/
		/*c_se=trim(left(put(round(stderr,&rs),&sdecimal))); */
		/*d_median=trim(left(put(round(median,&rmn),&mndecimal))) ||' ('||trim(left(put(round(min,&rd),&mdecimal))) || ', ' || trim(left(put(round(max,&rd),&mdecimal)))||')';*/
		/*e_minmax=trim(left(put(round(min,&rd),&mdecimal))) || ', ' || trim(left(put(round(max,&rd),&mdecimal)));*/
		if n=0 then delete;
		else do;
			if std=. then b_meansd=trim(left(put(round(mean,&rmn),&mndecimal))) || ' (na)';
			/*if stderr=. then c_se='na';*/
		end;
		drop _type_ _freq_ n mean std median stderr p25 p75 min max;
	run;
	proc sort data=tmp1;
		by &byvar;
	run;
	proc transpose data=tmp1 out=tmp2 name=what;
		by &byvar;
		var a_n b_meansd c_medianr /*d_minmax e_minmax*/;
	run;
	data tmp2;
		length what $80;
		set tmp2;
		length varid $15;
		varid="&varlist";
		%if %length(&porder)>0 %then %do;
			param=&porder;
		%end;
		rename col1=value;
	run;
	proc append base=&outdata data=tmp2 force;
	run;
	%if %length(&outdata2)>0 %then %do;
		data tmp0;
			set tmp0;
			%if %length(&porder)>0 %then %do;
				param=&porder;
			%end;
			drop _type_ _freq_;
		run;
		proc append base=&outdata2 data=tmp0;
		run;
	%end;
%mend;

%macro demog(pop=, sub=, baseout=, titlmain=,group= );

%let outpath=c:\Users\sli126\Documents\GitHub\new;
%let outname=&baseout;

   data adsl;
	  length trt $20;
	  set new.adsl;
	  if sex='ÄÐ' then sex='M'; else sex='F';

        /*if 50=< age <= 65 then agegrp = '50 - 65';
          else if 89>= age >=66 then agegrp = '66 - 89';
	  else agegrp = ' ';*/

      if &pop="Y" &sub;
      trtn=&group;
      trt=put(&group,yn.);
      output;

      trtn=3;
      trt="Overall";
      output; * overall; 
  run;


  proc sql noprint;
	create table npop as
	select trtn, count(distinct subjid) as npop
	from adsl
	where trtn>.z
	group by trtn;

	select npop into :n1 - :n3
	from npop;
  quit;


  data adsl02;
     set adsl;
  run;



 ** check obs - added by fwei on 06/22/2011 **;
 %let dsid = %sysfunc(open(adsl02, i));
 %if &dsid > 0 %then %do;
       %let noobs = %sysfunc(attrn(&dsid,any));
 %end;
 %let dsid = %sysfunc(close(&dsid));

 %if &noobs ne 0 %then %do;

  %conVar(indata=adsl02, outdata=out1, byvar=trtn, varlist=age1, decimal=0, porder=1);
  %conVar(indata=adsl02, outdata=out1, byvar=trtn, varlist=birthweight, decimal=0, porder=3);

  %disVar(indata=adsl02, outdata=outsex, byvar=trtn, varlist=sex, porder=2 , fmt=%str($sexfmt.));
  %disVar(indata=adsl02, outdata=outvd, byvar=trtn, varlist=vitd, porder=4,fmt=%str(yn.));
  %disVar(indata=adsl02, outdata=outca, byvar=trtn, varlist=ca, porder=5,fmt=%str(yn.));
  %disVar(indata=adsl02, outdata=outvdm, byvar=trtn, varlist=vitd_m, porder=6,fmt=%str(yn.));
  %disVar(indata=adsl02, outdata=outcam, byvar=trtn, varlist=ca_m, porder=7,fmt=%str(yn.));
  data out1;
	set out1;
	length what1 $80;
	what1=put(what,$meanfmt.);
  run;

 
  data sex;
	length what $80 what1 what2 $80;
	do j=1 to 3;
	  do i=1 to 2;
		param=2;
		what2=put(i,sexf.);
		what1=upcase(what2);
		what=left(put(i,8.));
		output;
	  end;
	end;
    rename j=trtn;
	drop i;
  run;

  proc sort data=sex;
     by param what1 trtn;
  run;

  proc sort data=outsex;
     by param what1 trtn;
  run;

  data out2;
	merge sex outsex;
        by param what1 trtn;
        if value='' then value='0';
	what=put(what1,$sexf.);
	what1=what2;
	 if what1 = '' and what2 = '' then do;
       what = '99';
       what1= 'Missing';
    end;
  run;

  
  data yn (drop=i);
     length what what1 what2 $80;
	do param = 4 to 7;
     do trtn = 1 to 3;
        do i = 1 to 2;
           what2 = put(i, yn.);
           what1  = what2;
     	   what = left(put(i,8.));
           output;
        end;
     end;
	 end;
  run;

  proc sort data = yn;
     by param what1 trtn;
  run;

data outdis;
	set outvd outca outvdm outcam;
run;
  proc sort data = outdis;
     by param what1 trtn;
  run;


  data out3;
	merge yn outdis;
        by param what1 trtn;
        if value='' then value='0';
    	what =what1;
		what1=what2;
    if what1 = '' and what2 = '' then do;
       what = '99';
       what1= 'Missing';
    end;
  run;


  data final1;
        set out1 out2 out3 ;
  run;

  proc sort data=final1;
	by param what what1;
  run;



/*Add prefix=trt option to be consistent with t_pot_t on 26DEC2012 */
  proc transpose data=final1 prefix=trt out=final2(drop=_name_);
	by param what what1;
    id trtn;
	var value;
  run;

  data subtitle;
        do i=1 to 7;
		param=i;
		length what what1 $80;
		what=left(put(i,orderfmt.));
		what1=what;
		output;
	end;
	drop i;
  run;

  data final3;
	set final2(in=a) subtitle(in=b);
	if a then do;
		suborder=2;
		what1='    '||left(what1);
	end;
	else suborder=1;
  run;

  proc sort data=final3;
	by param suborder what what1;
  run;

  * final patch if any null treatments caused by transpose;
  data final4;
     array _trt{*} $30 trt1 trt2 trt3 ;
     set final3;

     if _trt(3) ^= ""  then do;
        do i=1 to dim(_trt);
           if _trt{i}="" then do;
				if what='A_N' then _trt{i}="0 ";
				else if what in('B_MEANSD','C_MEDIANR','D_MINMAX') then _trt{i}='na';
				else if what ='99' then _trt{i}='0 ';
			end;
		  end;
     end;

     if what1='' then delete;
  
  run;

  proc sort data=final4 out=final ;
     by param suborder;
  run;

  proc sort data=final;
	by  param suborder what what1;
  run;

  data final;
  	set final;
  	by  param suborder what what1;
  run;
  data final;
     retain page1 1;
     set final;
     by param suborder;
     * create page number;
	* x=mod(_n_,1);
*if (mod(_n_, 13)=0 and first.param) or (mod(_n_, 13)>11 and first.param) then page1+1;
         if (mod(_n_, 18)=0 and first.param) or (mod(_n_, 18)>14 and first.param) then page1+1;
  run;
  %end;
  %else %do;
        data final;
           length what what1 $80;
           page1 = 1;
           param = 1;
           suborder = 1;
           what = '1';
           what1 = '';
           array _trt(3) $30  trt1 trt2 trt3 ;
           do i = 1 to dim(_trt);
              _trt(i) = ' ';
           end;
        run;
  %end;
proc sort data=final;
  	by page1 param suborder what what1;
run;

      data final;
        set final;
        if suborder=1 then what1=strip(what1);
      run;

options orientation=portrait;
ods escapechar='^';
ods listing close;
ods rtf file="&outpath\&outname..rtf"  startpage=no style=Journal;
options nodate nonumber center;
title1 "&titlmain";

      proc report missing nowindows split='|' data=final spanrows;
          columns (
                   what1
                   
           		   ("Yes" trt1) 
            	   ("No" trt2)
            	   ("Over all" trt3)
				 
                  );
          define what1  / display " "  flow style={asis=on cellwidth=2in};
          define trt1  / display "(N=&N1)" style={cellwidth=1.5in just=C};
          define trt2  / display "(N=&N2)" style={cellwidth=1.5in just=C};
          define trt3  / display "(N=&N3)" style={cellwidth=1.5in just=C};
      run;


 ods rtf close;

 ods listing;

   proc datasets nolist;
         delete out1 out2 out3 outsex outdis outvd outca outvdm outcam/ memtype=data;
   quit;
 
%mend demog;

%demog(pop=, sub=, baseout=tdemog_vd, titlmain=Demographic character by the usage of Vitamin D,group= vitd );
%demog(pop=, sub=, baseout=tdemog_vdm, titlmain=Demographic character by the usage of Vitamin D of mother,group= vitd_m );
%demog(pop=, sub=, baseout=tdemog_ca, titlmain=Demographic character by the usage of Ca,group= ca );
%demog(pop=, sub=, baseout=tdemog_cam, titlmain=Demographic character by the usage of Ca of mother,group= ca_m );

