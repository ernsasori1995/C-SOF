libname ptephwk "C:\Users\HP\OneDrive\Desktop\EP 850\person-time homework";

proc sort data= ptephwk.cgsof_t1; by id; run;
proc sort data= ptephwk.cgsof_t2; by id; run;
proc sort data= ptephwk.cgsof_t3; by id; run;
proc sort data= ptephwk.cgsof_t4; by id; run;
proc sort data= ptephwk.cgsof_t5; by id; run;
proc sort data= ptephwk.cgsof_end; by id; run;

data pteplong;
	merge ptephwk.cgsof_t1 ptephwk.cgsof_t2 ptephwk.cgsof_t3 ptephwk.cgsof_t4 ptephwk.cgsof_t5 ptephwk.cgsof_end;
	by id;

time=1;
fuyears=1; 
diedtermbefore=0;
age=t1age; wt=t1wt; married=t1married; hlth=t1hlth; cesdx=t1cesdx; medcon=t1medcon; pssadj=t1pssadj; 
allcg=t1allcg; adlhelpa=t1adlhelpa; iadlhelpa=t1iadlhelpa; status=t1status; output;

*T2;
time=2;
fuyears=(t2age-t1age);
*present;
	if t2status=0 then do;
		diedtermbefore=0;
		age=t2age; wt=t2wt; married=t2married; hlth=t2hlth; cesdx=t2cesdx; medcon=t2medcon; pssadj=t2pssadj; 
		allcg=t2allcg; adlhelpa=t2adlhelpa; iadlhelpa=t2iadlhelpa; status=t2status;
	end;
*other (died, terminated, etc.);
	if t2status ne 0 then do;
		diedtermbefore=2; 
		age=end_age; wt=t1wt; married=t1married; hlth=t1hlth; cesdx=t1cesdx; medcon=t1medcon; pssadj=t1pssadj; 
		allcg=t1allcg; adlhelpa=t1adlhelpa; iadlhelpa=t1iadlhelpa; status=t2status; fuyears=(end_age-t1age); 
	end;
output;

*T3;
time=3;
fuyears=(t3age-t2age);
*present;
	if t3status = 0 then do;
		diedtermbefore=0;
		age=t3age; wt=t3wt; married=t3married; hlth=t3hlth; cesdx=t3cesdx; medcon=t3medcon; pssadj=t3pssadj;
		allcg=t3allcg; adlhelpa=t3adlhelpa; iadlhelpa=t3iadlhelpa;  status=t3status; 
	end;
*other (died, terminated, etc.);
	if t1status eq 0 and t2status eq 0 and t3status ne 0 then do; 
		diedtermbefore = 3;
		age=end_age; wt=t2wt; married=t2married; hlth=t2hlth; cesdx=t2cesdx; medcon=t2medcon; pssadj=t2pssadj; 
		allcg=t2allcg; adlhelpa=t2adlhelpa; iadlhelpa=t2iadlhelpa;  status=t3status; fuyears=(end_age-t2age); 
	end;
*Note: Because there is no do loop specific to participants who died or terminated at t2, 
	values assigned under time=2 will be used (such as diedtermbefore) unless otherwise specified (such as fuyears);

output;

*T4;
time=4;
fuyears=(t4age-t3age);
*present;
	if t4status = 0 then do;
		diedtermbefore=0;
		age=t4age; wt=t4wt; married=t4married; hlth=t4hlth;  cesdx=t4cesdx; medcon=t4medcon; pssadj=t4pssadj;
		allcg=t4allcg; adlhelpa=t4adlhelpa; iadlhelpa=t4iadlhelpa; status=t4status;
	end;
*other (died, terminated, etc.);
	if t1status eq 0 and t2status eq 0 and t3status eq 0 and t4status ne 0 then do;
		diedtermbefore = 4;
		age=end_age; wt=t3wt; married=t3married; hlth=t3hlth; cesdx=t3cesdx; medcon=t3medcon; pssadj=t3pssadj;
		allcg=t3allcg; adlhelpa=t3adlhelpa; iadlhelpa=t3iadlhelpa;  status=t4status; fuyears=(end_age-t3age); 
	end;

output;

*T5;
time=5; 
fuyears=(t5age-t4age); 	

*present;
	if t5status = 0 then do;
		diedtermbefore=0;
		age=t5age; wt=t5wt; married=t5married; hlth=t5hlth;  cesdx=t5cesdx; medcon=t5medcon; pssadj=t5pssadj; 
		allcg=t5allcg; adlhelpa=t5adlhelpa; iadlhelpa=t5iadlhelpa; status=t5status;
	end;
*other (died, terminated, etc.);
if t1status eq 0 and t2status eq 0 and t3status eq 0 and t4status eq 0 and t5status ne 0 then do;
		diedtermbefore=5;
		age=end_age; wt=t4wt; married=t4married; hlth=t4hlth;  cesdx=t4cesdx; medcon=t4medcon; pssadj=t4pssadj;
		allcg=t4allcg; adlhelpa=t4adlhelpa; iadlhelpa=t4iadlhelpa; status=t5status; fuyears=(end_age-t4age); 
	end;

output;

*Keep only certain variables: id, newly created variables, and death and ages (needed for next set of code);
keep id race2 educ2 time fuyears diedtermbefore age wt married hlth cesdx medcon pssadj 
		allcg adlhelpa iadlhelpa status fuyears death term age_term age_death end_age t1age t2age t3age t4age t5age t1wt t1married t1hlth t1cesdx t1medcon t1pssadj 
	t1allcg t1adlhelpa t1iadlhelpa t1status
	t2allcg t3allcg t4allcg t5allcg;; 

run;


data pteplong1; set pteplong ; 
	if diedtermbefore ne 0 then do; *only looking at rows of people who died or terminated;
		if time > diedtermbefore then delete; *remove extra rows for people who died/terminated before interview;
	end;

	*In the homework, this death_now variable is described as "dichotomous death indicator variable which is
	1= died at current age 
	0= did not die at current age";
	if death=1 then do;
		if diedtermbefore=time then death_now=1; *indicator variable for those who died = 1 at the contact they died;
		else death_now = 0; *earlier contacts = 0;
	end;
	if death ne 1 then death_now=0; *assigning 0 values to those who never died;

	*re-creating a variable end_age which represents the age at the last contact completion, termination or death;
	if end_age eq . then do;
		if t5age ne . then end_age = t5age; 
		else if t4age ne . then end_age = t4age;
		else if t3age ne . then end_age = t3age;
		else if t2age ne . then end_age = t2age;
		else end_age = t1age;
	end;
run;

proc freq data=pteplong1;
	tables time*(race2 educ2) /missing;
run;

proc print data = pteplong1 (obs = 30);
	var id time status race2 educ2; *Note values do not appear to change over time within an individual;
run;

proc means data=pteplong1;
class time;
var age wt;
run;

data pteplong1;
set pteplong1;
	length age_cat $ 30;
*we are creating time-varying age categories in this step;
	if age ne . then do;
		if age lt 75 then age_cat = 0; *<75;
		else if age lt 80 then age_cat = 1; *75 to <80;
		else if age lt 85 then age_cat = 2; *80 to <85;
		else if age lt 90 then age_cat = 3; *85 to <90;
		else age_cat = 4; *90+;
	end;

	if wt ne . then do;
		if wt lt 128 then wt_cat = 0; *Q1: <128 lbs;
		else if wt le 146 then wt_cat = 1; *Q2: 128 to 146 lbs;
		else if wt lt 169 then wt_cat = 2; *Q3: 147 to 168 lbs;
		else if wt ge 169 then wt_cat = 3; *Q4: > or = 169 lbs;
	end;

	if pssadj ne . then do;
		if pssadj gt 11 then high_stress = 1; *Stress >11;
		else high_stress = 0; *Stress 0 to 11;
	end;

	if cesdx ne . then do;
		if cesdx ge 16  then high_dep = 1; *Depression > or = 16;
		else high_dep = 0; *Depression 0 to < 16;
	end;
run;

/* caregiving status at baseline*/
proc freq data=pteplong1;
	 tables allcg;
	 where time = 1;
run;

/* creating table 1 for homework*/

proc freq data= pteplong1;
 tables (race2 educ2 married high_dep high_stress) * allcg / norow nopercent nocum missing ;
 where time=1;
run;

proc means data=pteplong1 maxdec=2;
	var age wt;
	class t1allcg; where time=1;
run;

proc freq data=pteplong1;
 tables allcg;
 where time=1;
run;


*CRUDE Model with FIXED BASELINE exposure;
proc phreg data=pteplong1;
	class t1allcg (param=ref ref='0');
	model fuyears*death_now(0) = t1allcg /
/*	ties = exact*/
	rl;
	strata age_cat; *this creates the categorical age-based risk sets;
run;


/*Operationalizing FIXED covariate values based on BASELINE (for models)*/
data pteplong2;
	set pteplong1;

*Categorize the baseline variables so that they are constant (not time varying);
if t1wt ne . then do;
		if t1wt lt 128 then t1wt_cat = 0;
		else if t1wt le 146 then t1wt_cat = 1;
		else if t1wt lt 169 then t1wt_cat = 2;
		else if t1wt ge 169 then t1wt_cat = 3;
	end;

if t1cesdx ne . then do;
		if t1cesdx ge 16  then t1high_dep = 1;
		else t1high_dep = 0;
	end;

if t1pssadj ne . then do;
		if t1pssadj gt 11 then t1high_stress = 1;
		else t1high_stress = 0;
	end;

run;


*4- ADJUSTED model with FIXED BASELINE exposure with adjustment for FIXED BASELINE covariates;
proc phreg data=pteplong2;
	class t1allcg (ref = '0')educ2 race2 t1married t1wt_cat t1high_dep t1high_stress/ param = ref;
	model fuyears*death_now(0) =  t1allcg educ2 race2 t1married t1wt_cat t1high_dep t1high_stress /
/*	ties = exact*/
	rl;
	*Note: Do not need to use t1race2 and t1educ2 because not time varying;
	strata age_cat;
run;

/*estimating the person-years and deaths for FIXED/BASELINE caregiving status*/
proc means  data=pteplong3 sum maxdec = 0;
class t1allcg;
var death_now fuyears;
run;


/* CRUDE model with time-varying exposure*/
proc phreg data=pteplong2;
	class allcg (ref='0') / param=ref;
	model fuyears*death_now(0) = allcg /
/*	ties = exact*/
	rl;
	strata age_cat;
run;

/*ADJUSTED model with time-varying exposure and time-varying covariates*/
proc phreg data=pteplong2;
	class allcg (ref='0')  race2 married educ2 wt_cat high_stress high_dep / param=ref;
	model fuyears*death_now(0) = allcg race2  married educ2 wt_cat high_stress high_dep /
/*	ties = exact*/
	rl;
	strata age_cat;
run;

/*estimating the person-years and deaths for TIME-VARYING caregiving status*/
proc means  data=pteplong3 sum maxdec = 0;
class allcg;
var death_now fuyears;
run;


/* lagged exposure*/
data pteplong3; set pteplong2;
	if time=1 then allcg_lag1 = t1allcg;
	if time=2 then allcg_lag1 = t1allcg;
	if time=3 then allcg_lag1 = t2allcg;
	if time=4 then allcg_lag1 = t3allcg;
	if time=5 then allcg_lag1 = t4allcg;
run;

*Crude model with lagged exposure;
proc phreg data=pteplong3;
	class allcg_lag1 (param=ref ref='0');
	model fuyears*death_now(0) = allcg_lag1/
/*	ties = exact*/
	rl;
	strata age_cat;
run;

*lagged exposure adjusted for time varying covariates;
proc phreg data=pteplong3;
	class allcg_lag1 (ref = '0')  race2 married educ2 wt_cat high_stress high_dep / param = ref;
	model fuyears*death_now(0) = allcg_lag1 race2 married educ2 wt_cat high_stress high_dep /
/*	ties = exact*/
	rl;
	strata age_cat;
run;

/*estimating the person-years and deaths for LAGGED caregiving status*/
proc means  data=pteplong3 sum maxdec = 0;
class allcg_lag1;
var death_now fuyears;
run;
