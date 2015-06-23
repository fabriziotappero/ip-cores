# sprintf() does not support %f on m6811/m6812 target.
if { [istarget "m6811-*-*"] || [istarget "m6812-*-*"]} {
	return 1
}
# it does not either on scarts_32
if { [istarget "scarts_32-*-*"] } {
	set torture_execute_xfail "scarts_32-*-*"
}
# or on scarts_16
if { [istarget "scarts_16-*-*"] } {
	set torture_execute_xfail "scarts_16-*-*"
}
return 0
