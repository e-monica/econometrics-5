*==========================================================================================
*Title: monica_timeseries.do
*Author: Monica Elgawly
*Date created: 5/14/2018
*Date modified: 5/14/2018
*Problem Set: 5
*==========================================================================================

cap log close
clear
set more off

log using "/Users/monica_timeseries.log", replace
use "/Users/USmacro_Quarterly.dta"

*==========================================================================================
*Exercise Chapter 14: Question 1(a)(i)
*==========================================================================================

sort time;
ge lpcep = log(PCECTPI); 
// 1 missing value generated
ge infl = 400*[lpcep-lag_lpcep];
// 1 missing value generated 
su infl;

*==========================================================================================
*Exercise Chapter 14: Question1(a)(ii) 
*==========================================================================================

ge year = substr(time, 1, 4);
ge quarter = substr(time, 7, 7);
ge year_quarter, force replace;
//ear_quarter contains nonnumeric characters; year_quarter replaced as int
twoway connected infl year_quarter;
graph export "/Users/Stata/Lecture_24/infl.pdf', replace

//insert graph here!
// Inflation increased over the 20 year period 1960-1980, then declined for a decade
// and has been reasonably stable since then. It appears to have a stochastic trend.

*==========================================================================================
*Exercise Chapter 14: Question1(b)(i) 
*==========================================================================================

sort time;
ge t=_n;
tsset t;
//time variable: t, 1 to 228, delta one unit
ge lag_infl = infl(_n-1);
// 2 missing values generated 
corrgram dinfl, lag(4);

//looks like the series is negatively correlated

*==========================================================================================
*(c) Estimate an AR(1) of change in infl_t on change in inflation_t-1
*Does knowing the change in inflation this quarter help forecast the change in 
*inflation in the next quarter?
*==========================================================================================

reg dinfl L1.dinfl;

// The coefficient on lagged change in inflation is statistically insignificant, 
// so lagged change in inflation helps predict current change in inflation.
// If the change in inflation increased between last quarter and this quarter
// then we forecast that it will decrease between this quarter and next quarter

*==========================================================================================
*(c) ii. Estimate a AR(2) model change in inflation. Is the AR(2) model better than the AR(1)?
*==========================================================================================

reg dinfl L1.dinfl L2.dinfl;

// The estimated coefficient on change in inflation_t-2 is statistically significant so the
// AR(2) model is preferred to the AR(1) model. Note also that the adjusted R^2 increased from
// .08 in the AR(1) model to .13 in the AR(2) model.

*==========================================================================================
*(c) iii. Estimate a AR(p) model for change in inflation for p=0,...,8. What lag length 
* is chosen by BIC and AIC?
*==========================================================================================

reg dinfl L(1/8).dinfl;
varsoc dinfl, maxlag(8);

//The BIC and AIC say we should choose p=2.
*==========================================================================================
*(c) iv. Use the AR(2) model to predict the change in inflation from 2012:Q4 to 2013:Q1.
*==========================================================================================
reg dinfl L(1/2).dinfl;

// The forecast for the change in inflation for 2013:Q1 is 
// -.01 - .35(-.06) - .24(.62) = -.14

*==========================================================================================
*(c) v. Use the AR(2) model to predict the level of inflation in 2013:Q1.
*==========================================================================================
tab infl if year_quarter==20124;
//The forecast for the level of inflation in '13:Q1 is: 
// infl_'12:4 + estimate of the change in inflation_'13:1 = 1.61-.14 = 1.47
*==========================================================================================
*(d) i. Use the ADF test for the regression with two lags to test for a stochastic trend
* in inf.
*==========================================================================================
dfuller infl, lags(2);
//Since -2.882 < -2.707 < -2.572, we can reject the null hypothesis of nonstationarity 
//in inflation at the 10% level, but not at the 5% level
*==========================================================================================
*==========================================================================================
clear

