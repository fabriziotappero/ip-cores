setMode -bscan
setCable -p usb21
identify
assignfile -p 1 -file xilinx-spa3-dsp1800a.bit
program -p 1 -e -v
quit

