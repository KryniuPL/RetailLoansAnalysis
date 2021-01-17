libname data "C:\Users\dragak01\GIT\RetailLoansAnalysis";

data train;
	set data.abt_sam_beh_train;
run;

data valid;
	set data.abt_sam_beh_valid;
run;


proc contents data=testma³y out=cols noprint; 
run; 

data null; 
   set cols nobs=total; 
   call symputx('totvar', total); 
run;

data missing_count_per_observations; 
	set train; 
	totmiss=cmiss(of _all_); 
	keep cid totmiss default_cus12;
run;

proc rank data=a out=a1;
   var y;
   ranks yrank;
run;
proc print;
run;

proc corr data=missing_count_per_observations spearman kendall hoeffding;
   var totmiss;
   with default_cus12;
run;

proc means data=train N NMISS;
run;

data test1 (keep=app_spendings app_number_of_children);
 set data.abt_sam_beh_valid;
run;

data period_time;
	set data.abt_sam_beh_valid;
	period_date=mdy(substr(period,5,2),1,substr(period,1,4));
    format period_date DDMMYY10.;
	keep period period_date;
run;

data specific_column_train;
set data.abt_sam_beh_train;
keep aid;
run;

data specific_column_valid;
set data.abt_sam_beh_valid;
keep aid;
run;

data specific_time;
set data.abt_sam_beh_valid;
where period like '2004%';
run;

ods select MissPattern;
proc mi data=train nimpute=0;
var default_cus12 app_income act_age app_spendings;
run;

