**This package contains the individual-level dataset ("MassTrials.dta") and the Stata do-file required to replicate the microdata (survey) analysis in the paper, specifically Tables 2, 3, 6, and 8 (and Figures 4 and 5).

**The do-file is organized by the tables and analyses presented in the paper.

clear 
use "C:\Users\Javier Padilla\OneDrive\Desktop\Papers\Transitional Justice Trials\Individual Level\MassTrials.dta" 
set scheme s1color
 set scheme s1mono
 
***Country-year (for the cluster)
gen countryear=country*10000 + year
 
**Argentina (1983) Bolivia (1982) Brazil (1984) Chile (1990) Ecuador (1979) Paraguay (1989) Peru (1980) Uruguay

gen translat=1 if country==32 | country==68 | country==858 | country==604 | country==152 | country==76 | country==218 | country==600

drop if translat!=1 

label define country 32"Argentina" 152 "Chile" 76 "Brasil" 858 "Uruguay" 218 "Ecuador" 600 "Paraguay" 604 "Peru" 68 "Bolivia"
label values country country

**Trials: Argentina in 2007, Uruguay in 2005 (Bordaberry), and Peru in 2005 (Fujimori trial).
gen treat=0 
replace treat=1 if (country==32 & year>2006) | (country==858 & year>2004) | (country==604 & year>2004)

recode ideology (-8=.) (-6=.)

gen right=1 if ideology>5 & ideology!=.
gen left=1 if ideology<5 & ideology!=.
gen centrist=1 if ideology==5 & ideology!=.

replace left=0 if ideology>4

gen ideo3a=0 if ideology<4
replace ideo3a=1 if ideology==5 | ideology==4 | ideology==6
replace ideo3a=2 if ideology>6

bysort country year: egen satism=mean(satdem4)
bysort country year left: egen satismid=mean(satdem4)

recode educ(-5=.)

cd "C:\Users\Javier Padilla\OneDrive\Desktop\Papers\Transitional Justice Trials\Individual Level\Results"

***Controls
**Vote (partisanship)
recode vote (-7/0=.)
reg satdem4 i.treat i.country i.vote

**Party in Power (0 if Ideologically Unaligned Dictatorship ; 1 if Ideologically aligned)

*Argentina
gen partypow=.
replace partypow=1 if year<2000 & country==32
replace partypow=0 if year>2000 & year<2004 & country==32
replace partypow=1 if year>2003 & year<2008 & country==32
replace partypow=0 if year>2007 & year<2016 & country==32

*Bolivia
replace partypow=0 if year<1997 & country==68
replace partypow=1 if year>1996 & year<2003 & country==68
replace partypow=0 if year>2002 & country==68

*Brazil
replace partypow=0 if year<1997 & country==76

*Chile
replace partypow=0 if year<2010 & country==152
replace partypow=1 if year>2009 & year<2014 & country==152
replace partypow=0 if year>2013 & country==152

*Ecuador
replace partypow=1 if year<2010 & country==218
replace partypow=1 if year>2009 & country==218

*Paraguay
replace partypow=1 if year>1994 & year<2008 & country==600
replace partypow=0 if year>2007 & year<2014 & country==600
replace partypow=1 if year>2013 & country==600

*Peru
replace partypow=1 if year<2002 & country==604
replace partypow=0 if year>2001 & country==604

*Uruguay
replace partypow=0 if year>1994 & country==858


**Recode (from less to more)
recode trustcon trustjud trustchurch trustpolice trustmilitary trustpolpar (1=4) (2=3) (3=2) (4=1) 
recode econcon econper (1=5) (2=4) (4=2) (5=1)

**Normal (Table 8)
reg satdem4 i.treat
estimates store m1

reg satdem4 i.treat i.year  
estimates store m2

reg satdem4 i.treat i.year i.country i.vote i.ideology
estimates store m3

reg satdem4 i.treat i.year i.country i.partypow i.ideology
estimates store m4

reg satdem4 i.treat i.year i.country trustjud trustmilitary trustpolpa i.ideology
estimates store m5

reg satdem4 i.treat i.year i.country econcon econper i.ideology
estimates store m6

reg satdem4 i.treat i.year i.country i.vote i.partypow trustjud trustmilitary trustpolpa econcon econper i.ideology
estimates store m7

esttab m1 m2 m3 m4 m5 m6 m7 using "SatisNor.tex",  cells(b(star fmt(%9.2f)) ///
 se(par)) starlev(* .1 ** .05 *** .01) stats(r2 N, fmt(%9.3f %9.0g) labels("R-squared" "N")) legend ///
 nobaselevels varlabels( _cons "Constant") wide ///
 mtitles collabels(,none) varwidth(20) compress replace 

**Heterogeneous effects (table 2)
reg satdem4 i.treat##i.left
estimates store m1

reg satdem4 i.treat##i.left i.year i.country
estimates store m2

reg satdem4 i.treat##i.left i.year i.country age female educ i.vote
estimates store m3

reg satdem4 i.treat##i.left i.year i.country age female educ i.partypow
estimates store m4

reg satdem4 i.treat##i.left i.year i.country age female educ trustjud trustmilitary trustpolpa
estimates store m5

reg satdem4 i.treat##i.left i.year i.country age female educ econcon econper
estimates store m6

reg satdem4 i.treat##i.left i.year i.country age female educ i.vote i.partypow trustjud trustmilitary trustpolpa econcon econper
estimates store m7

esttab m1 m2 m3 m4 m5 m6 m7 using "CitizenHet.tex",  cells(b(star fmt(%9.2f)) ///
 se(par)) starlev(* .1 ** .05 *** .01) stats(r2 N, fmt(%9.3f %9.0g) labels("R-squared" "N")) legend ///
 nobaselevels varlabels( _cons "Constant") wide ///
 mtitles collabels(,none) varwidth(20) compress replace 

 **Figure 4
 reg satdem4 i.treat##i.left i.year i.country age female educ i.vote i.partypow  
margins i.treat#i.left
marginsplot, title(Higher Satisfaction With Democracy After the Trials) ytitle(Satisfaction With Democracy) legend(on order(1 "Non-Left non-Support Dem" 2 "Non-Left Support Dem" 3 "Left non-Support Dem" 4 "Left Support Dem")) xtitle(Trials) xlabel(0 "No" 1 "Yes")

**Including Centrists (robust)
reg satdem4 i.treat##i.ideo3a i.year i.country age female educ i.vote i.partypow  
margins i.treat#i.ideo3a
marginsplot, title(Higher Satisfaction With Democracy After the Trials) ytitle(Satisfaction With Democracy) legend(on order(1 "Non-Left non-Support Dem" 2 "Centrist Support Dem" 3 "Left Support Dem")) xtitle(Trials) xlabel(0 "No" 1 "Yes")


**Heterogeneous effects Support (table 3)
reg satdem4 i.treat##i.left##demsup2
estimates store m1

reg satdem4 i.treat##i.left##demsup2 i.year i.country
estimates store m2

reg satdem4 i.treat##i.left##demsup2 i.year i.country age female educ i.vote
estimates store m3
 
reg satdem4 i.treat##i.left##demsup2 i.year i.country age female educ i.partypow
estimates store m4

reg satdem4 i.treat##i.left##demsup2 i.year i.country age female educ trustjud trustmilitary trustpolpa
estimates store m5

reg satdem4 i.treat##i.left##demsup2 i.year i.country age female educ econcon econper
estimates store m6

reg satdem4 i.treat##i.left##demsup2 i.year i.country age female educ i.vote i.partypow trustjud trustmilitary trustpolpa econcon econper
estimates store m7


esttab m1 m2 m3 m4 m5 m6 m7 using "CitizenHetSup.tex",  cells(b(star fmt(%9.2f)) ///
 se(par)) starlev(* .1 ** .05 *** .01) stats(r2 N, fmt(%9.3f %9.0g) labels("R-squared" "N")) legend ///
 nobaselevels varlabels( _cons "Constant") wide ///
 mtitles collabels(,none) varwidth(20) compress replace 

 **Figure 5
reg satdem4 i.treat##i.left##demsup2 i.year i.country age female educ i.vote i.partypow trustjud trustmilitary trustpolpa econcon econper
margins i.treat#i.left#demsup2
marginsplot, title(Higher Satisfaction With Democracy After the Trials) ytitle(Satisfaction With Democracy) legend(on order(1 "Non-Left non-Support Dem" 2 "Non-Left Support Dem" 3 "Left non-Support Dem" 4 "Left Support Dem")) xtitle(Trials) xlabel(0 "No" 1 "Yes")

**Descripitive (Table 6)
sum satdem4 treat ideology demsup2 age female educ trustjud trustmilitary trustpolpa econcon econper 

**Cluster (country per year // Using clustered standard errors at the country level (eight clusters) would be unreliable because the statistical method is inaccurate with so few groups, leading to standard errors that are too small and a high risk of finding false "statistically significant" results.)

reg satdem4 i.treat##i.left, cl(countryear)
estimates store m1

reg satdem4 i.treat##i.left i.year i.country, cl(countryear)
estimates store m2

reg satdem4 i.treat##i.left i.year i.country age female educ i.vote, cl(countryear)
estimates store m3

reg satdem4 i.treat##i.left i.year i.country age female educ i.partypow, cl(countryear)
estimates store m4

reg satdem4 i.treat##i.left i.year i.country age female educ trustjud trustmilitary trustpolpa, cl(countryear)
estimates store m5

reg satdem4 i.treat##i.left i.year i.country age female educ econcon econper, cl(countryear)
estimates store m6

reg satdem4 i.treat##i.left i.year i.country age female educ i.vote i.partypow trustjud trustmilitary trustpolpa econcon econper, cl(countryear)
estimates store m7

esttab m1 m2 m3 m4 m5 m6 m7 using "CitizenHet.tex",  cells(b(star fmt(%9.2f)) ///
 se(par)) starlev(* .1 ** .05 *** .01) stats(r2 N, fmt(%9.3f %9.0g) labels("R-squared" "N")) legend ///
 nobaselevels varlabels( _cons "Constant") wide ///
 mtitles collabels(,none) varwidth(20) compress replace 


**Heterogeneous Effects
 reg satdem4 i.treat##i.left##demsup2, cl(countryear)
estimates store m1

reg satdem4 i.treat##i.left##demsup2 i.year i.country, cl(countryear)
estimates store m2

reg satdem4 i.treat##i.left##demsup2 i.year i.country age female educ i.vote, cl(countryear)
estimates store m3
 
reg satdem4 i.treat##i.left##demsup2 i.year i.country age female educ i.partypow, cl(countryear)
estimates store m4

reg satdem4 i.treat##i.left##demsup2 i.year i.country age female educ trustjud trustmilitary trustpolpa, cl(countryear)
estimates store m5

reg satdem4 i.treat##i.left##demsup2 i.year i.country age female educ econcon econper, cl(countryear)
estimates store m6

reg satdem4 i.treat##i.left##demsup2 i.year i.country age female educ i.vote i.partypow trustjud trustmilitary trustpolpa econcon econper, cl(countryear)
estimates store m7
