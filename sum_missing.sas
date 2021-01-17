libname data "C:\Users\dragak01\GIT\RetailLoansAnalysis";

%macro sum_missing(libname, dsetin, dsetout);
	*Delete old dataset;
	proc datasets nodetails nolist;
		delete &dsetout;
	quit;

	*Upcase all macro variables to have consistency;
	data _null_;
		call symput ("libname", upcase("&libname."));
		call symput ("dsetin", upcase("&dsetin."));
	run;

	*Formats for missing for character and numeric variables;
	proc format;
		value $ missfmt ' '= "Missing" 'l' = "Missing" 'i' = "Missing" 'M' = "Missing" other="Not Missing";
		value nmissfmt . = "Missing" other="Not Missing";
	run;

	ods table variablesshort=varshort;

	proc contents data=&libname..&dsetin. short;
	run;

	data _null_;
		set varshort;
		call symput ("var_list", variables);
	run;

	proc sql noprint;
		*Get count of total number of observations into macro variable;
		select count(*) into : obs_count

		from &libname..&dsetin.;
	quit;

	*Start looping through the variable list here;
	%let i=1;

	%do %while (%scan(&var_list, &i, " ") ^=%str());
		%let var=%scan(&var_list, &i, " ");

		*Get count of missing;
		proc freq data=&libname..&dsetin. noprint;
			table &var/missing out=cross_tab1;
				format _character_ $missfmt. _numeric_ nmissfmt.;
		run;

		*Get format of missing;
		data _null_;
			set cross_tab1;
			call symput("var_fmt", vformat(&var));
			call symput("var_label", vlabel(&var));
		run;

		data cross_tab2;
			set cross_tab1;
			length variable $50.;
			category=put(&var, &var_fmt.);
			variable="&var_label.";

			if _n_=1 and category='Not Missing' then
				do;;
					Number_Missing=&obs_count-count;
					Percent_Missing=Number_Missing/&obs_count.;
					percent=percent/100;
					output;
				end;
			else if _n_=1 and category='Missing' then
				do;
					Number_Missing=count;
					Percent_Missing=percent/100;
					output;
				end;

			format percent: percent10.1;
			keep variable Number_Missing Percent_Missing;
		run;

		proc append base=&dsetout data=cross_tab2 force;
		run;

		proc datasets nodetails nolist;
			delete cross_tab1 cross_tab2;
		run;

		quit;

		*Increment counter;
		%let i=%eval(&i+1);
	%end;

	*Categorical;
	proc datasets nodetails nolist;
		delete step1;
	run;

	quit;

%mend;

data train;
	set data.abt_sam_beh_train;
run;

data valid;
	set data.abt_sam_beh_valid;
run;

data valid_variables;
	set train;
	keep period act_CMax_Days act_CMax_Due act_CMin_Days act_CMin_Due act_age act_cncr act_cus_cc
         act_cus_dueutl act_cus_loan_number act_cus_n_loans_act act_cus_n_loans_hist
         act_cus_n_statB act_cus_n_statC act_cus_pins act_cus_seniority act_cus_utl 
         app_char_cars app_char_city app_char_home_status app_char_job_code app_char_marital_status
         app_income app_number_of_childre app_spendings default_cus12;
run;

data train;
	set data.abt_sam_beh_train;
run;

proc sql;
	create table period1 as
	select * from train where period like '2004%' or period like '2005%' or period like '2006%'
	order by period asc;
	quit;
run;

proc sql;
	create table period2 as
	select * from train where period like '2007%' or period like '2008%' or period like '2009%'
	order by period asc;
	quit;
run;

proc sql;
	create table period3 as
	select * from train where period like '2010%' or period like '2011%' or period like '2012%'
	order by period asc;
	quit;
run;

proc sql;
	create table period4 as
	select * from train where period like '2013%' or period like '2014%' or period like '2015%'
	order by period asc;
	quit;
run;

proc sql;
	create table period5 as
	select * from train where period like '2016%' or period like '2017%' or period like '2018%'
	order by period asc;
	quit;
run;

%sum_missing(work, period1, class_missing1);
%sum_missing(work, period2, class_missing2);
%sum_missing(work, period3, class_missing3);
%sum_missing(work, period4, class_missing4);
%sum_missing(work, period5, class_missing5);

proc sql;
select cm1.variable, cm1.Number_missing, cm2.Number_missing,cm1.Percent_missing,cm2.Percent_missing
from class_missing1 cm1 join class_missing2 cm2 on cm1.variable=cm2.variable;
run;

proc sql;
select cm1.variable, cm1.Number_missing, cm2.Number_missing,cm3.Number_missing,cm4.Number_missing,cm5.Number_missing,cm1.Percent_missing,cm2.Percent_missing,cm3.Percent_missing,cm4.Percent_missing,cm5.Percent_missing
from class_missing1 cm1 join class_missing2 cm2 on cm1.variable=cm2.variable join class_missing3 cm3 on cm1.variable=cm3.variable join class_missing4 cm4 on cm1.variable=cm4.variable join class_missing5 cm5 on cm1.variable=cm5.variable;
run;

data valid;
	set data.abt_sam_beh_valid;
run;

data yyy;
	set train;
	keep Iqr_CMax_Days  Iqr_CMax_Due  Iqr_CMin_Days  Iqr_CMin_Due  Iqr_Cncr  Kurtosis_CMax_Days  Kurtosis_CMax_Due  Kurtosis_CMin_Days  Kurtosis_CMin_Due  Kurtosis_Cncr  Max_CMax_Days  Max_CMax_Due  Max_CMin_Days  Max_CMin_Due  Max_Cncr  Mean_CMax_Days  Mean_CMax_Due  Mean_CMin_Days  Mean_CMin_Due  Mean_Cncr  Median_CMax_Days  Median_CMax_Due  Median_CMin_Days  Median_CMin_Due  Median_Cncr  Min_CMax_Days  Min_CMax_Due  Min_CMin_Days  Min_CMin_Due  Min_Cncr  N_CMax_Days  N_CMax_Due  N_CMin_Days  N_CMin_Due  N_Cncr  Nmiss_CMax_Days  Nmiss_CMax_Due  Nmiss_CMin_Days  Nmiss_CMin_Due  Nmiss_Cncr  Pctl25_CMax_Days  Pctl25_CMax_Due  Pctl25_CMin_Days  Pctl25_CMin_Due  Pctl25_Cncr  Pctl5_CMax_Days  Pctl5_CMax_Due  Pctl5_CMin_Days  Pctl5_CMin_Due  Pctl5_Cncr  Pctl75_CMax_Days  Pctl75_CMax_Due  Pctl75_CMin_Days  Pctl75_CMin_Due  Pctl75_Cncr  Pctl95_CMax_Days  Pctl95_CMax_Due  Pctl95_CMin_Days  Pctl95_CMin_Due  Pctl95_Cncr  Range_CMax_Days  Range_CMax_Due  Range_CMin_Days  Range_CMin_Due  Range_Cncr  Skewness_CMax_Days  Skewness_CMax_Due  Skewness_CMin_Days  Skewness_CMin_Due  Skewness_Cncr  Std_CMax_Days  Std_CMax_Due  Std_CMin_Days  Std_CMin_Due  Std_Cncr  Sum_CMax_Days  Sum_CMax_Due  Sum_CMin_Days  Sum_CMin_Due  Sum_Cncr;
run;

%sum_missing(work, valid_variables, class_missing);

proc sql;
	select variable into:zmienne separeted by ' '
	from class_missing
	where Percent_Missing < 0.3
	order by Percent_Missing desc;
run;
%put &zmienne;

data sss;
	set train;
	keep act_CMin_Days act_CMax_Days period act_cus_n_statC act_cus_seniority app_char_marital_status act_cus_n_loans_hist app_spendings 
act_cus_cc act_cus_pins act_cus_dueutl act_cus_utl app_char_home_status act_cus_n_loans_act app_char_job_code act_age app_income 
act_cus_n_statB default_cus12 app_char_city act_CMax_Due act_CMin_Due act_cus_loan_number app_char_cars35;
run;

proc sql;
select max(period) from valid;
run;

proc sql;
select max(period) from train;
run;

proc sql;
select * from sss order by period desc;
run;

/*
	2004-2007
	2007-2010
	2010-2013
	2013-2016
	2016-2018
*/

/*
act_CMin_Days act_CMax_Days period act_cus_n_statC act_cus_seniority app_char_marital_status act_cus_n_loans_hist app_spendings 
act_cus_cc act_cus_pins act_cus_dueutl act_cus_utl app_char_home_status act_cus_n_loans_act app_char_job_code act_age app_income 
act_cus_n_statB default_cus12 app_char_city act_CMax_Due act_CMin_Due act_cus_loan_number app_char_cars
35         
*/

%macro gini(dataSet, dataSetVars, vars);
proc sql noprint;
    select count()
    into :n
    from &dataSetVars;
quit;

%do i=1 %to &n;
    %let zm = %scan(&vars, &i,' ');
 	proc freq data=&dataSet;
        TABLES &zm*default_cus12/chisq;
    run;
%end;

%mend;

%gini(testData, testData, &zmienne);

proc freq data=valid;
     TABLES ags21_Range_CMax_Days*default_cus12/chisq;
run;

data filtered;
	set train;
	keep &zmienne;
run;

data xss;
set filtered;
keep period;
run;
