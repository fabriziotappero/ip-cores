# sprintf() does not support %g on scarts_32
if { [istarget "scarts_32-*-*"] } {
	set torture_execute_xfail "scarts_32-*-*"
}
# sprintf() does not support %g on scarts_16
if { [istarget "scarts_16-*-*"] } {
	set torture_execute_xfail "scarts_16-*-*"
}
return 0
