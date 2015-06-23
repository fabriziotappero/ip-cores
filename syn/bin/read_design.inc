/* Set search path for verilog include files */
search_path = search_path + { RTL_PATH } + { GATE_PATH }

/* Read verilog files of the PTC IP core */
if (TOPLEVEL == "ptc") {
	read -f verilog ptc.v
} else {
	echo "Non-existing top level."
	exit
}

