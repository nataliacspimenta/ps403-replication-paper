clear 
use "C:\Users\Javier Padilla\OneDrive\Desktop\Papers\Transitional Justice Trials\Argentina\ArgentinaRegional.dta"

label define countries 32 "Argentina" 68 "Bolivia" 76 "Brazil" 152 "Chile" 170 "Colombia"  188 "Costa Rica" 214 "Dominicana" 218 "Ecuador" 222 "El Salvador" 320 "Guatemala" 340 "Honduras" 484 "Mexico" 558 "Nicaragua" 591 "Panama" 600 "Paraguay" 604 "Peru" 724 "Spain" 858 "Uruguay" 862 "Venezuela"
label values country countries  

set scheme s1mono
 
recode ideology (-8=.) (-6=.)

*recode from less to more
recode trustcon trustjud trustchurch trustpolice trustmilitary trustpolpar (1=4) (2=3) (3=2) (4=1) 
recode econcon econper (1=5) (2=4) (4=2) (5=1)
 

gen right=1 if ideology>5 & ideology!=.
gen left=1 if ideology<5 & ideology!=.
gen centrist=1 if ideology==5 & ideology!=.

gen ideo3=0 if left==1
replace ideo3=1 if centrist==1
replace ideo3=2 if right==1

gen extright=1 if ideology>7 & ideology!=.
gen extleft=1 if ideology<3 & ideology!=.

drop if country!=32

foreach var of varlist demsup demsup2 satdem4 ideology econcon trustcon trustjud trustchurch trustpolice trustmilitary trustpolpar {
recode `var' (-1=.) (-2=.) (-3=.) (-4=.)     
}

**Argentina (1983)
gen nocondic=1 if country==32
gen derdic=0 if country==32 
gen lefgov=1 if (country==32 & year>2000 & year<2004) | (country==32 & year>2008 & year<2016)
gen riggov=1 if (country==32 & year<2000) | (country==32 & year<2004 & year<2008)
gen camb=1 if (country==32 & year==1999| year==2003 | year==2007 | year==2015)
gen camblef=1 if (country==32 & year==1999 | year==2007)
gen elec=1 if (country==32) & (year==1995 |  year==1999 | year==2003 | year==2007 | year==2011 | year==2015)

**Regions
tostring reg, gen(strx)
encode strx, gen(region2)

gen regi=.
replace regi=1 if region2==2 | region2==15
replace regi=2 if region2==3 | region2==29
replace regi=3 if region2==4 | region2==30
replace regi=4 if region2==5 | region2==31
replace regi=5 if region2==6 | region2==19
replace regi=6 if region2==7 | region2==21
replace regi=7 if region2==8 | region2==16
replace regi=8 if region2==9 | region2==35
replace regi=9 if region2==10 | region2==26
replace regi=10 if region2==11 | region2==18
replace regi=11 if region2==12 | region2==32
replace regi=12 if region2==13 | region2==23
replace regi=13 if region2==14 | region2==28
replace regi=14 if region2==17
replace regi=15 if region2==20
replace regi=16 if region2==22
replace regi=17 if region2==24
replace regi=18 if region2==25
replace regi=19 if region2==27
replace regi=20 if region2==33
replace regi=21 if region2==34


label define regions 1 "Capital Federal" 2 "Buenos Aires" 3 "Córdoba" 4 "La Pampa" 5 "Chaco" 6 "Entre Ríos" 7 "Mendoza" 8"Río Negro" 9 "Salta" 10 "San Luis" 11 "Santa Fe" 12 "Misiones" 13 "Tucumán" 14 "San Juan" 15 "Corrientes" 16 "Formosa" 17 "Jujuy" 18 "Rioja" 19 "Santiago de Estero" 20 "Chubut" 21 "Neuquén"
label values regi regions  

label define left 0"Non-Leftist" 1 "Leftist"
label values left left  

replace left=0 if left!=1

**Trials 2008
gen treat=0 
replace treat=1 if regi==1 & year>=2008 //*Masacre de Fátima 18/07/2008 Capita Federal
replace treat=1 if regi==3 & year>=2008 //Luciano Benjamín 31/07/2008 Córdoba
replace treat=1 if regi==15 & year>=2008 //De Marchi 06/08/2008  Corrientes
replace treat=1 if regi==12 & year>=2008 // Misiones
replace treat=1 if regi==13 & year>=2008 // Tucumán

**Trials 2009
replace treat=1 if regi==21 & year>=2009 //*Neuquén
replace treat=1 if regi==10 & year>=2009 //*San Luis
replace treat=1 if regi==2 & year>=2009 //*Mar de Plata (Buenos Aires)
replace treat=1 if regi==16 & year>2009 //*Formosa
replace treat=1 if regi==11 & year>2009 //*Santa Fe

**Trials 2010
replace treat=1 if regi==9 & year>=2010 //*Salta
replace treat=1 if regi==18 & year>=2010 //*Rioja
replace treat=1 if regi==19 & year>2010 //*Santiago del Estero
replace treat=1 if regi==7 & year>2010 //*Mendoza
replace treat=1 if regi==4 & year>2010 //*La Pampa
replace treat=1 if regi==5 & year>2010 //*Chaco

**Trials 2011
replace treat=1 if regi==8 & year>=2011 //*Río Negro
replace treat=1 if regi==6 & year>2011 //*Entre Ríos

**Trials 2012
replace treat=1 if regi==20 & year>2012 //*Chubut

**Trials 2013
replace treat=1 if regi==17 & year>=2013 //*Jujuy
replace treat=1 if regi==14 & year>2013 //*San Juan

cd "C:\Users\Javier Padilla\OneDrive\Desktop\Papers\Transitional Justice Trials\Argentina\Results"

 ***Controls
**Vote (partisanship)
recode vote (-7/0=.)

**Results
 
reg satdem4 i.treat##i.left if year>2006 & year<2015, cluster(regi)
estimates store m1

reg satdem4 i.treat##i.left i.year i.regi if year>2006 & year<2015, cluster(regi)
estimates store m2

reg satdem4 i.treat##i.left i.year i.regi age female educ i.vote if year>2006 & year<2015, cluster(regi)
estimates store m3

reg satdem4 i.treat##i.left i.year i.regi age female educ trustjud trustmilitary trustpolpa if year>2006 & year<2015, cluster(regi)
estimates store m4

reg satdem4 i.treat##i.left i.year i.regi age female educ econcon econper if year>2006 & year<2015, cluster(regi)
estimates store m5

reg satdem4 i.treat##i.left i.year i.regi age female educ i.vote trustjud trustmilitary trustpolpa econcon econper if year>2006 & year<2015, cluster(regi)
estimates store m6 
 
esttab m1 m2 m3 m4 m5 m6 using "SatTrialsArDoble.tex",  cells(b(star fmt(%9.2f)) ///
 se(par)) starlev(* .1 ** .05 *** .01) stats(r2 N, fmt(%9.3f %9.0g) labels("R-squared" "N")) legend ///
 nobaselevels varlabels( _cons "Constant") wide ///
 mtitles collabels(,none) varwidth(20) compress replace  

**Without clusters at the region level, results remain robust
reg satdem4 i.treat##i.left i.year i.regi age female educ econcon econper if year>2006 & year<2015

**Graph H2 (Figure 6)
reg satdem4 i.treat##i.left i.year i.regi age female educ econcon econper if year>2005, cluster(regi)
margins treat#left
marginsplot, xtitle(Trial) xlabel(0 "No" 1 "Yes") title("Higher Satisfaction With Democracy After the Trials") ytitle("Satisfaction with Democracy")
 
**Triple 
reg satdem4 i.treat##i.left##demsup2 if year>2006 & year<2015, cluster(regi)
estimates store m1

reg satdem4 i.treat##i.left##demsup2 i.year i.regi if year>2006 & year<2015, cluster(regi)
estimates store m2

reg satdem4 i.treat##i.left##demsup2 i.year i.regi age female educ i.vote if year>2006 & year<2015, cluster(regi)
estimates store m3

reg satdem4 i.treat##i.left##demsup2 i.year i.regi age female educ trustjud trustmilitary trustpolpa if year>2006 & year<2015, cluster(regi)
estimates store m4

reg satdem4 i.treat##i.left##demsup2 i.year i.regi age female educ econcon econper if year>2006 & year<2015, cluster(regi)
estimates store m5

reg satdem4 i.treat##i.left##demsup2 i.year i.regi age female educ i.vote trustjud trustmilitary trustpolpa econcon econper if year>2006 & year<2015, cluster(regi)
estimates store m6 
 
esttab m1 m2 m3 m4 m5 m6 using "SatTrialsArTriple.tex",  cells(b(star fmt(%9.2f)) ///
 se(par)) starlev(* .1 ** .05 *** .01) stats(r2 N, fmt(%9.3f %9.0g) labels("R-squared" "N")) legend ///
 nobaselevels varlabels( _cons "Constant") wide ///
 mtitles collabels(,none) varwidth(20) compress replace 
 
**Graph H3 (Figure 7)
reg satdem4 treat##left##demsup2 i.regi i.year educ female age econcon econper if year>2005, cl(regi)
margins treat#left#demsup2
marginsplot, title(Higher Satisfaction with Democracy After the Trials) ytitle(Satisfaction With Democracy) legend(on order(1 "Non-Left non-Support Dem" 2 "Non-Left Support Dem" 3 "Left non-Support Dem" 4 "Left Support Dem")) xtitle(Trials) xlabel(0 "No" 1 "Yes")  

**Robustness Check Trust (Table 14)

reg trustjud treat##left i.regi i.year ideology educ female age econcon econper if year>2005, cluster(regi)
estimates store m1

reg trustmilitary treat##left i.regi i.year ideology educ female age econcon econper if year>2005, cluster(regi)
estimates store m2

reg trustpolpa treat##left i.regi i.year ideology educ female age econcon econper if year>2005, cluster(regi)
estimates store m3

esttab m1 m2 m3 using "TrustArg.tex",  cells(b(star fmt(%9.2f)) ///
 se(par)) starlev(* .1 ** .05 *** .01) stats(r2 N, fmt(%9.3f %9.0g) labels("R-squared" "N")) legend ///
 nobaselevels varlabels( _cons "Constant") wide ///
 mtitles collabels(,none) varwidth(20) compress replace 
 
**Robustness other variables (Table 12)
reg ideology treat i.regi i.year if year>2006, cluster(regi)
estimates store m1 

reg educ treat i.regi i.year if year>2006, cluster(regi)
estimates store m2

reg female treat i.regi i.year if year>2006, cluster(regi)
estimates store m3 

reg age treat i.regi i.year if year>2006, cluster(regi)
estimates store m4

reg econcon treat i.regi i.year if year>2006, cluster(regi)
estimates store m5 

reg econper treat i.regi i.year if year>2006, cluster(regi)
estimates store m6 

esttab m1 m2 m3 m4 m5 m6 using "Robustness.tex",  cells(b(star fmt(%9.2f)) ///
 se(par)) starlev(* .1 ** .05 *** .01) stats(r2 N, fmt(%9.3f %9.0g) labels("R-squared" "N")) legend ///
 nobaselevels varlabels( _cons "Constant") wide ///
 mtitles collabels(,none) varwidth(20) compress replace 


**Robustness Dev Dem (Table 15)

reg demdev i.treat##i.left if year>2006 & year<2015, cluster(regi)
estimates store m1

reg demdev i.treat##i.left i.year i.regi if year>2006 & year<2015, cluster(regi)
estimates store m2

reg demdev i.treat##i.left i.year i.regi age female educ i.vote if year>2006 & year<2015, cluster(regi)
estimates store m3

reg demdev i.treat##i.left i.year i.regi age female educ trustjud trustmilitary trustpolpa if year>2006 & year<2015, cluster(regi)
estimates store m4

reg demdev i.treat##i.left i.year i.regi age female educ econcon econper if year>2006 & year<2015, cluster(regi)
estimates store m5

reg demdev i.treat##i.left i.year i.regi age female educ i.vote trustjud trustmilitary trustpolpa econcon econper if year>2006 & year<2015, cluster(regi)
estimates store m6 

esttab m1 m2 m3 m4 m5 using "Development Dem.tex",  cells(b(star fmt(%9.2f)) ///
 se(par)) starlev(* .1 ** .05 *** .01) stats(r2 N, fmt(%9.3f %9.0g) labels("R-squared" "N")) legend ///
 nobaselevels varlabels( _cons "Constant") wide ///
 mtitles collabels(,none) varwidth(20) compress replace 


 
**Not included in the paper
 
**Placebo Treatment (moving everyhing three years before)

**placebo 2005
gen placebo=0 
replace placebo=1 if regi==1 & year>=2005 // Capita Federal
replace placebo=1 if regi==3 & year>=2005 // Córdoba
replace placebo=1 if regi==15 & year>=2005 //Corrientes
replace placebo=1 if regi==13 & year>=2005 // Tucumán
replace placebo=1 if regi==12 & year>=2005 // Misiones

**placebo 2006
replace placebo=1 if regi==21 & year>=2006 //*Neuquén
replace placebo=1 if regi==10 & year>=2006 //*San Luis
replace placebo=1 if regi==2 & year>=2006 //*Mar de Plata (Buenos Aires)
replace placebo=1 if regi==16 & year>2006 //*Formosa
replace placebo=1 if regi==11 & year>2006 //*Santa Fe

**placebo 2007
replace placebo=1 if regi==9 & year>=2007 //*Salta
replace placebo=1 if regi==18 & year>=2007 //*Rioja
replace placebo=1 if regi==19 & year>2007 //*Santiago del Estero
replace placebo=1 if regi==7 & year>2007 //*Mendoza
replace placebo=1 if regi==4 & year>2007 //*La Pampa
replace placebo=1 if regi==5 & year>2007 //*Chaco

**placebo 2008
replace placebo=1 if regi==8 & year>=2008 //*Río Negro
replace placebo=1 if regi==6 & year>2008 //*Entre Ríos

**placebo 2009
replace placebo=1 if regi==20 & year>2009 //*Chubut

**Trials 2010
replace placebo=1 if regi==17 & year>=2010 //*Jujuy
replace placebo=1 if regi==14 & year>2010 //*San Juan

cd "C:\Users\fnac\Desktop\Paper Míos\AP PP\Argentina"

**Interaction

reg satdem4 placebo##left i.regi i.year if year>2003 & year<2011, cluster(regi)
estimates store m1

reg satdem4 placebo##left i.regi i.year educ female age if year>2003 & year<2011, cluster(regi)
estimates store m2

reg satdem4 placebo##left i.regi i.year age female educ trustjud trustmilitary trustpolpa if year>2003 & year<2010, cl(regi)
estimates store m3
