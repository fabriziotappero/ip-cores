/* Set search path for verilog include files */
search_path = search_path + { RTL_PATH } + { GATE_PATH }

/* Read verilog files of the GPIO IP core */
if (TOPLEVEL == "gpio") {
	read -f verilog gpio.v
} else {
	echo "Non-existing top level."
	exit
}

