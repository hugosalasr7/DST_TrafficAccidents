clear
set mem 10m
sjlog using xtserial1, replace
use http://www.stata-press.com/data/r8/nlswork.dta
tsset idcode year
gen age2 = age^2
gen tenure2 = tenure^2
xtserial ln_wage age* ttl_exp tenure* south, output
sjlog close, replace

