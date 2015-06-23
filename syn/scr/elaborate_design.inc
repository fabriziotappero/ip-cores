/* Set search path for verilog include files */
search_path = search_path + { RTL_PATH } + { GATE_PATH }
 
/* Read verilog files of the PCI IP core */
if (TOPLEVEL == "TOP") {
    elaborate TOPLEVEL
} else {
        echo "Non-existing top level."
        exit
} 
