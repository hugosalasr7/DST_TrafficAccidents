import excel "$fig/robust.xls", clear

replace B=round(B, 0.0001)
replace D=round(D, 0.0001)


gen b1 = string(B) + "*" if C<0.1
replace b1 = string(B) + "**" if C<0.05
replace b1 = string(B) + "***" if C<0.01

gen b2 = string(D) + "*" if E<0.1
replace b2 = string(D) + "**" if E<0.05
replace b2 = string(D) + "***" if E<0.01
replace b2 = string(D) if b2==""

drop B C D E
