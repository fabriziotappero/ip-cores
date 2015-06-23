# 16-bit "int"
if { [istarget "xstormy16-*"] } {
	return 1
}
if { [istarget "scarts_16-*-*"] } {
	set torture_execute_xfail "scarts_16-*-*"
}

return 0

