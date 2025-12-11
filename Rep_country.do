***Description
*You need to use the data ("Supportdem.dta") and this Stata do-file required to replicate the tables and figures in the paper.

**The do-file is extensively commented to explain the purpose of each step.
**Set Your Working Directory

**The do-file uses absolute file paths (e.g., `C:\Users\Javier Padilla...`). **You must change these paths** to match the locations on your own computer.

* **Line 17:** Change `use "C:\Users\Javier Padilla\..."` to point to where you saved `Supportdem.dta`.
* **Line 44:** Change `cd "C:\Users\Javier Padilla\..."` to point to the folder where you want to save output tables.
**Recommendation:** The easiest method is to save the do-file and `Supportdem.dta` in the same folder, set that folder as your Stata working directory, and then simply use `use "Supportdem.dta"` and `esttab ... using "SatTrialAut.tex"`.

**B. Install Required Stata Packages. This was originall run in Stata 17.
*This analysis uses several user-written packages. Before running the do-file, please install them by running the following commands in your Stata console:

clear
use "C:\Users\Javier Padilla\OneDrive\Desktop\Papers\Transitional Justice Trials\Country Level\Supportdem.dta"

set scheme s1color
tostring idenpa, gen(pais)

**Data Visualization
net install grc1leg, from(http://www.stata.com/users/vwiggins) replace
net install gr0075, from(http://www.stata-journal.com/software/sj18-4) replace
ssc install labutil, replace
ssc install sencode, replace
net install panelview, all replace from("https://yiqingxu.org/packages/panelview_stata")

gen tranco=trancou
replace tranco=0 if tran>year

gen treat4=0 if treattrial==0 & tranco==0
replace treat4=1 if treattrial==0 & tranco==1
replace treat4=2 if treattrial==1 & tranco==1
replace treat4=3 if treattrial==1 & tranco==0

bysort idenpa: egen trialco=max(treattrial)

gen libd=libdem2 *100

**Figure Treatments
panelview libdem2 treat4 trancou if year>1986, i(idenpa) t(year) type(treat) xtitle("Year") ytitle("State") title("Treatment Status") bytiming legend(label(1 "No Transition") label(2 "Transition without Trial") label(3 "Transition with Trial") label(4 "Trial Without Transition"))  
**Two Way Fixed-Effect (comparing democracies)
cd "C:\Users\Javier Padilla\OneDrive\Desktop\Papers\Transitional Justice Trials\Country Level\Results"
**Satisfaction democracy

label var treattrial "Trial"
label var treatamnesty "Amnesty"
label var inflation "Inflation"
label var libdem "Liberal Democracy"
label var gdpca "GDP per Capita"
label var v2x_partip "Participation Index"
label var kill "Repression Kills"
label var disap "Repression Disappeared"

**Lag variables
sort idenpa year
by idenpa: gen lagamne = treatamnesty[_n-1]
by idenpa: gen lagtruth = treattruthco[_n-1]
by idenpa: gen lagtrial = treattrial[_n-1]
by idenpa: gen laginflation = inflation[_n-1]
by idenpa: gen laglibdem = libdem[_n-1]
by idenpa: gen laggdpca = gdpca[_n-1]
by idenpa: gen lagv2x_partip = v2x_partip[_n-1]
by idenpa: gen lagkill = kill[_n-1]
by idenpa: gen lagdisap = disap[_n-1]
by idenpa: gen lagchangede = changede[_n-1]
by idenpa: gen lagv2xnp_regcorrl = v2xnp_regcorr[_n-1]


**Trials after Transition (Table 1) (in countries that transitioned to democracy (trancou==1 and during the democratic time yeartra>0))
xtreg satisdem treattrial if trancou==1 & yeartra>0, fe 
estimates store m1

xtreg satisdem treattrial i.year if trancou==1 & yeartra>0, fe 
estimates store m2

xtreg satisdem treattrial i.year treatamnesty treattruthco if trancou==1 & yeartra>0, fe 
estimates store m3

xtreg satisdem treattrial i.year treatamnesty treattruthco inflation gdpca libdem changede kill disap v2x_partip v2xnp_regcorr if trancou==1 & yeartra>0, fe
estimates store m4

**Trials in dictatorships (Robust) Table 11 Appendix
destring Satis_Autoc, gen(satisaut)
recode satisaut (0=.)

xtreg satisaut treattrial, fe 
estimates store n1

xtreg satisaut treattrial i.year, fe 
estimates store n2

xtreg satisaut treattrial i.year treatamnesty treattruthco, fe 
estimates store n3

xtreg satisaut treattrial i.year treatamnesty treattruthco inflation gdpca libdem changede kill disap v2x_partip v2xnp_regcorr, fe
estimates store n4

esttab n1 n2 n3 n4 using "SatTrialAut.tex",  cells(b(star fmt(%9.2f)) ///
 se(par)) starlev(* .1 ** .05 *** .01) stats(r2 N, fmt(%9.3f %9.0g) labels("R-squared" "N")) legend ///
 nobaselevels varlabels( _cons "Constant") wide ///
 mtitles collabels(,none) varwidth(20) compress replace 

**Model with Lags (Robust)
xtreg satisdem lagtrial i.year lagamne lagtruth laginflation laggdpca laglibdem lagkill lagdisap lagchangede lagv2xnp_regcorrl if trancou==1 & yeartra>0, fe 

**Model with argentina and bolivia (generally robust) (if this is ran, re-run the code from the beginning without including this part)
*replace treattrial=1 if idenpa==5 
*replace treattrial=1 if idenpa==17
*xtreg satisdem treattrial if trancou==1 & yeartra>0, fe 
*xtreg satisdem treattrial i.year if trancou==1 & yeartra>0, fe
*xtreg satisdem treattrial treatamnesty treattruthco i.year if trancou==1 & yeartra>0, fe
*xtreg satisdem treattrial i.year treatamnesty treattruthco inflation gdpca libdem changede kill disap v2x_partip v2xnp_regcorr if trancou==1 & yeartra>0, fe

**Model with random effects (Robust)
xtreg satisdem treattrial if trancou==1 & yeartra>0, re 
xtreg satisdem treattrial i.year if trancou==1 & yeartra>0, re 
xtreg satisdem treattrial i.year treatamnesty treattruthco if trancou==1 & yeartra>0, re 
xtreg satisdem treattrial i.year treatamnesty treattruthco inflation gdpca libdem changede kill disap v2x_partip v2xnp_regcorr if trancou==1 & yeartra>0, re


**Effects of later trials in consolidated democracies (Robust)
*Chile (no more than 10 years)
replace treattrial=0 if idenpa==31  & yeartra>=0

**Venezuela (no more than 10 years)
replace treattrial=0 if idenpa==183 

**Romania (no more than 10 years)
replace treattrial=0 if idenpa==136 

**Mexico (no more than 10 years)
replace treattrial=0 if idenpa==106 

**Azerbaijan (no more than 10 years)
replace treattrial=0 if idenpa==9 

**El Salvador (no more than 10 years)
replace treattrial=0 if idenpa==49 

**Uruguay (reopening of trials)
replace treattrial=0 if idenpa==180 & year<2008

**Peru (Abimael)
replace treattrial=0 if idenpa==129 & year<2005
replace yearttrial=2004 if idenpa==129

**Moldova (no more than 10 years)
replace treattrial=0 if idenpa==107

**Panama (no more than 10 years)
replace treattrial=0 if idenpa==126

**Russia (no more than 10 years)
replace treattrial=0 if idenpa==137

*South Africa (no more than 10 years)
replace treattrial=0 if idenpa==152

**Turkey (no more than 10 years)
replace treattrial=0 if idenpa==173

*Egypt (no more than 10 years)
replace treattrial=0 if idenpa==48

*Ghana (no more than 10 years)
replace treattrial=0 if idenpa==62

*Indonesia (no more than 10 years)
replace treattrial=0 if idenpa==74

*Pakistan (no more than 10 years)
replace treattrial=0 if idenpa==123

**Uzbekistan (no more than 10 years)
replace treattrial=0 if idenpa==181

*Sri Lanka (no more than 10 years)
replace treattrial=0 if idenpa==157

*Lesotho (no more than 10 years)
replace treattrial=0 if idenpa==92

**Balance Panel
sort idenpa year
by idenpa: egen nonmissing1to7 = count(satisdem) if (year==1999 | year==2000 | year==2001 | year==2002 | year==2003 | year==2004 | year==2005 | year==2006 | year==2007 | year==2008 | year==2009 | year==2010 | year==2011 | year==2012)
keep if  nonmissing1to7==12 | nonmissing1to7==13 | nonmissing1to7==14

**Column 5 Table 1
xtreg satisdem treattrial i.year inflation libdem treatamnesty treattruthco gdpca v2x_partip kill disap if trancou==1 & yeartra>0, fe
estimates store m5

esttab m1 m2 m3 m4 m5 using "SatTrialsArTo.tex",  cells(b(star fmt(%9.2f)) ///
 se(par)) starlev(* .1 ** .05 *** .01) stats(r2 N, fmt(%9.3f %9.0g) labels("R-squared" "N")) legend ///
 nobaselevels varlabels( _cons "Constant") wide ///
 mtitles collabels(,none) varwidth(20) compress replace 

 panelview satisdem treattrial trancou if year>1986, i(idenpa) t(year) type(treat) xtitle("Year") ytitle("State") title("Trial After The Transition") bytiming legend(label(1 "No Trial or Trial in Transition") label(2 "Trial After Transition"))  

 
 **Descripitive (Table 4)
sum satisdem treattrial inflation libdem treatamnesty treattruthco v2x_partip kill disap supdem changede v2xnp_regcorr gdpca

**Figure Treatments (Figure 8)
panelview satisdem treattrial trancou if trancou==1, i(idenpa) t(year) type(treat) xtitle("Year") ytitle("State") title("Treatment Status") bytiming legend(label(1 "No TJ Trial") label(2 "TJ Trial") label(3 "Transition with Trial") label(4 "Trial Without Transition"))  

order idenpa year treattrial satisdem nonmissing1to7

**Main Graph (Transition Democracies)
did_multiplegt_old satisdem idenpa year treattrial if trancou==1, robust_dynamic dynamic(5) placebo(5) breps(20) controls(treatamnesty treattruthco changede) seed(22) cluster(Region_VD)

ssc install event_plot 

event_plot e(estimates)#e(variances), default_look ///
	graph_opt(xtitle("Years since the event") ytitle("Average causal effect") ///
	title("Average Treatment Effect on SWD") xlabel(-5(1)5)) stub_lag(Effect_#) stub_lead(Placebo_#) together
*graph export "did_multiplegt_controls_report.png"

**Main Graph (Not in the paper: With More Variables: similar results)
did_multiplegt_old satisdem idenpa year treattrial if trancou==1, robust_dynamic dynamic(5) placebo(5) breps(20) controls(treatamnesty treattruthco inflation libdem gdpca v2x_partip changede) seed(22) cluster(Region_VD)

event_plot e(estimates)#e(variances), default_look ///
	graph_opt(xtitle("Years since the event") ytitle("Average causal effect") ///
	title("Average Treatment Effect on SWD") xlabel(-5(1)5)) stub_lag(Effect_#) stub_lead(Placebo_#) together
*graph export "did_multiplegt_controls_report.png"

**Not in the paper: **With Other Controls (With Even More Variables: similar results)
did_multiplegt_old satisdem idenpa year treattrial if trancou==1, robust_dynamic dynamic(5) placebo(5) breps(20) controls(treatamnesty treattruthco inflation libdem gdpca v2x_partip kill disap changede v2xnp_regcorr) cluster(Region_VD) seed(18)

event_plot e(estimates)#e(variances), default_look ///
	graph_opt(xtitle("Years since the event") ytitle("Average causal effect") ///
	title("Average Treatment Effect on SWD") xlabel(-5(1)5)) stub_lag(Effect_#) stub_lead(Placebo_#) together
*graph export "did_multiplegt_controls_report.png"

**Not in the paper: **Main Graph (Without Cluster at the World Level: similar results)
did_multiplegt_old satisdem idenpa year treattrial if trancou==1, robust_dynamic dynamic(5) placebo(5) breps(20) controls(treatamnesty treattruthco inflation libdem gdpca v2x_partip kill disap changede v2xnp_regcorr) seed(21) 

event_plot e(estimates)#e(variances), default_look ///
	graph_opt(xtitle("Years since the event") ytitle("Average causal effect") ///
	title("Average Treatment Effect on SWD") xlabel(-5(1)5)) stub_lag(Effect_#) stub_lead(Placebo_#) together
*graph export "did_multiplegt_controls_report.png"

ssc install ftools,replace
ssc install _gwtmean,replace

**FECT (Figure 3) As indicated in the paper, there are some slight variations each time FECT command is run because there are simulations. 
fect satisdem, treat(treattrial) unit(idenpa) time(year) cov(treatamnesty treattruthco inflation libdem gdpca v2x_partip changede) method("fe") force("two-way") preperiod(-5) offperiod(5) se title(EAT of Trials) 

**Other Controls (Not in the paper: With more variables: Robust)
fect satisdem, treat(treattrial) unit(idenpa) time(year) cov(inflation libdem treatamnesty treattruthco v2x_partip kill disap supdem) method("fe") force("two-way") preperiod(-5) offperiod(5) se title(EAT of Trials)





