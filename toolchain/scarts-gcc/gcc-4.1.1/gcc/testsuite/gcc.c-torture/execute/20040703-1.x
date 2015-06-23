# int is only 16 bits on scarts_16 
if { [istarget "scarts_16-*-*"] } {
	set torture_execute_xfail "scarts_16-*-*"
}
return 0
